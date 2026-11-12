# Chính sách ký mã (Code signing policy) - Lotus Share

> Trạng thái (13/11/2026): bản Windows/macOS **chưa** có chứng thư ký mã thương mại. SignPath Foundation chưa duyệt đơn
> lần đầu (12/11/2026) vì dự án còn mới, chưa đủ mức độ được biết đến công khai; dự án sẽ nộp lại sau. Apple Developer
> ID (macOS/iOS) dự kiến tháng 12/2026. Trong lúc chờ, mọi tệp phát hành đều kiểm chứng được bằng SHA256SUMS ký
> Sigstore và chứng thực nguồn gốc SLSA (mục bên dưới). Trang này sẽ cập nhật ngay khi việc ký được bật.

Nếu được SignPath Foundation duyệt, bản Windows sẽ ký theo câu ghi công sau:

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
- Mọi thay đổi chỉ vào `main` qua Pull Request được duyệt.

## Quyền riêng tư

Chính sách quyền riêng tư chung của hệ sinh thái: <https://tsudev.com/privacy>. Ứng dụng chỉ trao đổi dữ liệu trực
tiếp giữa các thiết bị trong mạng nội bộ; tệp và tin nhắn không đi ra Internet, không có telemetry. Ngoại lệ duy nhất:
khi mở, ứng dụng tải tệp công khai `https://lotus.tsudev.com/phien-ban.json` (chỉ chứa số phiên bản) để biết có bản mới
hoặc bản đang dùng đã quá cũ - yêu cầu không kèm dữ liệu nào của thiết bị hay người dùng; không có Internet thì ứng
dụng vẫn chạy bình thường.

This program will not transfer any information to other networked systems unless specifically requested by the user
or the person installing or operating it. (Thiết bị chỉ phát tên máy trong mạng nội bộ để tìm nhau khi người dùng mở
ứng dụng; tính năng WebRTC qua Internet đang tắt.) The only Internet request is a plain HTTPS GET of the public version
file `https://lotus.tsudev.com/phien-ban.json` at startup, carrying no device or user data, used to tell the user that
an update is available or required.

## Summary in English (for SignPath Foundation reviewers)

Lotus Share is an independent, Vietnamese-first local file-sharing app by tsudev (Apache-2.0; derived from Apache-2.0
code, see [NOTICE](NOTICE)). Release binaries are built only by GitHub-hosted runners from immutable, admin-only tags
`v*-lotus.*` via [`release-lotus.yml`](.github/workflows/release-lotus.yml); every change to `main` goes through a pull
request with all required checks.

- Committers and reviewers: [@tsudev-tsudev](https://github.com/tsudev-tsudev)
- Approvers: [@tsudev-tsudev](https://github.com/tsudev-tsudev)
- All team members use multi-factor authentication on GitHub and SignPath; every signing request is approved manually.
- Privacy: this program will not transfer any information to other networked systems unless specifically requested by
  the user or the person installing or operating it. Devices only announce their name on the local network for
  discovery while the app is open; Internet (WebRTC) transfer is disabled at build time. The only Internet request is
  an HTTPS GET of the public version file `https://lotus.tsudev.com/phien-ban.json` at startup (no device or user data).
