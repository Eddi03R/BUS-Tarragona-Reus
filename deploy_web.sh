#!/usr/bin/env bash
# deploy_web.sh - ErasBus Tarragona (versione macOS/Linux di deploy_web.ps1)
# Cloudflare Pages serve dal branch gh-pages (file pre-buildati).
# bump versione -> build -> push master -> push gh-pages.
set -euo pipefail
cd "$(dirname "$0")"
abort() { echo "DEPLOY FALLITO: $1" >&2; exit 1; }

[ "$(git rev-parse --abbrev-ref HEAD)" = "master" ] || abort "Esegui da master"
[ -z "$(git status --porcelain)" ] || abort "File non committati su master"

# 1. Bump versione
cur=$(grep -E '^version:' pubspec.yaml | head -1)
[[ $cur =~ ([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+) ]] || abort "versione non trovata in pubspec.yaml"
semver=${BASH_REMATCH[1]}; build=$((BASH_REMATCH[2] + 1))
sed -i.bak -E "s/^version:.*/version: $semver+$build/" pubspec.yaml && rm pubspec.yaml.bak
printf "const String kAppVersion = 'v%s (%s)';\n" "$semver" "$build" > lib/app_version.dart
echo "Versione: v$semver ($build)"

# 2. Build
flutter pub get
flutter build web --release || abort "flutter build web fallita"

# 3. Commit bump + push master
git add pubspec.yaml lib/app_version.dart
git commit -m "chore: bump versione v$semver+$build"
git push origin master || abort "push master fallito"

# 4. Copia build fuori dal repo
tmp=$(mktemp -d)
cp -R build/web/. "$tmp"
[ "$(find "$tmp" -type f | wc -l)" -ge 10 ] || abort "copia build incompleta"

# 5. gh-pages: sostituisci contenuto
git fetch origin gh-pages
git checkout gh-pages
[ "$(git rev-parse --abbrev-ref HEAD)" = "gh-pages" ] || abort "checkout gh-pages fallito"
git rm -rf --quiet . || true
git clean -fdx --quiet
cp -R "$tmp"/. .
rm -rf "$tmp"
git add -A
git commit -m "deploy: v$semver+$build ($(date '+%Y-%m-%d %H:%M'))"
git push origin gh-pages || abort "push gh-pages fallito"

git checkout master
echo "Deploy completato! v$semver ($build) - Cloudflare aggiorna in ~1-2 min."
