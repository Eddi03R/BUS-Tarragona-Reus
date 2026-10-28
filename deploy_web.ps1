$flutter = "C:\Users\eddi.raimondi\flutter\bin\flutter.bat"
$project = $PSScriptRoot
$tmpBranch = "gh-pages"

Write-Host "Building Flutter web..." -ForegroundColor Cyan
& $flutter build web --release
if ($LASTEXITCODE -ne 0) { Write-Error "Build web fallita"; exit 1 }

# Copia il build in una directory TEMP esterna al progetto, prima di qualsiasi operazione git
$tmpDir = Join-Path $env:TEMP "erasbus_web_deploy_$(Get-Random)"
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
Copy-Item -Path (Join-Path $project "build\web\*") -Destination $tmpDir -Recurse -Force
Write-Host "Build salvato in temp: $tmpDir" -ForegroundColor DarkGray

Write-Host "Deploying to gh-pages..." -ForegroundColor Cyan

$current = git -C $project rev-parse --abbrev-ref HEAD
$hasChanges = (git -C $project status --porcelain) -ne $null
if ($hasChanges) { git -C $project stash }

git -C $project fetch origin $tmpBranch
git -C $project checkout $tmpBranch

# Rimuovi tutto tranne .git e privacy.html (il deploy_web.ps1 e' untracked su master, non esiste su gh-pages)
Get-ChildItem -Path $project -Exclude ".git", "privacy.html", "deploy_web.ps1" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Copia dalla directory temp
Copy-Item -Path "$tmpDir\*" -Destination $project -Recurse -Force
if ($LASTEXITCODE -ne 0) { Write-Error "Copia dal temp fallita!"; exit 1 }

# Pulizia temp
Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue

git -C $project add -A
git -C $project commit -m "deploy: web build $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git -C $project push origin $tmpBranch

git -C $project checkout $current
if ($hasChanges) { git -C $project stash pop 2>$null }

# Ricrea deploy_web.ps1 su master perche' il remove-item lo ha eliminato
# (lo script si trova nella cartella del progetto che viene pulita durante il checkout gh-pages)
Write-Host "Deploy completato!" -ForegroundColor Green
