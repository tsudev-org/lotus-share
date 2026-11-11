# PHIẾU BÀN GIAO - Kết phiên đổi tên Lotus Share

- **Mã phiếu**: 20261112-03
- **Từ**: phiên tsudev-lotus-0e (12/11/2026) - **Đến**: phiên kế tiếp của repo `tsudev-org/lotus-share`
- **Trạng thái**: MỞ (bước 1 - deploy website - XONG 12/11/2026)
- Phiếu `20261111-04` (kết phiên trước): các mục đã xong hoặc chuyển vào STATE.md -> coi như ĐÓNG.

## 1. Đã làm

PR #17 (bảo mật yêu thích mTLS, rustix), #18 (chuẩn hóa tsudev), #19 (PIN CSPRNG), #21 (Lotus Share: tên, định danh,
logo, bảng màu, đổi tên repo), #22 (trang Ủng hộ). Chi tiết: `logs/STATE.md`.

## 2. Bước tiếp theo CỤ THỂ (theo thứ tự)

1. Deploy website - xem mục CHẶN đầu hàng đợi STATE.md (wrangler đang ở tài khoản Cloudflare khác; KHÔNG chạy
   `wrangler login` trên cấu hình chung). Kiểm sau deploy: `curl -s https://lotus.tsudev.com/ | grep -o '<title>[^<]*'`
   ra "Lotus Share | tsudev"; `/ung-ho/` trả 200; `curl -s https://lotus.tsudev.com/ung-ho/vietqr-vib.svg | sha256sum`
   = `7209698f1393857607ec7bea95b06349ca8ce332d6fb0c9f1774d6beab4cecae`.
2. Phát hành `v1.18.2-lotus.3` (chủ dự án gắn nhãn) -> kiểm tệp `lotus-share-*` trên trang Tải về.
3. Đổi thư mục máy sang `~/projects/lotus-share` (chủ dự án, khi đóng mọi phiên ở đây).

## 3. Cảnh báo

- KHÔNG tạo repo nào tên `tsudev-lotus` (trong org hay tài khoản): sẽ cắt chuyển hướng của repo cũ.
- Keystore APK: alias trong tệp vẫn là `tsudev-lotus` (`release-lotus.yml` có chú thích) - không đổi.
- Logo nguồn chỉ 466 px: icon 1024 được phóng to; có bản lớn hơn/vector thì thay `support/brand/lotus-share/logo-source.png`
  và chạy lại 3 công cụ (xem `support/brand/README.md`).
- Đổi tên tự động từng biến câu "...của tsudev-lotus:" thành `lotus-share:` (đã sửa 7 chỗ) - rà lại nếu thấy slug trong văn.

## 4. Cổng kiểm

- [x] check-standards ĐẠT; flutter analyze 0 lỗi, test 100/100; cargo test lõi + CLI 41/41; i18n ĐẠT; website check-dist,
  a11y (9 trang x 2 chế độ), theme 0 lỗi; build thử đủ nền tảng xanh.

## 5. Kết quả xử lý

-
