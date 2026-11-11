# STATE.md - Trạng thái project Lotus Share (repo tsudev-org/lotus-share, trước đây tsudev-lotus)

> Agent đọc file này ở đầu mỗi phiên và cập nhật ở cuối mỗi phiên.
> Quy trình: `.standards/docs/AGENT_PROTOCOL.md`.

## Hàng đợi task (làm từ trên xuống)

- [ ] **CHẶN - deploy website**: `wrangler` trên máy đang đăng nhập tài khoản Cloudflare của dự án UBND, không phải tsudev
      -> production `lotus.tsudev.com` vẫn là bản trước đổi tên (chưa có `/ung-ho/`, tiêu đề "tsudev-lotus"). Chủ dự án
      đăng nhập tsudev vào cấu hình RIÊNG (không đổi đăng nhập chung):
      `! XDG_CONFIG_HOME=$HOME/.config/wrangler-tsudev npx --prefix ~/projects/lotus-share/website wrangler login`, rồi
      deploy: `cd website && XDG_CONFIG_HOME=$HOME/.config/wrangler-tsudev npm run deploy` (Worker `lotus-share`; tên miền
      đang gắn Worker `tsudev-lotus` -> gỡ tên miền khỏi Worker cũ trên dashboard trước, hoặc tạm deploy `--name tsudev-lotus`).
      Dọn: 2 Worker tạo NHẦM 12/11 00:50 trong tài khoản UBND (`lotus-share`, `tsudev-lotus`, chỉ chứa site tĩnh) - chủ dự án xóa.
- [ ] Đổi tên thư mục máy `~/projects/tsudev-lotus` -> `~/projects/lotus-share` (chủ dự án làm khi KHÔNG còn phiên nào mở
      trong thư mục; khóa ký đã chuyển sang `~/.config/lotus-share/keys`, symlink tên cũ còn giữ).
- [ ] Phát hành `v1.18.2-lotus.3` = bản Lotus Share đầu tiên (định danh mới; build thử run 43066623921 xanh mọi nền tảng).
- [ ] Phiếu `~/projects/logs/handover/20261112-02` (kho gói đổi tên `lotus-share`) - sau khi kho gói đổi, sửa lệnh cài ở
      `website/src/pages/tai-ve.astro` và bỏ tiền tố cũ `tsudev-lotus` trong `website/src/lib/noi-dung.ts`.
- [ ] **Chủ dự án nộp đơn SignPath Foundation** theo phiếu `logs/handover/20261111-03_noi-dung-don-signpath.md`
      (nội dung điền sẵn; trang `lotus.tsudev.com/chinh-sach-ky-ma/` đã có). Ghi ngày nộp vào mục Quyết định.
- [ ] **Đầu tháng 12/2026 - ký mã Apple (macOS công chứng, iOS TestFlight)** khi chủ dự án có Apple Developer; tích hợp
      SignPath khi đơn được duyệt. Kế hoạch: `docs/vi/KE-HOACH-KY-MA-12-2026.md` mục 1.5, 2.
- [ ] Dựng máy chủ tín hiệu `signal.lotus.tsudev.com` từ `server/` trước khi bật WebRTC (mặc định đã trỏ về đó).
- [ ] Gói .deb/.rpm cho Linux (cấu hình `app/linux/packaging/` đã đổi tên, workflow chưa dựng), Linux ARM64, Windows ARM64.
- [ ] Nâng `rsa` 0.9 -> 0.10 khi lõi upstream nâng (xóa chấp nhận RUSTSEC-2023-0071 trong `tools/osv_scan.py`).

## Đang thực hiện

| Task | Agent | Bắt đầu |
| --- | --- | --- |

## Đã hoàn thành (mới nhất trên cùng)

