# Tests the actual final MSI on a disposable CI runner, without owner credentials.
param(
  [Parameter(Mandatory=$true)][string]$MsiPath,
  [Parameter(Mandatory=$true)][string]$PayloadZipPath,
  [Parameter(Mandatory=$true)][string]$EvidenceDirectory
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if (-not $IsWindows -or $env:GITHUB_ACTIONS -ne 'true' -or $env:RUNNER_ENVIRONMENT -ne 'github-hosted') {
  throw 'Installer smoke is restricted to a disposable GitHub-hosted Windows runner'
}
$msi = (Resolve-Path -LiteralPath $MsiPath).Path
$zip = (Resolve-Path -LiteralPath $PayloadZipPath).Path
New-Item -ItemType Directory -Force -Path $EvidenceDirectory | Out-Null
$evidence = (Resolve-Path -LiteralPath $EvidenceDirectory).Path
$installRoot = Join-Path $env:RUNNER_TEMP ('MorseCQ installer smoke ' + [guid]::NewGuid().ToString('N'))
$exe = Join-Path $installRoot 'morsecq.exe'
$preflight = Join-Path $PSScriptRoot 'release_preflight.py'
$app = $null
$installAttempted = $false
$installed = $false
$report = [ordered]@{
  platform = [Environment]::OSVersion.VersionString
  msi_sha256 = (Get-FileHash -LiteralPath $msi -Algorithm SHA256).Hash
  zip_sha256 = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
  stages = [System.Collections.Generic.List[string]]::new()
  outcome = 'running'
}

function Invoke-Msi([string]$Stage, [string[]]$Arguments, [switch]$AllowAbsent) {
  $log = Join-Path $evidence "$Stage.log"
  $process = Start-Process msiexec.exe -ArgumentList ($Arguments + @('/qn', '/norestart', '/L*v', "`"$log`"")) -PassThru
  if (-not $process.WaitForExit(180000)) {
    $process.Kill()
    throw "MSI $Stage timed out after 180 seconds; see $log"
  }
  if ($process.ExitCode -notin @(0, 3010) -and -not ($AllowAbsent -and $process.ExitCode -eq 1605)) {
    throw "MSI $Stage failed with exit $($process.ExitCode); see $log"
  }
  $report.stages.Add("$Stage exit=$($process.ExitCode)")
}

function Assert-InstalledPayload([string]$Stage) {
  foreach ($file in @('morsecq.exe', 'flutter_windows.dll', 'data/app.so', 'data/icudtl.dat', 'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll', 'licenses/MSVC-runtime.txt')) {
    if (-not (Test-Path -LiteralPath (Join-Path $installRoot $file) -PathType Leaf)) {
      throw "MSI omitted required release payload: $file"
    }
  }
  & python $preflight --output (Join-Path $evidence "$Stage.json") native $installRoot --platform windows --architecture x86_64 --expected-zip $zip
  if ($LASTEXITCODE -ne 0) { throw "Installed payload verification failed: $Stage" }
  $runtimeFiles = @(Get-ChildItem -LiteralPath $installRoot -File | Where-Object { $_.Name -match '^(?:msvcp140|vcruntime140|concrt140).*\.dll$' })
  foreach ($file in $runtimeFiles) {
    $signature = Get-AuthenticodeSignature -LiteralPath $file.FullName
    if ($signature.Status -ne 'Valid' -or $null -eq $signature.SignerCertificate -or $signature.SignerCertificate.Subject -notmatch '(^|,\s*)O=Microsoft Corporation(,|$)') {
      throw "MSVC runtime does not retain its trusted Microsoft signature: $($file.Name)"
    }
  }
  $report.stages.Add("$Stage hashes and native architecture verified")
}

function Test-InstalledWindow([string]$Stage) {
  $script:app = Start-Process -FilePath $exe -WorkingDirectory $installRoot -PassThru
  $deadline = [DateTime]::UtcNow.AddSeconds(30)
  do {
    Start-Sleep -Milliseconds 250
    $script:app.Refresh()
    if ($script:app.HasExited) { throw "Installed application exited before showing a window: $($script:app.ExitCode)" }
  } while ($script:app.MainWindowHandle -eq 0 -and [DateTime]::UtcNow -lt $deadline)
  if ($script:app.MainWindowHandle -eq 0) { throw 'Installed application did not show a main window within 30 seconds' }
  Start-Sleep -Seconds 10
  $script:app.Refresh()
  if ($script:app.HasExited) { throw "Installed application exited during startup: $($script:app.ExitCode)" }
  $loaded = @($script:app.Modules)
  $runtimeModules = @()
  foreach ($name in @('flutter_windows.dll', 'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll')) {
    $modules = @($loaded | Where-Object { $_.ModuleName -ieq $name })
    $expected = [IO.Path]::GetFullPath((Join-Path $installRoot $name))
    if ($modules.Count -ne 1 -or -not [string]::Equals($modules[0].FileName, $expected, [StringComparison]::OrdinalIgnoreCase)) {
      throw "Installed application did not load $name from its own payload directory"
    }
    $runtimeModules += @{ name = $name; path = $modules[0].FileName; version = $modules[0].FileVersionInfo.FileVersion }
  }
  $report["${Stage}_runtime_modules"] = $runtimeModules
  # Fresh runner preferences leave close-to-tray disabled. A forced cleanup
  # below must never turn a refused close or an orphan process into a pass.
  if (-not $script:app.CloseMainWindow()) { throw 'Installed window did not accept the close request' }
  if (-not $script:app.WaitForExit(20000)) { throw 'Installed application did not quit after closing the fresh-profile window' }
  if ($script:app.ExitCode -ne 0) { throw "Installed application quit with exit $($script:app.ExitCode)" }
  $report.stages.Add("$Stage visible window and graceful quit verified")
}

function Get-MsiProductState {
  $installer = New-Object -ComObject WindowsInstaller.Installer
  $database = $null
  $view = $null
  $record = $null
  try {
    $database = $installer.OpenDatabase($msi, 0)
    $view = $database.OpenView('SELECT `Value` FROM `Property` WHERE `Property` = ''ProductCode''')
    [void]$view.Execute()
    $record = $view.Fetch()
    if (-not $record) { throw 'MSI ProductCode is missing' }
    $code = $record.StringData(1)
    $state = $installer.GetType().InvokeMember('ProductState', 'GetProperty', $null, $installer, @($code))
    return [pscustomobject]@{ product_code = $code; state = $state }
  } finally {
    if ($view) { [void]$view.Close() }
    foreach ($item in @($record, $view, $database, $installer)) {
      if ($item) { [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($item) }
    }
  }
}

try {
  # Do not close or uninstall another running copy. This is a disposable-runner
  # test, not an installation command for a developer's regular desktop.
  if (@(Get-Process -Name morsecq -ErrorAction SilentlyContinue).Count) {
    throw 'An existing MorseCQ process makes this runner unsuitable for the installer smoke test'
  }
  $product = Get-MsiProductState
  $report['product_code'] = $product.product_code
  if ($product.state -ne -1) {
    throw "MSI product is already registered (state $($product.state)); refusing to change an existing install"
  }
  # path_provider_windows uses KnownFolder paths and version resources, not
  # an APPDATA environment override. Refuse an existing profile; do not erase it.
  $dataDirectories = @(
    (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'icu.agentx/morsecq'),
    (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'icu.agentx/morsecq')
  )
  $report['data_directories'] = $dataDirectories
  foreach ($directory in $dataDirectories) {
    if (Test-Path -LiteralPath $directory) { throw 'An existing MorseCQ data directory makes this runner unsuitable for a fresh-profile test' }
  }
  $installAttempted = $true
  Invoke-Msi 'install' @('/i', "`"$msi`"", "INSTALL_ROOT=`"$installRoot`"")
  $installed = $true
  $identity = [Diagnostics.FileVersionInfo]::GetVersionInfo($exe)
  if ($identity.CompanyName -ne 'icu.agentx' -or $identity.ProductName -ne 'morsecq') {
    throw 'Installed version resources disagree with the expected application data identity'
  }
  Assert-InstalledPayload 'installed'
  Test-InstalledWindow 'installed'
  Remove-Item -LiteralPath (Join-Path $installRoot 'flutter_windows.dll')
  Invoke-Msi 'repair' @('/i', "`"$msi`"", 'REINSTALL=ALL', 'REINSTALLMODE=vomus', "INSTALL_ROOT=`"$installRoot`"")
  Assert-InstalledPayload 'repaired'
  Test-InstalledWindow 'repaired'
  Invoke-Msi 'uninstall' @('/x', "`"$msi`"")
  $installed = $false
  if (Test-Path -LiteralPath $installRoot) {
    if (@(Get-ChildItem -LiteralPath $installRoot -File -Recurse).Count) {
      throw 'Uninstall left files in the installed payload directory'
    }
  }
  if ((Get-MsiProductState).state -ne -1) { throw 'Uninstall left the MSI product registered' }
  if (@(Get-Process -Name morsecq -ErrorAction SilentlyContinue).Count) { throw 'Uninstall left a MorseCQ process running' }
  $report.outcome = 'passed'
} catch {
  $report.outcome = 'failed'
  $report['error'] = $_.Exception.Message
  throw
} finally {
  try {
    if ($app -and -not $app.HasExited) { Stop-Process -Id $app.Id -Force }
    if ($installed -or ($installAttempted -and $report.outcome -ne 'passed')) {
      Invoke-Msi 'cleanup-uninstall' @('/x', "`"$msi`"") -AllowAbsent
    }
  } catch {
    $report['cleanup_error'] = $_.Exception.Message
    $report.outcome = 'failed'
    throw
  } finally {
    $report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $evidence 'result.json') -Encoding utf8
  }
}
Write-Host 'Final Windows MSI passed install, payload verification, visible launch, graceful quit, repair and uninstall.'
