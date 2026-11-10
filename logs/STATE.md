# STATE.md - Trạng thái project tsudev-lotus

> Agent đọc file này ở đầu mỗi phiên và cập nhật ở cuối mỗi phiên.
> Quy trình: `.standards/docs/AGENT_PROTOCOL.md`.

## Hàng đợi task (làm từ trên xuống)

- [ ] Chủ dự án: đẩy khóa ký Android lên GitHub Secrets: `./tools/day-khoa-ky-android.sh` (agent không được ghi
      secret). Sao lưu ngoại tuyến `~/.config/tsudev-lotus/keys/` (mất khóa = không cập nhật được APK đã cài).
- [ ] Chủ dự án: duyệt + merge `tsudev-org/tsudev-standards#48`, gắn nhãn `v3.3.0`; sau đó ở repo này
      `./scripts/sync-standards.sh --ref v3.3.0` và bỏ `continue-on-error` ở bước cổng quy ước (`fork-ci.yml`).
- [ ] Chủ dự án: merge PR `chore/khoi-tao-fork` vào `main`, bật bảo vệ nhánh `main` (PR + check "Kiểm tra bản fork", "Bảo mật").
- [ ] Phát hành bản đầu `v1.18.2-lotus.1` theo `docs/vi/PHAT-HANH.md` (cần secret ở trên). Theo dõi lần chạy đầu của
      `release-lotus.yml`: các bước Windows/Linux/Android/macOS chưa từng chạy trên runner thật.
- [ ] Sau khi có bản phát hành: `cd website && npm run deploy` (trang Tải về lấy gói + SHA-256 lúc build).
- [ ] Chứng thư ký mã Windows: nộp đơn SignPath Foundation (miễn phí cho OSS); macOS/iOS cần Apple Developer Program.
- [ ] Gói .deb/.rpm cho Linux (cấu hình `app/linux/packaging/` đã đổi tên, workflow chưa dựng), Linux ARM64, Windows ARM64.
- [ ] Nâng `rsa` 0.9 -> 0.10 khi lõi upstream nâng (xóa chấp nhận RUSTSEC-2023-0071 trong `tools/osv_scan.py`).
- [ ] Khi bật WebRTC: dựng máy chủ tín hiệu riêng từ `server/` và đổi `forkDefaultSignalingServers`.

## Đang thực hiện

| Task | Agent | Bắt đầu |
| --- | --- | --- |

## Đã hoàn thành (mới nhất trên cùng)

- 10/11/2026 (phiên 2) - Repo `tsudev-org/tsudev-lotus` (công khai): secret scanning + push protection, báo lỗi bảo
  mật riêng tư, Dependabot alerts/security updates đã bật TRƯỚC lần push đầu; homepage `https://lotus.tsudev.com`
  (site đang chạy, header bảo mật đúng).
- 10/11/2026 (phiên 2) - Định danh riêng mọi nền tảng (`com.tsudev.lotus`, `tsudev_lotus`, AppId Inno mới, CLI
  `tsudev-lotus-cli` + thư mục cấu hình riêng, AppImage tự cập nhật từ repo tsudev); icon mọi nền tảng sinh từ dấu
  hiệu cú tsudev (`tools/gen_icons.py`), logo trong ứng dụng không còn tô màu.
- 10/11/2026 (phiên 2) - Việt hóa: sửa 66 chuỗi vi.json dịch sai/máy móc (vd "Multicast address" thành "Đa phương
  tiện", "Exclude system apps" thành "Mở ứng dụng hệ thống"); đổi "LocalSend" thành tên sản phẩm ở 57 ngôn ngữ (giữ
  ở ghi công/ủng hộ tác giả gốc); trang web nhận tệp, lời xin quyền iOS/macOS, bộ cài Inno (tiếng Việt mặc định,
  `Vietnamese.isl` chính thức), menu macOS, gói Linux, toàn bộ CLI (kể cả `--help`). Kiểm: flutter analyze 0 lỗi,
  flutter test 92/92, cargo test CLI 41/41, web 9/9.
- 10/11/2026 (phiên 2) - Quy trình phát hành `release-lotus.yml` + `docs/vi/PHAT-HANH.md`: Windows (bộ cài + ZIP),
  Linux (AppImage + tar.gz), Android (APK ký khóa tsudev, ghim dấu vân tay), macOS (DMG ad-hoc), CLI; SBOM SPDX,
  SHA256SUMS ký Sigstore keyless, chứng thực SLSA, bản nháp phát hành. Khóa APK RSA 4096 tạo ngoài repo.
- 10/11/2026 (phiên 2) - Em-dash: cơ chế miễn trừ theo dòng cho fork (tsudev-standards PR #48, 7 ca kiểm thử);
  `.standards-upstream` ở repo này (71 dòng kế thừa được miễn, xác minh trực tuyến); bắt và sửa 1 em-dash do fork
  thêm (`website/scripts/check-dist.mjs`); phiếu `20261110-01` gửi tsudev-files (đo thử: 295 dòng miễn, 1 vi phạm thật).

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
- 10/11/2026 - Định danh: chỉ đổi định danh CÀI ĐẶT/hiển thị; giữ tên nội bộ (package Kotlin, kênh nền tảng, gói
  Dart, crate) để gộp upstream ít xung đột. Chi tiết `docs/vi/PHAT-HANH.md` mục 1.
- 10/11/2026 - Icon: dùng dấu hiệu chung tsudev (BRAND_ASSETS mục 12.3), không dùng logo LocalSend.
- 10/11/2026 - Flutter dùng bản ghim 3.47.9 (commit `c197ca51`) cài ở `~/.local/share/flutter-sdk/3.47.9`, tắt analytics.

## Sự cố bảo mật

- (chưa có)