- 12/11/2026 (tsudev-lotus-0e) - **Đổi tên Lotus Share** (PR #21): tên hiển thị 57 ngôn ngữ, CLI, bộ cài, website,
  tài liệu; định danh mới `com.tsudev.lotusshare` / `lotus_share` / AppId `{21D09887-...}` / `lotus-share-cli`; repo đổi
  thành `tsudev-org/lotus-share` (tên cũ chuyển hướng; bảo mật + 3 ruleset giữ nguyên). Logo Lotus Share: bộ công cụ
  `prepare_brand.py` -> `gen_icons.py` -> `brand_assets.py` (icon mọi nền tảng, favicon, PWA, AVIF/WebP, OG). Bảng màu
  Lotus (app AA 4.81-9.06; quầng 3 màu trên web). Build thử đủ nền tảng xanh (run 43066623921).
- 12/11/2026 - Trang Ủng hộ `/ung-ho/` (PR #22, phiếu 20261112-01): VietQR một nguồn, ghim SHA-256, kiểm lúc build; app chỉ
  mở trang, ẩn trên iOS; FUNDING.yml + CODEOWNERS.
- 11/11/2026 (phiên tsudev-lotus-0e) - Bảo mật: thiết bị yêu thích chỉ tin dấu vân tay mTLS (chặn mạo danh để "Lưu
  nhanh" ở chế độ HTTP, PR #17); PIN nhận tệp/chia sẻ liên kết sinh 8 ký tự bằng CSPRNG fail-closed, tối thiểu 6 ký tự;
  vá `rustix` RUSTSEC-2026-0486. Rà soát: uuid v4 (CryptoRNG), session/token lõi Rust (getrandom) đều an toàn.
- 11/11/2026 - Chuẩn hóa hệ tsudev (PR #18): trang Ủng hộ chỉ dẫn tsudev.com / lotus.tsudev.com / GitHub
  (`forkSupportLinks`); gỡ `in_app_purchase` + StoreKit + `FUNDING.yml`; 56 tệp dịch đổi tên sản phẩm; máy chủ
  tín hiệu/STUN không còn localsend.org; issue template, CONTRIBUTING, CODE_SIGNING viết lại; trang
  `/chinh-sach-ky-ma/`. Build thử đủ nền tảng run 43051435568 (macOS/Android/Windows/CLI xanh; Linux kẹt apt Ubuntu).
- 11/11/2026 - CI website: cài Chromium không qua apt (kho Ubuntu lỗi DNS làm job quá giờ).
- 10/11/2026 - Phiếu `20261110-05` (giao diện đen + tím kiểu Supabase): website + app (mặc định Tối, màu nhấn tím).
  Chi tiết: mục Kết quả của phiếu. PR #11 đã merge; trang Tải về production không còn gói trùng (đã đo).
- 10/11/2026 - **Phát hành công khai `v1.18.2-lotus.2`** (bản mới nhất, 15 tệp): Windows exe/zip, Linux AppImage/zsync/
  tar.gz, 4 APK ký khóa tsudev, macOS DMG, CLI Linux/Windows, SBOM, SHA256SUMS + chữ ký Sigstore; chứng thực SLSA.
  Đã kiểm trên bản phát hành thật: SHA256SUMS khớp, `gh attestation verify` trỏ workflow tại nhãn, CLI chạy và in tiếng
  Việt. Trang `lotus.tsudev.com/tai-ve/` hiện đủ gói + SHA-256. `main` bảo vệ bằng 3 ruleset (PR + 11 kiểm tra bắt
  buộc; nhãn `v*-lotus.*` bất biến, chỉ quản trị tạo); repo bật tự merge (`gh pr merge --auto`).
- 10/11/2026 - Quy trình phát hành chạy xanh trọn vẹn (build thử run 42804114546, nhánh `fix/phat-hanh-lan-dau`):
  13 gói (Windows exe/zip, Linux AppImage/zsync/tar.gz, 4 APK ký khóa tsudev, macOS DMG, CLI Linux/Windows, SBOM),
  SHA256SUMS ký Sigstore, chứng thực SLSA v1 cho 15 tệp (Rekor). Đã tự kiểm: `gh attestation verify` đạt với tệp thật,
  từ chối tệp sửa 1 byte. Lần gắn nhãn `v1.18.2-lotus.1` trước đó hỏng (nhãn bất biến) -> phát hành thật là `-lotus.2`.
  Lỗi đã sửa: chú thích cuối dòng CMake, Gradle 8.14.3 + Kotlin 2.2.20 (mức tối thiểu Flutter 3.47.9), macOS ký ad-hoc +
  Xcode 26, AppImage thử lại khi máy chủ Ubuntu đồng bộ, bước kiểm chữ ký APK (định dạng apksigner, biến đè nhau).
- 10/11/2026 - Quy ước v3.3.0 (tsudev-standards#48 merge, nhãn v3.3.0) đồng bộ vào repo; cổng quy ước trong CI chặn thật (bỏ `continue-on-error`), em-dash kế thừa được miễn theo dòng.
- 10/11/2026 - Chủ dự án đẩy khóa ký APK lên GitHub Secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, 05:20 UTC); dấu vân tay khớp giá trị ghim trong `release-lotus.yml`.
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

- 11-12/11/2026 - Chủ dự án: tên **Lotus Share**, slug `lotus-share`; dùng logo riêng (lệch BRAND_ASSETS, đề xuất ở
  tsudev-standards phiếu 20261112-01); ĐỔI cả định danh cài đặt (bản tsudev-lotus cũ không tự cập nhật - trang Tải về có
  hướng dẫn); bảng màu Lotus giữ 3 chế độ. Agent giữ: alias `tsudev-lotus` trong keystore APK (đổi là hỏng ký), tên gói
  nội bộ `localsend_app`/crate `localsend` (cầu nối Rust-Flutter + gộp bản vá upstream - chờ chủ dự án quyết riêng).
- 11/11/2026 - Chủ dự án giao agent chọn phương án đổi tên: GIỮ tên nội bộ (`localsend_app`, crate `localsend`,
  package Kotlin) để gộp được bản vá bảo mật upstream; mọi thứ người dùng/khách GitHub thấy là tsudev. Ghi công
  LocalSend / Tien Do Nam (LICENSE, NOTICE, Giới thiệu, trang Bản quyền) là nghĩa vụ Apache-2.0 - không gỡ.
- 11/11/2026 - Trang Ủng hộ: chỉ địa chỉ thuộc hệ tsudev (kiểm thử `fork_config_test.dart` chặn); chủ dự án sẽ bổ sung
  kênh ủng hộ mới vào `forkSupportLinks`.
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
