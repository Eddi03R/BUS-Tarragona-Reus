$flutter = "C:\Users\eddi.raimondi\flutter\bin\flutter.bat"
$project = $PSScriptRoot
$tmpBranch = "gh-pages"

function Abort {
    param([string]$msg, [string]$tmpDir, [bool]$hasChanges, [string]$current)
    Write-Host ""
    Write-Error "DEPLOY FALLITO: $msg"
    if ($tmpDir -and (Test-Path $tmpDir)) {
        Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    $nowOn = git -C $project rev-parse --abbrev-ref HEAD 2>$null
    if ($nowOn -ne $current) {
        Write-Host "Ritorno su $current..."
        git -C $project checkout $current 2>$null
    }
    if ($hasChanges) { git -C $project stash pop 2>$null }
    exit 1
}

# -- 0. Auto-bump versione -----------------------------------------------------
$pubspec = Get-Content (Join-Path $project "pubspec.yaml") -Raw
if ($pubspec -match 'version:\s+(\d+\.\d+\.\d+)\+(\d+)') {
    $semver = $Matches[1]
    $build  = [int]$Matches[2] + 1
    $pubspec = $pubspec -replace "version:\s+\d+\.\d+\.\d+\+\d+", "version: $semver+$build"
    Set-Content (Join-Path $project "pubspec.yaml") $pubspec -Encoding UTF8 -NoNewline
    Set-Content (Join-Path $project "lib\app_version.dart") "const String kAppVersion = 'v$semver ($build)';`n" -Encoding UTF8 -NoNewline
    Write-Host "Versione aggiornata: v$semver ($build)"
}

# -- 1. Build ------------------------------------------------------------------
& $flutter build web --release
if ($LASTEXITCODE -ne 0) { Write-Error "Build web fallita"; exit 1 }

# -- 2. Copia build in Documents (non in TEMP: AV blocca .js in TEMP) ---------
$tmpDir = "C:\Users\eddi.raimondi\Documents\erasbus_deploy_$(Get-Random)"
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
Copy-Item -Path (Join-Path $project "build\web\*") -Destination $tmpDir -Recurse -Force
$copiedFiles = (Get-ChildItem $tmpDir -Recurse -File).Count
if ($copiedFiles -lt 10) { Abort "Copia build incompleta ($copiedFiles file)" $tmpDir $false "" }
Write-Host "Build salvato: $copiedFiles file in $tmpDir"

# -- 3. Stash modifiche in corso (solo file tracciati) -------------------------
$current = git -C $project rev-parse --abbrev-ref HEAD
if ($LASTEXITCODE -ne 0) { Abort "impossibile leggere il branch" $tmpDir $false "" }

$hasChanges = (git -C $project status --porcelain --untracked-files=no) -ne $null
if ($hasChanges) {
    git -C $project stash
    if ($LASTEXITCODE -ne 0) { Abort "git stash fallito" $tmpDir $false $current }
}

# -- 4. Checkout gh-pages ------------------------------------------------------
git -C $project fetch origin $tmpBranch
if ($LASTEXITCODE -ne 0) { Abort "git fetch fallito" $tmpDir $hasChanges $current }

git -C $project checkout $tmpBranch
if ($LASTEXITCODE -ne 0) { Abort "git checkout $tmpBranch fallito" $tmpDir $hasChanges $current }

$activeBranch = git -C $project rev-parse --abbrev-ref HEAD
if ($activeBranch -ne $tmpBranch) {
    Abort "branch attivo '$activeBranch' != '$tmpBranch' - interrotto per sicurezza" $tmpDir $hasChanges $current
}

# -- 5. Sostituisci contenuto: rimuovi tracciati, copia nuovo build ------------
git -C $project rm -rf --quiet .
Copy-Item -Path "$tmpDir\*" -Destination $project -Recurse -Force
Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue

# -- 6. Commit e push su gh-pages ----------------------------------------------
git -C $project add -A
git -C $project commit -m "deploy: web build $(Get-Date -Format 'yyyy-MM-dd HH:mm') [v$semver+$build]"
if ($LASTEXITCODE -ne 0) { Abort "git commit fallito (nulla da committare?)" "" $hasChanges $current }

git -C $project push origin $tmpBranch
if ($LASTEXITCODE -ne 0) { Abort "git push fallito" "" $hasChanges $current }

# -- 7. Torna su master --------------------------------------------------------
git -C $project checkout $current
if ($LASTEXITCODE -ne 0) { Write-Warning "git checkout $current fallito - verifica manualmente il branch" }

if ($hasChanges) {
    git -C $project stash pop
    if ($LASTEXITCODE -ne 0) { Write-Warning "git stash pop con conflitti - risolvi manualmente" }
}

Write-Host ""
Write-Host "Deploy completato!" -ForegroundColor Green
