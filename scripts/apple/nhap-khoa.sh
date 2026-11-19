#!/usr/bin/env bash
# lotus-share: nạp chứng thư Apple (.p12, base64) vào một keychain TẠM trên máy chạy macOS của CI.
# Dùng: APPLE_P12_PASSWORD=... nhap-khoa.sh <biến-môi-trường-chứa-p12-base64>...   (vd APPLE_DEVID_P12_BASE64)
# In ra đường dẫn keychain; job phải gọi `xoa-khoa.sh` ở bước `if: always()`.
# CHƯA CHẠY THẬT (chờ Apple Developer Program, docs/vi/APPLE-IOS-MACOS.md mục 4) - build thử trước khi phát hành.
set -euo pipefail
: "${RUNNER_TEMP:?chỉ chạy trên CI}"
# Mật khẩu .p12 đến từ secret của workflow (biến môi trường), không bao giờ viết trong tệp này.
[[ -n "${APPLE_P12_PASSWORD-}" ]] || { echo "::error::Thiếu biến môi trường mật khẩu .p12 (secret của workflow)"; exit 1; }
kc="$RUNNER_TEMP/lotus-ky.keychain-db"
kc_pw="$(openssl rand -hex 24)"
security create-keychain -p "$kc_pw" "$kc"
security set-keychain-settings -lut 3600 "$kc"
security unlock-keychain -p "$kc_pw" "$kc"
for var in "$@"; do
  p12="$RUNNER_TEMP/$var.p12"
  (umask 077; printf '%s' "${!var:?thiếu secret $var}" | base64 --decode > "$p12")
  security import "$p12" -k "$kc" -P "$APPLE_P12_PASSWORD" -T /usr/bin/codesign -T /usr/bin/security -T /usr/bin/xcodebuild
  rm -f "$p12"
done
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$kc_pw" "$kc" >/dev/null
# Đưa keychain tạm lên đầu danh sách tìm kiếm (giữ keychain đăng nhập của máy chạy).
security list-keychains -d user -s "$kc" $(security list-keychains -d user | tr -d '"')
security find-identity -v -p codesigning "$kc"
echo "$kc"
