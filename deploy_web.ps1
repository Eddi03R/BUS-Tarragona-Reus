# deploy_web.ps1 - ErasBus Tarragona
# Il sito e' su Cloudflare Pages (bustarragonareus.pages.dev).
# Cloudflare Pages fa la build da master automaticamente ad ogni push.
# Questo script fa solo il bump di versione + push a master.

$project = $PSScriptRoot

# -- 1. Auto-bump versione in pubspec.yaml e lib/app_version.dart --------------
$pubspec = Get-Content (Join-Path $project "pubspec.yaml") -Raw
if ($pubspec -match 'version:\s+(\d+\.\d+\.\d+)\+(\d+)') {
    $semver = $Matches[1]
    $build  = [int]$Matches[2] + 1
    $pubspec = $pubspec -replace "version:\s+\d+\.\d+\.\d+\+\d+", "version: $semver+$build"
    Set-Content (Join-Path $project "pubspec.yaml") $pubspec -Encoding UTF8 -NoNewline
    Set-Content (Join-Path $project "lib\app_version.dart") "const String kAppVersion = 'v$semver ($build)';`n" -Encoding UTF8 -NoNewline
    Write-Host "Versione: v$semver ($build)"
}

# -- 2. Commit bump versione ---------------------------------------------------
$hasChanges = (git -C $project status --porcelain --untracked-files=no) -ne $null
if ($hasChanges) {
    git -C $project add pubspec.yaml "lib\app_version.dart"
    git -C $project commit -m "chore: bump versione v$semver+$build"
    if ($LASTEXITCODE -ne 0) { Write-Error "git commit fallito"; exit 1 }
}

# -- 3. Push master -> Cloudflare Pages fa la build automaticamente ------------
git -C $project push origin master
if ($LASTEXITCODE -ne 0) { Write-Error "git push fallito"; exit 1 }

Write-Host ""
Write-Host "Push completato! Cloudflare Pages inizia la build ora." -ForegroundColor Green
Write-Host "Controlla lo stato su: https://dash.cloudflare.com (Pages -> BUS-Tarragona-Reus)" -ForegroundColor Cyan
