# PHIẾU BÀN GIAO - Kết phiên sửa khám phá thiết bị, phát hành lotus.5

- **Mã phiếu**: 20261112-04
- **Từ**: phiên lotus-share-d7 (12/11/2026) - **Đến**: phiên kế tiếp của repo `tsudev-org/lotus-share`
- **Trạng thái**: MỞ (2 việc ở mục 2)

## 1. Đã làm

- PR #35: sửa "điện thoại và máy tính không thấy nhau" (6 nguyên nhân, `docs/vi/KHAM-PHA-THIET-BI.md`): broadcast song
  song multicast (lõi Rust), MulticastLock Android, xếp cuối card ảo/VPN, bộ cài Inno tạo/xóa quy tắc tường lửa + gỡ
  `tsudev-lotus` cũ + xóa khóa tự khởi động, công cụ `support/scripts/chan-doan-mang.ps1`, bộ cài `-setup.exe`,
  website "Tải nhanh" + `/tai/<nen-tang>` (`_redirects`) + mục "Không thấy thiết bị?". PR #36: STATE.
- Phát hành `v1.18.2-lotus.5` (đã Publish, Latest), website deploy lại, Scoop/Homebrew lên lotus.5.
- Phiếu đồng bộ cả hệ: `~/projects/logs/handover/20261112-03_yeu-cau-bo-cai-chuan-tuong-lua-chan-doan-mang.md`.

## 2. Bước tiếp theo CỤ THỂ

1. Hỏi chủ dự án đã duyệt run linux-packages 43206677590 chưa (STATE mục đầu). Duyệt rồi: đo
   `curl -s https://pkg.tsudev.com/apt/dists/stable/main/binary-amd64/Packages | grep -A1 'Package: lotus-share'`
   có `Version: 1.18.2-5`.
2. Thử thật với 2 thiết bị (STATE): máy phát triển này còn `C:\Program Files\tsudev-lotus` (bản cũ) + LocalSend 1.17,
   Wi-Fi đặt Công cộng - cài `lotus.tsudev.com/tai/windows` (chọn cài cho mọi người dùng, giữ dấu chọn tường lửa), kiểm
   bản cũ bị gỡ, `Get-NetFirewallApplicationFilter -Program 'C:\Program Files\Lotus Share\lotus_share.exe' |
   Get-NetFirewallRule` có 2 quy tắc Allow; mở Lotus Share trên điện thoại Android (APK lotus.5) cùng Wi-Fi, thấy nhau
   hai chiều. Không thấy: chạy "Lotus Share - Sửa lỗi kết nối", ghi kết quả vào STATE.

## 3. Cảnh báo

- Bộ cài chỉ tạo quy tắc tường lửa khi cài với quyền quản trị (cài cho mọi người dùng); cài riêng người dùng thì công cụ
  chẩn đoán sửa (tự xin UAC).
- Tệp `.iss` phải giữ UTF-8 CÓ BOM (chữ Việt trong `[CustomMessages]`).
- `_redirects` chỉ nhận đích `github.com/tsudev-org/lotus-share/releases/download/...` (`website/scripts/tao-chuyen-huong.mjs`).
  Sau MỖI bản phát hành phải deploy lại website để `/tai/*` trỏ bản mới.
- Gói `.zip` Windows giữ tên không `-setup` vì Scoop dùng.
