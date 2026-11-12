#!/usr/bin/env bash
# lotus-share: đặt secret + biến SignPath cho workflow phát hành (chủ dự án tự chạy, cần quyền admin repo).
# Chạy SAU khi SignPath Foundation duyệt đơn (docs/vi/HUONG-DAN-KY-MA.md, phần A, bước A6).
#   ./tools/dat-bien-signpath.sh
# Token API nhập ẩn (không hiện, không vào lịch sử shell). Không lưu token ra tệp.
set -euo pipefail
R="tsudev-org/lotus-share"

hoi() {  # hoi <tên biến> <mô tả> <mẫu regex>
  local v
  read -r -p "$2: " v
  [[ $v =~ $3 ]] || { echo "Giá trị không đúng dạng ($3)"; exit 1; }
  gh variable set "$1" -R "$R" --body "$v"
}

echo "Lấy các giá trị trong SignPath: Organization ID ở trang Organization > Settings; slug ở trang Project."
hoi SIGNPATH_ORGANIZATION_ID "Organization ID (dạng UUID)" '^[0-9a-fA-F-]{36}$'
hoi SIGNPATH_PROJECT_SLUG "Project slug (vd lotus-share)" '^[A-Za-z0-9._-]+$'
hoi SIGNPATH_POLICY_SLUG "Signing policy slug (vd release-signing)" '^[A-Za-z0-9._-]+$'

read -r -s -p "API token của người dùng CI (quyền Submitter, nhập ẩn): " t; echo
[ -n "$t" ] || { echo "Token rỗng"; exit 1; }
printf '%s' "$t" | gh secret set SIGNPATH_API_TOKEN -R "$R"
unset t

gh variable list -R "$R" | grep SIGNPATH_ || true
gh secret list -R "$R" | grep SIGNPATH_ || true
echo "Xong. Báo phiên agent để tích hợp bước ký vào release-lotus.yml (docs/vi/KE-HOACH-KY-MA-12-2026.md mục 1.5)."
