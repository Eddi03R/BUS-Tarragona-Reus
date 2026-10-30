# deploy_web.ps1 - ErasBus Tarragona
# Cloudflare Pages serve da branch gh-pages (file pre-buildati).
# Questo script: bump versione -> build -> push su gh-pages -> Production aggiornato.

$flutter  = "C:\Users\eddi.raimondi\flutter\bin\flutter.bat"
$project  = $PSScriptRoot

function Abort { param([string]$msg) Write-Error "DEPLOY FALLITO: $msg"; exit 1 }

# -- 0. Verifica branch master e working tree pulito -------------------------
$branch = git -C $project rev-parse --abbrev-ref HEAD
if ($branch -ne "master") { Abort "Esegui da master (branch attuale: $branch)" }
$dirty = git -C $project status --porcelain
if ($dirty) { Abort "Ci sono file non committati su master:`n$dirty`nCommittali prima di deployare." }

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

# -- 2. Build web release -----------------------------------------------------
Push-Location $project
& $flutter build web --release
Pop-Location
if ($LASTEXITCODE -ne 0) { Abort "flutter build web fallita" }

# -- 3. Commit bump versione su master ----------------------------------------
git -C $project add pubspec.yaml "lib\app_version.dart"
git -C $project commit -m "chore: bump versione v$semver+$build"
git -C $project push origin master
if ($LASTEXITCODE -ne 0) { Abort "push master fallito" }

# -- 4. Copia build in Documents (evita AV su TEMP) ---------------------------
$tmpDir = "C:\Users\eddi.raimondi\Documents\erasbus_deploy_$(Get-Random)"
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
Copy-Item -Path (Join-Path $project "build\web\*") -Destination $tmpDir -Recurse -Force
$count = (Get-ChildItem $tmpDir -Recurse -File).Count
if ($count -lt 10) { Abort "Copia build incompleta ($count file)" }

# -- 5. Checkout gh-pages e rimpiazza contenuto --------------------------------
git -C $project fetch origin gh-pages
git -C $project checkout gh-pages
if ((git -C $project rev-parse --abbrev-ref HEAD) -ne "gh-pages") { Abort "checkout gh-pages fallito" }

git -C $project rm -rf --quiet .
git -C $project clean -fdx --quiet
Copy-Item -Path "$tmpDir\*" -Destination $project -Recurse -Force
Remove-Item $tmpDir -Recurse -Force

# -- 6. Stage tutti i file web -----------------------------------------------
git -C $project add -A
git -C $project commit -m "deploy: v$semver+$build ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
if ($LASTEXITCODE -ne 0) { Abort "commit gh-pages fallito" }

git -C $project push origin gh-pages
if ($LASTEXITCODE -ne 0) { Abort "push gh-pages fallito" }

# -- 7. Torna su master -------------------------------------------------------
git -C $project checkout master

Write-Host ""
Write-Host "Deploy completato! v$semver ($build)" -ForegroundColor Green
Write-Host "Cloudflare Pages aggiornerà bustarragonareus.pages.dev in ~1-2 min." -ForegroundColor Cyan
