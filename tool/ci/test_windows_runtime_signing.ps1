param([Parameter(Mandatory=$true)][string]$RuntimePath)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$original = (Resolve-Path -LiteralPath $RuntimePath).Path
$signature = Get-AuthenticodeSignature -LiteralPath $original
if ($signature.Status -ne 'Valid' -or $null -eq $signature.SignerCertificate -or $signature.SignerCertificate.Subject -notmatch '(^|,\s*)O=Microsoft Corporation(,|$)') {
  throw 'Regression requires a real trusted Microsoft runtime as its input'
}
$temporary = Join-Path $env:RUNNER_TEMP ('MorseCQ CRT refusal ' + [guid]::NewGuid().ToString('N'))
$previousIdentity = $env:MORSECQ_WINDOWS_CERT_SHA1
New-Item -ItemType Directory -Path $temporary | Out-Null
try {
  $damaged = Join-Path $temporary 'msvcp140.dll'
  $bytes = [IO.File]::ReadAllBytes($original)
  if ($bytes.Length -lt 4096) { throw 'Unexpectedly small Microsoft runtime fixture' }
  # Alter hashed code bytes, not an unauthenticated certificate padding region.
  $bytes[4095] = $bytes[4095] -bxor 1
  [IO.File]::WriteAllBytes($damaged, $bytes)
  if ((Get-AuthenticodeSignature -LiteralPath $damaged).Status -eq 'Valid') {
    throw 'Tampered runtime fixture unexpectedly retained a valid signature'
  }
  # This is a nonexistent public thumbprint fixture, never a new credential.
  $env:MORSECQ_WINDOWS_CERT_SHA1 = '0000000000000000000000000000000000000000'
  function Get-Command { throw 'Signing tool lookup must never be reached for damaged CRTs' }
  # PowerShell unwraps a singleton pipeline; both public input forms must
  # still reach CRT refusal under StrictMode, never a missing Count property.
  foreach ($inputPathFixture in @($damaged, $temporary)) {
    $refused = $false
    try {
      & (Join-Path $PSScriptRoot 'sign_windows.ps1') -InputPath $inputPathFixture
    } catch {
      if ($_.Exception.Message -notlike 'MSVC runtime must retain a trusted Microsoft signature*') { throw }
      $refused = $true
    }
    if (-not $refused) { throw 'Damaged CRT reached signing without the required refusal' }
  }
  Write-Host 'Real tampered Microsoft CRT rejected before owner signing-tool lookup.'
} finally {
  $env:MORSECQ_WINDOWS_CERT_SHA1 = $previousIdentity
  Remove-Item -LiteralPath $temporary -Recurse -Force
}
