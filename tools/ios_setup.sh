#!/usr/bin/env bash
# Prepara il progetto iOS (ios/ non è nel repo: lo genera flutter create) e applica
# le impostazioni di ErasBus Tarragona. Va lanciato dalla radice del repo su macOS.
set -euo pipefail

BUNDLE_ID="app.lumelabs.bustarragona"
TEAM_ID="2Z2S5SNBUL"
ADMOB_APP_ID="ca-app-pub-3708488192021794~5959288041"

flutter create --platforms=ios --org app.lumelabs --project-name reus_tarragona_bus .

PBX=ios/Runner.xcodeproj/project.pbxproj
# Bundle ID (prima i test, poi l'app) e versione minima di iOS (richiesta da Firebase).
sed -i '' -E "s/(PRODUCT_BUNDLE_IDENTIFIER = )app\.lumelabs\.[^;.]*\.RunnerTests;/\1${BUNDLE_ID}.RunnerTests;/" "$PBX"
sed -i '' -E "s/(PRODUCT_BUNDLE_IDENTIFIER = )app\.lumelabs\.[^;.]*;/\1${BUNDLE_ID};/" "$PBX"
sed -i '' -E "s/IPHONEOS_DEPLOYMENT_TARGET = [0-9.]+;/IPHONEOS_DEPLOYMENT_TARGET = 15.0;/" "$PBX"
# Solo iPhone: con l'iPad Apple chiederebbe anche gli screenshot dell'iPad.
sed -i '' -E 's/TARGETED_DEVICE_FAMILY = "1,2";/TARGETED_DEVICE_FAMILY = 1;/' "$PBX"
if [ -f ios/Podfile ]; then
  sed -i '' -E "s/^# *platform :ios, .*/platform :ios, '15.0'/" ios/Podfile
fi

# Info.plist
PL=ios/Runner/Info.plist
pb() { /usr/libexec/PlistBuddy -c "$1" "$PL" 2>/dev/null || true; }
pb "Delete :CFBundleDisplayName"
pb "Add :CFBundleDisplayName string 'ErasBus Tarragona'"
pb "Add :GADApplicationIdentifier string ${ADMOB_APP_ID}"
pb "Add :ITSAppUsesNonExemptEncryption bool false"
pb "Add :NSUserTrackingUsageDescription string 'This identifier is used to show you more relevant ads. The app is free to use either way.'"
pb "Add :NSLocationWhenInUseUsageDescription string 'Your location is used to find the nearest bus stops and plan your trip.'"
pb "Add :NSLocationAlwaysAndWhenInUseUsageDescription string 'Your location is used to find the nearest bus stops and plan your trip.'"
pb "Add :CFBundleLocalizations array"
i=0; for l in it en es ca de; do pb "Add :CFBundleLocalizations:$i string $l"; i=$((i+1)); done
pb "Add :SKAdNetworkItems array"
i=0
for id in cstr6suwn9 4fzdc2evr5 2fnua5tdw4 ydx93a7ass 5a6flpkh64 p78axxw29g v72qych5uu ludvb6z3bs cp8zw746q7 3sh42y64q3 c6k4g5qg8m s39g8k73mm 3qy4746246 f38h382jlk hs6bdukanm v4nxqhlyqp wzmmz9fp6w yclnxrl5pm t38b2kh725 7ug5zh24hu gta9lk7p23 vutu7akeur y5ghdn5j9k n6fk4nfna4 v9wttpbfk9 n38lu8286q 47vhws6wlr kbd757ywx3 9t245vhmpl a2p9lx4jpn 22mmun2rn5 4468km3ulz 2u9pt9hc89 8s468mfl3y klf5c3l5u5 ppxm28t8ap 424m5254lk uw77j35x4d 578prtvx9j 4dzt52r2t5 e5fvkxwrpn 8c4e2ghe7u zq492l623r 3rd42ekr43 3qcr597p9d; do
  pb "Add :SKAdNetworkItems:$i dict"
  pb "Add :SKAdNetworkItems:$i:SKAdNetworkIdentifier string ${id}.skadnetwork"
  i=$((i+1))
done

# Icona dell'app: un solo PNG 1024x1024 (Xcode 15+).
ICONSET=ios/Runner/Assets.xcassets/AppIcon.appiconset
rm -rf "$ICONSET"; mkdir -p "$ICONSET"
cp ios_config/AppIcon-1024.png "$ICONSET/icon-1024.png"
cat > "$ICONSET/Contents.json" <<'JSON'
{
  "images": [
    { "filename": "icon-1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
JSON

# GoogleService-Info.plist nel target Runner + firma automatica con il team Apple.
cp ios_config/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
gem install xcodeproj --no-document >/dev/null
TEAM_ID="$TEAM_ID" ruby <<'RUBY'
require 'xcodeproj'
proj = Xcodeproj::Project.open('ios/Runner.xcodeproj')
target = proj.targets.find { |t| t.name == 'Runner' }
group = proj.main_group.find_subpath('Runner', true)
ref = group.new_file('GoogleService-Info.plist')
target.add_resources([ref])
target.build_configurations.each do |c|
  c.build_settings['DEVELOPMENT_TEAM'] = ENV['TEAM_ID']
  c.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
end
proj.save
RUBY
echo "iOS pronto"
