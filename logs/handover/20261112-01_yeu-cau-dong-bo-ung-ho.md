# PHIẾU YÊU CẦU - Đồng bộ mục Ủng hộ (thay trang Donation)

- **Mã phiếu**: 20261112-01
- **Từ**: phiên tsudev-files-01 (12/11/2026), theo yêu cầu trực tiếp của chủ dự án
- **Đến**: phiên làm việc trên `tsudev-lotus`
- **Trạng thái**: ĐÓNG (12/11/2026, phiên tsudev-lotus-0e - nhánh `feat/ung-ho`)

## 1. Đọc trước

Phiếu gốc `~/projects/logs/handover/20261112-01_yeu-cau-dong-bo-ung-ho-he-sinh-thai.md`: thông tin Ủng hộ chuẩn (VIB `056485506`, NGUYEN TRANG TINH SU, chuỗi VietQR, ảnh
`vietqr-vib.svg` + SHA-256) và kiến trúc bắt buộc (một nguồn dữ liệu, app chỉ trỏ về trang, không dịch vụ QR bên thứ
ba, ghim SHA-256 + kiểm VietQR lúc build, CODEOWNERS, chính sách kho di động, không lưu bí mật).
Bản tham chiếu: repo `tsudev-files` (`website/src/data/ung-ho.json`, `website/src/lib/ung-ho.ts`,
`website/public/ung-ho/vietqr-vib.svg`, `tools/ung-ho/tao-vietqr.py`).

## 2. Việc riêng của repo này (khảo sát nhanh 12/11/2026 - cần rà lại)

- `app/lib/pages/donation/` (lối vào ở `settings_tab.dart`): trang Donation kế thừa LocalSend - GitHub Sponsors/Ko-fi
  của Tienisto và mua trong ứng dụng (IAP, `purchase_provider`, `app/ios/MyLocalSendStoreKit.storekit`) gắn mã sản
  phẩm/tài khoản cửa hàng của bản gốc. Kiểm lại trạng thái hiện tại (có thể phiên trước đã sửa một phần).
- `.github/FUNDING.yml`: `github: [Tienisto]` -> trang ủng hộ tsudev.
- Bản qua Google Play/App Store: phiếu gốc mục 3.5 - KHÔNG hiện QR/liên kết ngoài; tắt IAP của bản gốc. Bản desktop/
  APK trực tiếp: nút mở trang ủng hộ.
- `website/` (lotus.tsudev.com): thêm trang/khối Ủng hộ theo bản tham chiếu, hoặc liên kết `tsudev.com/ung-ho`.
- Giữ `LICENSE`, `NOTICE`, `README.upstream.md` (ghi công).

## 3. Việc chung

Theo phiếu gốc mục 4: gỡ kênh cũ, `FUNDING.yml`, trang/nút Ủng hộ, cổng kiểm + test, ghi `logs/STATE.md`.

## 4. Kết quả xử lý (phiên nhận điền, và ghi một dòng vào phiếu gốc mục 6)

-
- 12/11/2026 (tsudev-lotus-0e): làm theo bản tham chiếu tsudev-files.
  - Web: `lotus.tsudev.com/ung-ho/` - dữ liệu một nguồn `website/src/data/ung-ho.json`, kiểm lúc build ở
    `website/src/lib/ung-ho.ts` (CRC VietQR, NAPAS, BIN + số tài khoản, SHA-256 ảnh QR ghim; chặn tienisto/ko-fi/
    localsend.org). Đã thử tráo ảnh QR 1 byte -> build dừng. Ảnh `vietqr-vib.svg` chép nguyên (SHA-256 `7209698f...`).
    Liên kết ở chân mọi trang + sitemap; `tools/ung-ho/tao-vietqr.py` chép kèm.
  - App: trang Ủng hộ chỉ MỞ trang web (không hiển thị số tài khoản/QR trong app); ẩn trên iOS (App Store).
    Mua trong ứng dụng + StoreKit + kênh Tienisto đã gỡ từ PR #18. Android hiện chỉ phân phối APK trực tiếp.
  - GitHub: `.github/FUNDING.yml` -> `custom: https://lotus.tsudev.com/ung-ho/`; `CODEOWNERS` cho dữ liệu, ảnh QR,
    công cụ, FUNDING, `fork_config.dart`.
  - Còn lại: nếu sau này phát hành lên Google Play, phải ẩn lối vào Ủng hộ ở bản Play (cờ build) theo mục 3.5.

## 5. Bổ sung 12/11/2026 - phương án theo nền tảng (đã chốt)

Áp dụng phiếu `~/projects/logs/handover/20261112-02_quyet-dinh-ung-ho-theo-nen-tang.md` (thay mục 3.5 của phiếu gốc):
web hiện đầy đủ; desktop/Android chỉ nút mở trang web kèm câu "tự nguyện, 100% tới nhà phát triển, không mở khóa gì";
iOS App Store ẩn hoàn toàn. Ghi một dòng kết quả vào mục 5 của phiếu đó.
