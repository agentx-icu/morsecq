param([Parameter(Mandatory=$true)][string]$InputPath)
$ErrorActionPreference = 'Stop'
$identity = $env:MORSECQ_WINDOWS_CERT_SHA1
if (-not $identity) { throw 'distribution requires MORSECQ_WINDOWS_CERT_SHA1' }
$files = if (Test-Path $InputPath -PathType Container) {
  @(Get-ChildItem $InputPath -Recurse -File | Where-Object { $_.Extension -in '.exe', '.dll' })
} else { @(Get-Item $InputPath) }
if ($files.Count -eq 0) { throw 'No PE or installer files to sign' }
# Redistributable CRTs must remain the original signed Microsoft components.
# Refuse damaged/unsigned CRTs before looking up any owner signing tool/key.
foreach ($file in $files) {
  if ($file.Name -match '^(?:msvcp140|vcruntime140|concrt140).*\.dll$') {
    $signature = Get-AuthenticodeSignature -LiteralPath $file.FullName
    if ($signature.Status -ne 'Valid' -or $null -eq $signature.SignerCertificate -or $signature.SignerCertificate.Subject -notmatch '(^|,\s*)O=Microsoft Corporation(,|$)') {
      throw "MSVC runtime must retain a trusted Microsoft signature; refusing owner re-sign: $($file.Name)"
    }
  }
}
$signTool = (Get-Command signtool.exe -ErrorAction Stop).Source
foreach ($file in $files) {
  $signature = Get-AuthenticodeSignature $file.FullName
  $owned = $file.Name -eq 'morsecq.exe' -or $file.Extension -eq '.msi'
  if ($signature.Status -ne 'Valid' -or ($owned -and $signature.SignerCertificate.Thumbprint -ne $identity)) {
    & $signTool sign /sha1 $identity /fd SHA256 /tr https://timestamp.digicert.com /td SHA256 $file.FullName
    if ($LASTEXITCODE -ne 0) { throw "Signing failed: $($file.Name)" }
  }
  & $signTool verify /pa $file.FullName
  if ($LASTEXITCODE -ne 0) { throw "Signature verification failed: $($file.Name)" }
  $signature = Get-AuthenticodeSignature $file.FullName
  if ($signature.Status -ne 'Valid' -or ($owned -and $signature.SignerCertificate.Thumbprint -ne $identity)) {
    throw "Unexpected publisher or untrusted signature: $($file.Name)"
  }
}
