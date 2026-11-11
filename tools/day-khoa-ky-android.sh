#!/usr/bin/env bash
# lotus-share: đẩy khóa ký Android lên GitHub Secrets của repo (chủ dự án tự chạy, cần quyền admin repo).
# Khóa nằm NGOÀI repo: ~/.config/lotus-share/keys/ (0600). Không bao giờ commit khóa.
#   ./tools/day-khoa-ky-android.sh
set -euo pipefail
K="${LOTUS_SHARE_KEYS:-$HOME/.config/lotus-share/keys}"
R="tsudev-org/lotus-share"
test -f "$K/android-release.jks" && test -f "$K/key.properties"
base64 -w0 "$K/android-release.jks" | gh secret set ANDROID_KEYSTORE_BASE64 -R "$R"
sed -n 's/^storePassword=//p' "$K/key.properties" | tr -d '\n' | gh secret set ANDROID_KEYSTORE_PASSWORD -R "$R"
gh secret list -R "$R"
echo "Xong. Dấu vân tay chứng thư (công bố trên trang Tải về để người dùng đối chiếu):"
keytool -list -v -keystore "$K/android-release.jks" \
  -storepass "$(sed -n 's/^storePassword=//p' "$K/key.properties")" | grep -m1 'SHA256:'
