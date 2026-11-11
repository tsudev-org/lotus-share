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

## 2. Nội dung điền đơn (https://signpath.org/apply)

| Ô | Nội dung |
| --- | --- |
| Project name | tsudev-lotus |
| Repository | https://github.com/tsudev-org/tsudev-lotus |
| Homepage / download page | https://lotus.tsudev.com (tải về: https://lotus.tsudev.com/tai-ve/) |
| Code signing policy URL | https://lotus.tsudev.com/chinh-sach-ky-ma/ |
| License | Apache-2.0 (OSI) |
| Description | Cross-platform app to share files and messages between nearby devices on the local network, without Internet or accounts. Vietnamese-first fork of LocalSend (Apache-2.0, signed by SignPath) with tsudev hardening; protocol-compatible with LocalSend v2. Fork relationship is stated in README, NOTICE and the About screen; upstream changes are merged via reviewed pull requests. |
| Build system | GitHub Actions, GitHub-hosted runners, workflow `.github/workflows/release-lotus.yml`, triggered by immutable admin-only tags `v*-lotus.*` |
| Files to sign | `tsudev_lotus.exe` and app DLLs built from this repo; installer `tsudev-lotus-<ver>-windows-x86-64.exe`; CLI `tsudev-lotus-cli-<ver>-windows-x86-64.exe` |
| Team | Author/Reviewer/Approver: tsudev-tsudev (MFA enabled) |
| Existing release | v1.18.2-lotus.2 (https://github.com/tsudev-org/tsudev-lotus/releases) |

## 3. Việc chủ dự án làm

1. Bật MFA cho `tsudev-tsudev` (nếu chưa) và "Require two-factor authentication" ở org `tsudev-org`.
2. Nộp đơn với nội dung mục 2; ghi ngày nộp vào `logs/STATE.md` (mục Quyết định quan trọng).
3. Nếu SignPath đòi "visible fork": cân nhắc nhờ GitHub Support gắn quan hệ fork, hoặc trả lời bằng các bằng chứng ở
   mục 1. KHÔNG xóa/tạo lại repo (vi phạm quy tắc tên repo trong CLAUDE.md toàn cục, gãy updater).

## 4. Kết quả xử lý

-
