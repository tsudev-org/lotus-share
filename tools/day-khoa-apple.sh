#!/usr/bin/env bash
# lotus-share: đẩy chứng thư + khóa API Apple lên GitHub Secrets (chủ dự án tự chạy, cần quyền admin repo).
# Chạy SAU phần B của docs/vi/HUONG-DAN-KY-MA.md. Tệp nằm NGOÀI repo, quyền 0600:
#   ~/.config/lotus-share/keys/apple/developer-id.p12   chứng thư "Developer ID Application" (macOS)
#   ~/.config/lotus-share/keys/apple/distribution.p12   chứng thư "Apple Distribution" (iOS)
#   ~/.config/lotus-share/keys/apple/AuthKey_<KEYID>.p8 khóa API App Store Connect
#   ./tools/day-khoa-apple.sh
set -euo pipefail
K="${LOTUS_SHARE_KEYS:-$HOME/.config/lotus-share/keys}/apple"
R="tsudev-org/lotus-share"

for f in developer-id.p12 distribution.p12; do
  test -f "$K/$f" || { echo "Thiếu $K/$f"; exit 1; }
done
mapfile -t p8 < <(find "$K" -maxdepth 1 -name 'AuthKey_*.p8')
[ ${#p8[@]} -eq 1 ] || { echo "Cần đúng 1 tệp AuthKey_<KEYID>.p8 trong $K"; exit 1; }
key_id=$(basename "${p8[0]}" .p8); key_id=${key_id#AuthKey_}

# Quyền tệp: khóa riêng không được để người khác đọc.
for f in "$K"/*.p12 "${p8[@]}"; do
  [ "$(stat -c %a "$f")" = 600 ] || { echo "Đặt quyền 0600 cho $f (chmod 600)"; exit 1; }
done

read -r -p "Team ID (10 ký tự, Membership details): " team
[[ $team =~ ^[A-Z0-9]{10}$ ]] || { echo "Team ID sai dạng"; exit 1; }
read -r -p "Issuer ID của App Store Connect API (UUID): " issuer
[[ $issuer =~ ^[0-9a-f-]{36}$ ]] || { echo "Issuer ID sai dạng"; exit 1; }
read -r -s -p "Mật khẩu của hai tệp .p12 (nhập ẩn, dùng chung một mật khẩu): " pw; echo
[ -n "$pw" ] || { echo "Mật khẩu rỗng"; exit 1; }

# Kiểm mật khẩu mở được .p12 trước khi đẩy.
for f in developer-id.p12 distribution.p12; do
  openssl pkcs12 -in "$K/$f" -passin "pass:$pw" -nokeys -legacy >/dev/null 2>&1 \
    || openssl pkcs12 -in "$K/$f" -passin "pass:$pw" -nokeys >/dev/null \
    || { echo "Không mở được $f bằng mật khẩu đã nhập"; exit 1; }
done

base64 -w0 "$K/developer-id.p12" | gh secret set APPLE_DEVID_P12_BASE64 -R "$R"
base64 -w0 "$K/distribution.p12" | gh secret set APPLE_DIST_P12_BASE64 -R "$R"
printf '%s' "$pw" | gh secret set APPLE_P12_PASSWORD -R "$R"; unset pw
base64 -w0 "${p8[0]}" | gh secret set APPLE_ASC_KEY_P8_BASE64 -R "$R"
gh variable set APPLE_TEAM_ID -R "$R" --body "$team"
gh variable set APPLE_ASC_KEY_ID -R "$R" --body "$key_id"
gh variable set APPLE_ASC_ISSUER_ID -R "$R" --body "$issuer"

gh secret list -R "$R" | grep APPLE_ || true
gh variable list -R "$R" | grep APPLE_ || true
echo "Xong. Báo phiên agent: Team ID = $team (sẽ được ghim trong workflow để kiểm chữ ký)."
