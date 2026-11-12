# Chính sách ký mã (Code signing policy) - Lotus Share

> Trạng thái (12/11/2026): bản Windows/macOS **chưa** có chứng thư ký mã thương mại. Đã nộp đơn SignPath Foundation
> (Windows), đang chờ duyệt; Apple Developer ID (macOS/iOS) dự kiến tháng 12/2026. Hướng dẫn: `docs/vi/HUONG-DAN-KY-MA.md`.
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

## Summary in English (for SignPath Foundation reviewers)

Lotus Share is a Vietnamese-first, security-hardened fork of [LocalSend](https://github.com/localsend/localsend)
(Apache-2.0), protocol-compatible with LocalSend v2. Release binaries are built only by GitHub-hosted runners from
immutable, admin-only tags `v*-lotus.*` via [`release-lotus.yml`](.github/workflows/release-lotus.yml); every change to
`main`, including upstream merges, goes through a pull request with all required checks.

- Committers and reviewers: [@tsudev-tsudev](https://github.com/tsudev-tsudev)
- Approvers: [@tsudev-tsudev](https://github.com/tsudev-tsudev)
- All team members use multi-factor authentication on GitHub and SignPath; every signing request is approved manually.
- Privacy: this program will not transfer any information to other networked systems unless specifically requested by
  the user or the person installing or operating it. Devices only announce their name on the local network for
  discovery while the app is open; Internet (WebRTC) transfer is disabled at build time.
