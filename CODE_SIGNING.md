# Chính sách ký mã - tsudev-lotus

> Trạng thái (11/11/2026): bản Windows/macOS **chưa** có chứng thư ký mã thương mại; đang chuẩn bị đăng ký
> SignPath Foundation (Windows) và Apple Developer ID (macOS/iOS). Kế hoạch: `docs/vi/KE-HOACH-KY-MA-12-2026.md`.
> Trang này sẽ cập nhật ngay khi việc ký được bật.

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

## Quyền riêng tư

Chính sách quyền riêng tư chung của hệ sinh thái: <https://tsudev.com/privacy>. Ứng dụng chỉ trao đổi dữ liệu trực
tiếp giữa các thiết bị trong mạng nội bộ; không gửi dữ liệu ra Internet, không có telemetry.
