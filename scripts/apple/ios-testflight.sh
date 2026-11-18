#!/usr/bin/env bash
# lotus-share: lưu trữ (archive) bản iOS ký "Apple Distribution" và tải thẳng lên App Store Connect (TestFlight).
# IPA KHÔNG đưa vào GitHub Release: người dùng iOS cài qua TestFlight/App Store (KE-HOACH-KY-MA mục 2.2.4).
# Cần: keychain từ nhap-khoa.sh (APPLE_DIST_P12_BASE64), APPLE_TEAM_ID(+_GHIM), APPLE_ASC_KEY_ID, APPLE_ASC_ISSUER_ID,
# ASC_P8. Hồ sơ cấp phép (provisioning profile) do xcodebuild tự tạo qua khóa API (-allowProvisioningUpdates) - khóa
# API cần quyền Admin, hoặc App Manager có "Access to Certificates, Identifiers & Profiles".
# CHƯA CHẠY THẬT (chờ Apple Developer Program, docs/vi/APPLE-IOS-MACOS.md mục 4).
set -euo pipefail
: "${APPLE_TEAM_ID:?}" "${APPLE_TEAM_ID_GHIM:?}" "${APPLE_ASC_KEY_ID:?}" "${APPLE_ASC_ISSUER_ID:?}" "${ASC_P8:?}" "${RUNNER_TEMP:?}"
[[ "$APPLE_TEAM_ID" == "$APPLE_TEAM_ID_GHIM" ]] || { echo "::error::Team ID khác bản ghim"; exit 1; }
goc="$(cd "$(dirname "$0")/../.." && pwd)"
auth=(-allowProvisioningUpdates -authenticationKeyPath "$ASC_P8" -authenticationKeyID "$APPLE_ASC_KEY_ID"
      -authenticationKeyIssuerID "$APPLE_ASC_ISSUER_ID")
cd "$goc/app"
flutter build ios --release --config-only
archive="$RUNNER_TEMP/LotusShare.xcarchive"
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -destination 'generic/platform=iOS' \
  -archivePath "$archive" DEVELOPMENT_TEAM="$APPLE_TEAM_ID" CODE_SIGN_STYLE=Automatic "${auth[@]}" archive
opts="$RUNNER_TEMP/ExportOptions.plist"
sed "s/__TEAM_ID__/$APPLE_TEAM_ID/" ios/ExportOptions-AppStore.plist > "$opts"
# destination=upload trong ExportOptions: xuất xong tải luôn lên App Store Connect.
xcodebuild -exportArchive -archivePath "$archive" -exportOptionsPlist "$opts" -exportPath "$RUNNER_TEMP/ipa" "${auth[@]}"
