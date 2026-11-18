#!/usr/bin/env bash
# lotus-share: ký "Developer ID Application" + Hardened Runtime, dựng DMG, công chứng (notarize) và staple.
# Dùng: ky-cong-chung-macos.sh "<Lotus Share.app>" <tệp.dmg ra>
# Cần: keychain từ nhap-khoa.sh (APPLE_DEVID_P12_BASE64), APPLE_TEAM_ID, APPLE_ASC_KEY_ID, APPLE_ASC_ISSUER_ID, ASC_P8.
# Dừng nếu TeamIdentifier sau khi ký khác Team ID đã GHIM ở release-lotus.yml (APPLE_TEAM_ID_GHIM) - secret bị tráo.
# CHƯA CHẠY THẬT (chờ Apple Developer Program, docs/vi/APPLE-IOS-MACOS.md mục 4).
set -euo pipefail
app="${1:?đường dẫn .app}"; dmg="${2:?đường dẫn .dmg}"
: "${APPLE_TEAM_ID:?}" "${APPLE_TEAM_ID_GHIM:?}" "${APPLE_ASC_KEY_ID:?}" "${APPLE_ASC_ISSUER_ID:?}" "${ASC_P8:?}"
[[ "$APPLE_TEAM_ID" == "$APPLE_TEAM_ID_GHIM" ]] \
  || { echo "::error::vars.APPLE_TEAM_ID ($APPLE_TEAM_ID) khác Team ID ghim ($APPLE_TEAM_ID_GHIM)"; exit 1; }
id="$(security find-identity -v -p codesigning | sed -n "s/.*\"\(Developer ID Application: .*(${APPLE_TEAM_ID})\)\"/\1/p" | head -1)"
[[ -n "$id" ]] || { echo "::error::Không có chứng thư Developer ID Application của Team $APPLE_TEAM_ID"; exit 1; }
ent="$(cd "$(dirname "$0")/../.." && pwd)/app/macos/Runner/Release.entitlements"
ent_ext="$(cd "$(dirname "$0")/../.." && pwd)/app/macos/ShareExtension/ShareExtension.entitlements"

# Ký từ trong ra ngoài (không dùng --deep cho Developer ID): thư viện, framework, phần mở rộng, rồi ứng dụng.
while IFS= read -r -d '' f; do
  codesign --force --options runtime --timestamp --sign "$id" "$f"
done < <(find "$app/Contents/Frameworks" \( -name '*.dylib' -o -name '*.framework' \) -prune -print0 2>/dev/null)
if [[ -d "$app/Contents/PlugIns" ]]; then
  while IFS= read -r -d '' ext; do
    codesign --force --options runtime --timestamp --entitlements "$ent_ext" --sign "$id" "$ext"
  done < <(find "$app/Contents/PlugIns" -name '*.appex' -prune -print0)
fi
codesign --force --options runtime --timestamp --entitlements "$ent" --sign "$id" "$app"
codesign --verify --deep --strict --verbose=2 "$app"
team="$(codesign -dv "$app" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
[[ "$team" == "$APPLE_TEAM_ID_GHIM" ]] || { echo "::error::TeamIdentifier $team khác Team ID ghim"; exit 1; }

st="$(mktemp -d)"; cp -R "$app" "$st/"; ln -s /Applications "$st/Applications"
hdiutil create -volname "Lotus Share" -srcfolder "$st" -ov -format UDZO "$dmg"
codesign --force --timestamp --sign "$id" "$dmg"
xcrun notarytool submit "$dmg" --key "$ASC_P8" --key-id "$APPLE_ASC_KEY_ID" --issuer "$APPLE_ASC_ISSUER_ID" \
  --wait --timeout 60m --output-format json | tee "$RUNNER_TEMP/notary.json"
python3 -I -c 'import json,sys; s=json.load(open(sys.argv[1]))["status"]; sys.exit(0 if s=="Accepted" else f"công chứng: {s}")' \
  "$RUNNER_TEMP/notary.json"
xcrun stapler staple "$dmg"
xcrun stapler validate "$dmg"
spctl -a -vvv -t install "$dmg" 2>&1 | tee /dev/stderr | grep -q 'source=Notarized Developer ID'
