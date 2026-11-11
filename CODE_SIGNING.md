# Chính sách ký mã (Code signing policy) - tsudev-lotus

> Trạng thái (11/11/2026): bản Windows/macOS **chưa** có chứng thư ký mã thương mại; đang chuẩn bị đăng ký
> SignPath Foundation (Windows) và Apple Developer ID (macOS/iOS). Kế hoạch: `docs/vi/KE-HOACH-KY-MA-12-2026.md`.
> Trang này sẽ cập nhật ngay khi việc ký được bật.

Khi được SignPath Foundation duyệt, bản Windows sẽ ký theo câu ghi công sau:

Free code signing provided by [SignPath.io](https://about.signpath.io), certificate by [SignPath Foundation](https://signpath.org)

## Bản phát hành được tạo thế nào

- Mọi tệp phát hành được build tự động từ mã nguồn ở repo này bằng GitHub Actions
  ([`release-lotus.yml`](.github/workflows/release-lotus.yml)), chỉ từ nhãn `v*-lotus.*` (bất biến, chỉ quản trị
  viên tạo được).
- Mọi thay đổi vào `main` phải qua Pull Request và toàn bộ kiểm tra bắt buộc (ruleset của repo).
- APK Android ký bằng khóa riêng của tsudev; dấu vân tay chứng thư được ghim trong workflow.
- `SHA256SUMS` ký bằng Sigstore (keyless), mỗi tệp có chứng thực nguồn gốc SLSA - người dùng tự kiểm chứng được theo
  [docs/vi/PHAT-HANH.md](docs/vi/PHAT-HANH.md).
- Chỉ ký tệp do repo này build. Thư viện bên thứ ba đóng gói kèm giữ nguyên chữ ký của nhà phát hành gốc.

## Vai trò

- Tác giả (committer), người duyệt (reviewer): [@tsudev-tsudev](https://github.com/tsudev-tsudev)
- Người phê duyệt ký (approver): [@tsudev-tsudev](https://github.com/tsudev-tsudev)
- Mọi thành viên bật xác thực nhiều lớp (MFA) cho GitHub và SignPath. Mỗi yêu cầu ký được người phê duyệt duyệt tay.
- Thay đổi từ dự án gốc (LocalSend) chỉ vào `main` qua Pull Request được duyệt như mọi thay đổi khác.

## Quyền riêng tư

Chính sách quyền riêng tư chung của hệ sinh thái: <https://tsudev.com/privacy>. Ứng dụng chỉ trao đổi dữ liệu trực
tiếp giữa các thiết bị trong mạng nội bộ; không gửi dữ liệu ra Internet, không có telemetry.

This program will not transfer any information to other networked systems unless specifically requested by the user
or the person installing or operating it. (Thiết bị chỉ phát tên máy trong mạng nội bộ để tìm nhau khi người dùng mở
ứng dụng; tính năng WebRTC qua Internet đang tắt.)
