# build_android.ps1 — incrementa version code e builda il release AAB
$flutter = "C:\Users\eddi.raimondi\flutter\bin\flutter.bat"
$pubspec = Join-Path $PSScriptRoot "pubspec.yaml"

$content = Get-Content $pubspec -Raw
if ($content -match 'version:\s+(\d+\.\d+\.\d+)\+(\d+)') {
    $vname = $Matches[1]
    $vcode = [int]$Matches[2] + 1
    $content = $content -replace 'version:\s+\d+\.\d+\.\d+\+\d+', "version: $vname+$vcode"
    Set-Content $pubspec $content -NoNewline
    Write-Host "Version: $vname+$vcode (code $vcode)" -ForegroundColor Green
} else {
    Write-Error "version non trovata in pubspec.yaml"; exit 1
}

Write-Host "Building release AAB..." -ForegroundColor Cyan
& $flutter build appbundle --release
if ($LASTEXITCODE -eq 0) {
    $aab = Join-Path $PSScriptRoot "build\app\outputs\bundle\release\app-release.aab"
    Write-Host "Build OK: $aab" -ForegroundColor Green
} else {
    Write-Error "Build fallita"
}
