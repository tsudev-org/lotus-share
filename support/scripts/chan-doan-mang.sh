#!/usr/bin/env bash
# Lotus Share - chẩn đoán "không thấy thiết bị" trên Linux. Không gửi gì ra Internet.
# Dùng: bash chan-doan-mang.sh [--sua] [--cong 53420]
#   --sua   mở cổng trên tường lửa đang bật (ufw / firewalld), cần sudo
set -u

CONG=53420
SUA=0
while [ $# -gt 0 ]; do
  case "$1" in
    --sua) SUA=1 ;;
    --cong) shift; CONG="${1:-}" ;;
    -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
    *) echo "Tham số không hợp lệ: $1" >&2; exit 2 ;;
  esac
  shift
done
case "$CONG" in ''|*[!0-9]*) echo "Cổng không hợp lệ: $CONG" >&2; exit 2 ;; esac

LOI=0
ok()   { printf '  [ĐẠT] %s\n' "$*"; }
canh() { printf '  [CẢNH BÁO] %s\n' "$*"; }
loi()  { printf '  [LỖI] %s\n' "$*"; LOI=$((LOI + 1)); }
muc()  { printf '\n== %s ==\n' "$*"; }

muc "1. Ứng dụng và cổng $CONG"
if pgrep -x lotus_share >/dev/null 2>&1; then ok "Lotus Share đang chạy"; else canh "Lotus Share chưa chạy - mở ứng dụng rồi chạy lại công cụ"; fi
if command -v ss >/dev/null 2>&1; then
  GIU=$(ss -H -lntup "( sport = :$CONG )" 2>/dev/null)
  if [ -z "$GIU" ]; then
    canh "Không tiến trình nào nghe cổng $CONG"
  else
    printf '%s\n' "$GIU" | sed 's/^/    /'
    if printf '%s' "$GIU" | grep -qi 'users:' && ! printf '%s' "$GIU" | grep -qi 'lotus_share'; then
      loi "Cổng $CONG đang bị tiến trình khác giữ - tắt tiến trình đó rồi mở lại Lotus Share"
    fi
  fi
fi

muc "2. Tường lửa"
CAN_SUA=""
if command -v ufw >/dev/null 2>&1; then
  TT=$(LC_ALL=C sudo -n ufw status 2>/dev/null || true)
  if [ -z "$TT" ]; then
    canh "Có ufw - cần quyền quản trị để đọc trạng thái (chạy lại với --sua để kiểm và sửa)"
    CAN_SUA="ufw"
  elif printf '%s' "$TT" | grep -q 'Status: active'; then
    if printf '%s' "$TT" | grep -Eq "^$CONG(/udp)?[[:space:]].*ALLOW" && printf '%s' "$TT" | grep -Eq "^$CONG(/tcp)?[[:space:]].*ALLOW"; then
      ok "ufw đang bật và đã cho phép cổng $CONG"
    else
      loi "ufw đang bật nhưng CHƯA cho phép cổng $CONG (TCP + UDP) - thiết bị khác không thấy máy này"
      CAN_SUA="ufw"
    fi
  else
    ok "ufw đang tắt"
  fi
fi
if command -v firewall-cmd >/dev/null 2>&1 && firewall-cmd --state >/dev/null 2>&1; then
  if firewall-cmd --query-port="$CONG/tcp" >/dev/null 2>&1 && firewall-cmd --query-port="$CONG/udp" >/dev/null 2>&1; then
    ok "firewalld đang bật và đã cho phép cổng $CONG"
  else
    loi "firewalld đang bật nhưng CHƯA cho phép cổng $CONG (TCP + UDP) - thiết bị khác không thấy máy này"
    CAN_SUA="$CAN_SUA firewalld"
  fi
fi
[ -z "$CAN_SUA" ] && ! command -v ufw >/dev/null 2>&1 && ! command -v firewall-cmd >/dev/null 2>&1 && ok "Không thấy ufw/firewalld"

muc "3. Card mạng IPv4"
ip -4 -o addr show scope global 2>/dev/null | while read -r _ ten _ dc _; do
  case "$ten" in
    docker*|br-*|virbr*|veth*|vmnet*|vboxnet*|tailscale*|zt*|tun*|wg*) printf '    %-16s %-20s (card ảo/VPN)\n' "$ten" "$dc" ;;
    *) printf '    %-16s %-20s\n' "$ten" "$dc" ;;
  esac
done
MAC_DINH=$(ip -4 route show default 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}')
case "$MAC_DINH" in
  tailscale*|zt*|tun*|wg*) canh "Đường mặc định đi qua VPN ($MAC_DINH) - tắt VPN nếu không thấy thiết bị" ;;
  '') canh "Không có đường mặc định (chưa kết nối mạng?)" ;;
  *) ok "Mạng chính: $MAC_DINH" ;;
esac

muc "4. Thiết bị Lotus Share trong mạng chính"
if command -v curl >/dev/null 2>&1 && [ -n "$MAC_DINH" ]; then
  MANG=$(ip -4 -o addr show dev "$MAC_DINH" scope global | awk '{print $4}' | head -n1)
  CUA_MINH=${MANG%/*}
  TIEN_TO=${CUA_MINH%.*}
  echo "    Quét $TIEN_TO.0/24 cổng $CONG (khoảng 10 giây)..."
  for i in $(seq 1 254); do
    [ "$TIEN_TO.$i" = "$CUA_MINH" ] && continue
    (
      for giao_thuc in https http; do
        TRA=$(curl -sk --max-time 2 "$giao_thuc://$TIEN_TO.$i:$CONG/api/lotus/v2/info" 2>/dev/null)
        if [ -n "$TRA" ]; then
          TEN=$(printf '%s' "$TRA" | sed -n 's/.*"alias":"\([^"]*\)".*/\1/p')
          printf '    %-16s %s\n' "$TIEN_TO.$i" "${TEN:-(không rõ tên)}"
          break
        fi
      done
    ) &
    [ $((i % 64)) -eq 0 ] && wait
  done
  wait
  HANG_XOM=$(ip neigh show dev "$MAC_DINH" 2>/dev/null | grep -c 'REACHABLE\|STALE\|DELAY')
  echo "    Hàng xóm ARP: $HANG_XOM (0-1 khi có nhiều máy cùng Wi-Fi: mạng đang cách ly thiết bị)"
else
  canh "Thiếu curl - bỏ qua bước quét"
fi

if [ "$SUA" -eq 1 ] && [ -n "$CAN_SUA" ]; then
  muc "5. Sửa tường lửa (cần mật khẩu quản trị)"
  case "$CAN_SUA" in *ufw*)
    if LC_ALL=C sudo ufw status | grep -q 'Status: active'; then
      sudo ufw allow "$CONG/tcp" comment 'Lotus Share' && sudo ufw allow "$CONG/udp" comment 'Lotus Share' && ok "Đã mở cổng $CONG trên ufw"
    else
      ok "ufw đang tắt - không cần sửa"
    fi ;;
  esac
  case "$CAN_SUA" in *firewalld*)
    sudo firewall-cmd --permanent --add-port="$CONG/tcp" --add-port="$CONG/udp" && sudo firewall-cmd --reload && ok "Đã mở cổng $CONG trên firewalld" ;;
  esac
elif [ -n "$CAN_SUA" ]; then
  echo
  echo "Chạy lại với --sua để mở cổng $CONG (hoặc trong ứng dụng: Cài đặt > Khắc phục sự cố > Sửa lỗi tự động)."
fi

echo
[ "$LOI" -eq 0 ] && echo "Không phát hiện lỗi trên máy này." || echo "Phát hiện $LOI lỗi."
