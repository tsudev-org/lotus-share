#!/usr/bin/env bash
# lotus-share: ghi khóa API App Store Connect (.p8, từ secret APPLE_ASC_KEY_P8_BASE64) ra tệp quyền 600, in đường dẫn.
# Dùng cho `xcrun notarytool` (macOS) và `xcodebuild -authenticationKeyPath` (iOS).
set -euo pipefail
: "${RUNNER_TEMP:?chỉ chạy trên CI}" "${APPLE_ASC_KEY_ID:?}" "${APPLE_ASC_KEY_P8_BASE64:?thiếu secret APPLE_ASC_KEY_P8_BASE64}"
p8="$RUNNER_TEMP/AuthKey_${APPLE_ASC_KEY_ID}.p8"
(umask 077; printf '%s' "$APPLE_ASC_KEY_P8_BASE64" | base64 --decode > "$p8")
grep -q 'BEGIN PRIVATE KEY' "$p8" || { echo "::error::APPLE_ASC_KEY_P8_BASE64 không phải khóa .p8"; exit 1; }
echo "$p8"
