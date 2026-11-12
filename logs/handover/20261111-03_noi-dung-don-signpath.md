# PHIẾU - Nội dung đơn SignPath Foundation (chủ dự án nộp)

- **Mã phiếu**: 20261111-03
- **Từ**: phiên tsudev-lotus-0e (11/11/2026) - **Đến**: chủ dự án
- **Trạng thái**: MỞ - chờ chủ dự án nộp đơn, ghi ngày nộp vào `logs/STATE.md`
- **Kế hoạch gốc**: `docs/vi/KE-HOACH-KY-MA-12-2026.md` mục 1.4

## 1. Điều kiện đã đọc lại (signpath.org/terms, 11/11/2026)

Khớp mục 1.2 của kế hoạch, cộng thêm:

- **Bản fork** chỉ được ký khi: (a) dự án gốc có phát hành bản đã ký - LocalSend có (SignPath); (b) dự án "dùng fork
  một cách hiển nhiên, ví dụ tính năng fork của GitHub"; (c) nhánh phát hành dựa trên nhánh gốc vốn được ký;
  (d) đủ các nghĩa vụ khác. **Rủi ro**: `tsudev-org/tsudev-lotus` KHÔNG phải GitHub fork (`.fork = false`); việc fork
  chỉ thể hiện qua README, NOTICE, remote `upstream`, trang Bản quyền. Ghi rõ điều này trong đơn (mục 2, ô Mô tả).
- **Không thành phần độc quyền**: đã gỡ `in_app_purchase` khỏi mọi bản (PR #18) - đạt.
- **Metadata**: tên sản phẩm trong tệp ký = tên dự án (`tsudev-lotus`), phiên bản giống nhau mọi tệp của một bản build.
  Kiểm `app/windows/runner/Runner.rc` + bộ cài Inno trước khi tích hợp (mục 1.5).
- **Trang chính sách**: dùng cụm "Code signing policy" ở trang chủ và trang tải về; câu ghi công nguyên văn; vai trò;
  tuyên bố quyền riêng tư - đã có tại `https://lotus.tsudev.com/chinh-sach-ky-ma/` (nguồn `CODE_SIGNING.md`),
  liên kết ở chân mọi trang + mục Kiểm tra tệp của trang Tải về.
- **MFA** bắt buộc cho mọi thành viên trên GitHub và SignPath.

## 2. Nội dung điền đơn

**THAY THẾ (12/11/2026)**: bảng cũ dùng tên `tsudev-lotus` đã lỗi thời (sản phẩm đổi tên Lotus Share, repo
`tsudev-org/lotus-share`). Nội dung đơn, câu trả lời về fork và các bước làm theo
[`docs/vi/HUONG-DAN-KY-MA.md`](../../docs/vi/HUONG-DAN-KY-MA.md) phần A.

## 3. Việc chủ dự án làm

Theo `docs/vi/HUONG-DAN-KY-MA.md` mục A1-A7. Đo 12/11/2026: org `tsudev-org` CHƯA bật bắt buộc 2FA (mục A2).

## 4. Kết quả xử lý

- 12/11/2026 (lotus-share-fc): đọc lại signpath.org/terms + docs.signpath.io (GitHub); viết hướng dẫn từng bước
  `docs/vi/HUONG-DAN-KY-MA.md`, script `tools/dat-bien-signpath.sh`; trang chính sách thêm phần tiếng Anh với nhãn
  "Committers and reviewers" / "Approvers". Chờ chủ dự án nộp đơn.
- 12/11/2026: chủ dự án bật bắt buộc 2FA ở org `tsudev-org` (agent đo: `two_factor_requirement_enabled=true`) và đã nộp
  đơn. Chờ SignPath duyệt; bước tiếp: `docs/vi/HUONG-DAN-KY-MA.md` A6 -> KE-HOACH mục 1.5 (theo dõi ở `logs/STATE.md`).
