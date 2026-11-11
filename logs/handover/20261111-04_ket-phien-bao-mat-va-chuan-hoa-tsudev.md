# PHIẾU BÀN GIAO - Kết phiên bảo mật + chuẩn hóa tsudev

- **Mã phiếu**: 20261111-04
- **Từ**: phiên tsudev-lotus-0e (11/11/2026) - **Đến**: phiên kế tiếp của `tsudev-lotus`
- **Trạng thái**: ĐÓNG (12/11/2026 - việc còn lại chuyển vào STATE.md + phiếu 20261112-03)
- Phiếu `20261110-01` (kết phiên trước): các mục đã xử lý xong hoặc chuyển vào STATE.md -> coi như ĐÓNG.

## 1. Đã làm

- PR #17 (merge): yêu thích chỉ tin dấu vân tay mTLS; vá `rustix`; CI website cài Chromium không qua apt.
- PR #18: chuẩn hóa hệ tsudev (trang Ủng hộ, gỡ mua trong ứng dụng/StoreKit/FUNDING, i18n, tệp GitHub, máy chủ mặc
  định, trang Chính sách ký mã, nội dung đơn SignPath `20261111-03`).
- PR PIN (`feat/pin-ngau-nhien-manh`): PIN CSPRNG fail-closed, tối thiểu 6 ký tự.
- Đọc điều kiện SignPath (signpath.org/terms) 11/11/2026: rủi ro chính là repo KHÔNG phải GitHub fork - xem phiếu 03.

## 2. Bước tiếp theo CỤ THỂ

1. Kiểm `gh pr list -R tsudev-org/tsudev-lotus`: PR #18 và PR PIN phải MERGED; nếu chưa, xem kiểm tra trượt.
2. Website: sau merge, `cd website && npm run deploy` (nếu agent bị chặn, nhờ chủ dự án chạy `! cd ~/projects/tsudev-lotus/website && npm run deploy`);
   kiểm `curl -sI https://lotus.tsudev.com/chinh-sach-ky-ma/` trả 200.
3. Nhắc chủ dự án: nộp đơn SignPath (phiếu 03), gắn nhãn `v1.18.2-lotus.3` để phát hành bản có các bản sửa bảo mật.
4. Tệp lạ `logo-tsudev-lotus.png` ở gốc repo (không do phiên này tạo, chưa commit): hỏi chủ dự án trước khi xử lý.

## 3. Cảnh báo

- Dòng nào sửa trong tệp có em-dash kế thừa thì mất miễn trừ -> thay em-dash (U+2014) bằng `-` đúng dòng đó (đã gặp ở be/ky/ru/uk.json).
- Kho apt Ubuntu lỗi DNS 11/11/2026: job Linux của `release-lotus.yml` có thể kẹt ở bước "Thư viện hệ thống".

## 4. Cổng kiểm

- [x] check-standards ĐẠT; flutter analyze 0 lỗi; flutter test 97/97; cargo test core đạt; i18n ĐẠT; website check-dist 0 lỗi, a11y 9 trang x 2 chế độ 0 lỗi.

## 5. Kết quả xử lý

-
