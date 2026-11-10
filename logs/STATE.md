# STATE.md - Trạng thái project tsudev-lotus

> Agent đọc file này ở đầu mỗi phiên và cập nhật ở cuối mỗi phiên.
> Quy trình: `.standards/docs/AGENT_PROTOCOL.md`.

## Hàng đợi task (làm từ trên xuống)

- [ ] Chủ dự án: triển khai website `cd website && npx wrangler login && npm run deploy` (tự gắn `lotus.tsudev.com`),
      rồi `gh repo edit tsudev-org/tsudev-lotus --homepage https://lotus.tsudev.com`.
- [ ] Bật bảo vệ nhánh `main` (PR + check "Kiểm tra bản fork", "Bảo mật") và Private vulnerability reporting.
- [ ] Đổi định danh nền tảng để cài song song được với LocalSend: Android `applicationId`
      (`org.localsend.localsend_app` -> `com.tsudev.lotus`), bundle id iOS/macOS, tên tệp chạy Windows, tên AppImage/deb/rpm,
      `ProductName` của CLI (`cli/build.rs`), cửa sổ/khay hệ thống. Việc lớn, chạm mọi nền tảng: làm trên nhánh riêng.
- [ ] Viết lại workflow phát hành (`release.yml`, `build_*.yml`): đặt tên tệp `tsudev-lotus-<ver>-...`, sinh `SHA256SUMS`,
      SBOM, chứng thực nguồn gốc (attestation). Chưa có chứng thư ký mã Windows/Apple: phát hành bản chưa ký trước.
- [ ] Việt hóa phần ngoài Flutter: trang web nhận tệp qua trình duyệt (`packages/core/assets/web/`), bộ cài Inno Setup
      (`support/scripts/compile_windows_exe-inno.iss`), tệp `.desktop` Linux, chuỗi native Android/iOS, giao diện CLI.
- [ ] Màn hình Giới thiệu: thêm mục ghi công tsudev cho người dịch tiếng Việt; trang Ủng hộ hiện vẫn dẫn về tác giả gốc (giữ).
- [ ] Nâng `rsa` 0.9 -> 0.10 khi lõi upstream nâng (xóa chấp nhận RUSTSEC-2023-0071 trong `tools/osv_scan.py`).
- [ ] Khi bật WebRTC: dựng máy chủ tín hiệu riêng từ `server/` và đổi `forkDefaultSignalingServers`.
- [ ] Đề xuất ở `tsudev-standards`: cơ chế miễn trừ em-dash cho mã kế thừa upstream (đi chung phiếu của tsudev-files).

## Đang thực hiện

| Task | Agent | Bắt đầu |
| --- | --- | --- |

## Đã hoàn thành (mới nhất trên cùng)

- 10/11/2026 - Website `website/` (Astro tĩnh, không JS, CSP chặt): 7 trang + 404, ảnh OG, security.txt. Build:
  check-dist 0 lỗi; axe-core WCAG 2.2 AA 8 trang x 2 chế độ màu, 0 lỗi; npm audit 0 lỗ hổng.
- 10/11/2026 - Gia cố PIN trong lõi Rust (`packages/core/src/http/server/common/pin.rs`): so sánh thời gian hằng, đếm lần
  sai theo khối /64 IPv6 + bỏ ánh xạ IPv4; 4 test mới. `cargo test --features full` đạt toàn bộ.
- 10/11/2026 - Nâng 7 crate có lỗ hổng (rustls, rustls-webpki, webpki-roots, webpki-root-certs, tokio, h2, lru).
  `tools/osv_scan.py`: 773 gói, 0 lỗ hổng chưa xử lý (4 mục chấp nhận có hạn, xem `docs/vi/KIEN-TRUC-BAO-MAT.md` mục 5).
- 10/11/2026 - Tiếng Việt mặc định (`app/lib/config/fork_config.dart` + `persistence_provider.dart`, giữ lựa chọn
  "Theo hệ thống"); bổ sung 7 khóa thiếu + 9 chuỗi còn tiếng Anh + tên thiết bị ngẫu nhiên tiếng Việt; nhóm khóa `tsudev`
  thay chuỗi viết cứng ở Giới thiệu/Cài đặt/chọn APK. `flutter analyze` 0 lỗi, `flutter test` 92/92.
- 10/11/2026 - Khởi tạo fork từ `localsend/localsend@8476c091` (v1.18.2) sau khi rà quét an toàn: gitleaks toàn lịch sử
  (4 khóa thử nghiệm công khai, đã miễn trong `.gitleaksignore`), không mã độc/tải-chạy trong script build, 3 DLL MSVC
  của Microsoft, không có trình tự cập nhật hay telemetry.

## Quyết định quan trọng

- 10/11/2026 - Tên miền website: `lotus.tsudev.com` (tên miền con 1 cấp, cùng kiểu `files.`, `trafficmonitor.`, `compass.`).
- 10/11/2026 - Giữ tương thích giao thức LocalSend v2 (cổng 53317, multicast 224.0.0.167): giá trị cốt lõi của sản phẩm.
- 10/11/2026 - Giữ tên gói Dart/crate (`localsend_app`, `localsend`) và định danh nền tảng ở bước đầu để gộp upstream dễ;
  đổi định danh là task riêng (xem hàng đợi).
- 10/11/2026 - LocalSend không có trình cập nhật trong ứng dụng (phân phối qua kho ứng dụng), nên "đổi link kiểm tra cập
  nhật" được hiện thực bằng: liên kết Trang chủ/Mã nguồn/Phát hành trỏ về `tsudev-org/tsudev-lotus` (`fork_config.dart`).
  Thêm trình tự cập nhật có ký số là việc sau, khi có quy trình phát hành.
- 10/11/2026 - Flutter dùng bản ghim 3.47.9 (commit `c197ca51`) cài ở `~/.local/share/flutter-sdk/3.47.9`, tắt analytics.

## Sự cố bảo mật

- (chưa có)
