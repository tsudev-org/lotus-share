# STATE.md - Trạng thái project Lotus Share (repo tsudev-org/lotus-share, trước đây tsudev-lotus)

> Agent đọc file này ở đầu mỗi phiên và cập nhật ở cuối mỗi phiên.
> Quy trình: `.standards/docs/AGENT_PROTOCOL.md`.

## Hàng đợi task (làm từ trên xuống)

- Deploy website: `cd website && XDG_CONFIG_HOME=$HOME/.config/wrangler-tsudev npm run deploy` (cấu hình wrangler RIÊNG của
  tsudev - đăng nhập chung là tài khoản UBND; kiểm `wrangler whoami` = dev.nguyentrangtinhsu@...). Sau mỗi bản phát hành
  phải deploy lại (trang Tải về đọc danh sách tệp lúc build).
- [ ] winget `tsudev.LotusShare`: chờ Microsoft duyệt PR microsoft/winget-pkgs#478033 (đã đóng #477225 `tsudev.Lotus`). Khi
      merge: chuyển `winget` từ `planned` sang `channels` trong `packaging/package.json`, thêm lệnh winget vào trang Tải về.
- [ ] **SignPath Foundation: ĐÃ NỘP ĐƠN 12/11/2026, chờ duyệt** (org `tsudev-org` đã bắt buộc 2FA - đo 12/11/2026).
      Đầu mỗi phiên: hỏi chủ dự án có email từ SignPath chưa (agent không đọc được hộp thư).
      - SignPath hỏi thêm (thường về quan hệ fork): trả lời theo `docs/vi/HUONG-DAN-KY-MA.md` mục A5.
      - Được duyệt: chủ dự án làm A6 (MFA SignPath, Trusted Build System GitHub.com, CI user + token) rồi chạy
        `tools/dat-bien-signpath.sh`. Agent kiểm `gh variable list` / `gh secret list` có đủ `SIGNPATH_*` rồi làm
        `docs/vi/KE-HOACH-KY-MA-12-2026.md` mục 1.5 (artifact configuration XML, bước ký trong `release-lotus.yml`,
        build thử) -> 1.6 (trang chính sách ký mã: "đã bật", phát hành bản đã ký, trả lời SmartScreen trên Tải về).
      - Bị từ chối: ghi lý do vào mục Quyết định, báo chủ dự án; phương án dự phòng ở KE-HOACH mục 1.2.
- [ ] **Tháng 12/2026, khi chủ dự án có MacBook - ký mã Apple (macOS Developer ID + công chứng, iOS TestFlight)**.
      CHƯA làm gì trước thời điểm đó. Chủ dự án làm `docs/vi/HUONG-DAN-KY-MA.md` phần B trên MacBook (B1-B4, xin quyền
      multicast B3 ngay sau khi đăng ký vì Apple duyệt tay; chứng thư theo B5 "Trên MacBook"), chạy
      `tools/day-khoa-apple.sh`; agent làm `KE-HOACH-KY-MA-12-2026.md` mục 2.2 và chạy thử app trên MacBook thật.
- [ ] Dựng máy chủ tín hiệu `signal.lotus.tsudev.com` từ `server/` trước khi bật WebRTC (mặc định đã trỏ về đó).
- Xuất bản kho `pkg.tsudev.com` (linux-packages, Environment `packages`) cần duyệt mỗi lần. Chủ dự án đã cho agent tự
  duyệt (12/11/2026; quyền ghi ở `.claude/settings.local.json` của máy này):
  `gh api -X POST repos/tsudev-org/linux-packages/actions/runs/<id>/pending_deployments -F 'environment_ids[]=26928270657' -f state=approved -f comment=...`
- [ ] Nâng `rsa` 0.9 -> 0.10 khi lõi upstream nâng (xóa chấp nhận RUSTSEC-2023-0071 trong `tools/osv_scan.py`).

## Đang thực hiện

| Task | Agent | Bắt đầu |
| --- | --- | --- |

## Đã hoàn thành (mới nhất trên cùng)

- 12/11/2026 - Chủ dự án bật bắt buộc 2FA ở org `tsudev-org` (đã đo) và nộp đơn SignPath Foundation. Kho
  `pkg.tsudev.com` đã xuất bản lotus.4 (đo: `lotus-share`/`tsudev-lotus` 1.18.2-4 cho amd64 + arm64, RPM aarch64).

- 12/11/2026 (lotus-share-fc) - **Phát hành `v1.18.2-lotus.4`** (22 tệp, thêm Windows ARM64 exe/zip, Linux ARM64
  AppImage/zsync/tar.gz, CLI Linux/Windows ARM64). AppImage ARM64 (PR #32): appimage-builder chạy thẳng trên máy ARM
  (ảnh Docker chỉ amd64), phụ thuộc ghim hash `requirements-arm64.txt`, nguồn apt `ports.ubuntu.com`, `arch: aarch64`.
  Đã kiểm trên tệp thật: SHA256SUMS khớp, `gh attestation verify` trỏ `release-lotus.yml@refs/tags/v1.18.2-lotus.4`,
  từ chối tệp sửa 1 byte; AppImage ARM64 = runtime + `lotus_share` + lõi Rust đều aarch64, có thông tin cập nhật zsync.
  Website deploy lại (Tải về hiện lotus.4 + gói ARM64). Scoop + Homebrew (cả tên cũ) tự lên lotus.4, CI xanh.
  linux-packages PR #7: job `cai-thu-arm64` cài THẬT gói arm64 trên máy ARM (ubuntu 24.04, debian 12, fedora) gồm đường
  đổi tên `tsudev-lotus` -> `lotus-share` - đạt. winget #478033 qua 10 bước kiểm tự động, chờ người duyệt Microsoft.

- 12/11/2026 (lotus-share-fc) - winget: PR microsoft/winget-pkgs#478033 `tsudev.LotusShare` 1.18.2 (SHA-256 bộ cài khớp
  tệp tải về), đóng #477225, xóa nhánh `tsudev.Lotus-1.18.2`. Hướng dẫn chủ dự án `docs/vi/HUONG-DAN-KY-MA.md` (SignPath
  đối chiếu điều khoản cùng ngày; Apple: tạo chứng thư bằng openssl không cần Mac, quyền multicast) + 2 script đẩy bí
  mật; trang chính sách ký mã thêm phần tiếng Anh theo nhãn vai trò SignPath yêu cầu.
- 12/11/2026 (lotus-share-fc) - **ARM64**: `release-lotus.yml` thêm Windows ARM64 (bộ cài Inno `/DArm64` + ZIP, MSVC
  Redist ARM64 từ Visual Studio của máy chạy), Linux ARM64 (tar.gz), CLI Linux/Windows ARM64; job ARM `continue-on-error`.
  Build thử run 43139703302 xanh toàn bộ; đã tải artifact kiểm: ELF aarch64, PE 0xAA64 (exe, lõi Rust, vcruntime).
  `packaging/package.json` khai `windows-arm64`, `linux-arm64` (kho pkg.tsudev.com tự dựng .deb/.rpm arm64 từ bản sau).
  Gói .deb/.rpm x64: do `tsudev-org/linux-packages` dựng (không cần workflow trong repo này).
- 12/11/2026 (lotus-share-fc) - Gộp upstream `2e7ef197` (icon khay Snap), nâng `.standards-upstream` (PR #29).
- 12/11/2026 (lotus-share-fc) - **Kho gói đổi tên `lotus-share`** (phiếu `~/projects/logs/handover/20261112-02`):
  linux-packages #6 (tên riêng `tenRieng`, gói `.deb` chuyển tiếp `tsudev-lotus`, RPM Provides+Obsoletes; CI cài tên cũ thật
  từ pkg.tsudev.com rồi `apt upgrade`/`dnf upgrade` ra `lotus-share` - đạt 5 bản phân phối; sửa luôn lỗi xuat-ban định kỳ
  từ khi đổi tên) - đã xuất bản, đo `pkg.tsudev.com`: `lotus-share 1.18.2-3` + `tsudev-lotus 1.18.2-3` Depends lotus-share;
  scoop-bucket #2; homebrew-tap #1 (`cask_renames.json` KHÔNG chuyển máy đã cài - CI chứng minh, thay bằng cask tên cũ
  `deprecate!`). lotus-share #27 (`.desktop` "Lotus Share", `linux.formerNames`). Trang Tải về: lệnh cài `lotus-share`,
  bỏ tiền tố cũ khi nhận tệp phát hành, hướng dẫn chuyển cho máy đã cài bằng lệnh.
- 12/11/2026 - **Phát hành công khai `v1.18.2-lotus.3`** - bản Lotus Share đầu tiên (15 tệp `lotus-share-*`, có DMG macOS).
  Lần chạy đầu job macOS bị GitHub hủy (máy chạy, chưa chạy bước nào) -> xóa bản nháp, chạy lại job lỗi -> xanh toàn bộ.
  Đã kiểm trên tệp thật: SHA256SUMS khớp (DMG nằm trong tệp ký), `gh attestation verify` đạt + từ chối tệp sửa 1 byte,
  CLI in `lotus-share-cli 1.18.2`, APK định danh `com.tsudev.lotusshare`. Website deploy lại: Tải về hiện 1.18.2-lotus.3,
  11 gói, không trùng. Cloudflare: 3 Worker cũ/nhầm đã được chủ dự án xóa. Thư mục máy đổi thành `~/projects/lotus-share`.
- 12/11/2026 - Deploy `lotus.tsudev.com` bằng Worker mới `lotus-share` (tài khoản tsudev, cấu hình wrangler riêng). Đã đo:
  tiêu đề "Lotus Share | tsudev", `/ung-ho/` 200, SHA-256 ảnh QR khớp ghim, Tải về 11 gói không trùng, CSP + HSTS giữ.
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

- 12/11/2026 - Chủ dự án nộp đơn SignPath Foundation (Windows). Ký mã Apple (macOS + iOS) dời sang tháng 12/2026, làm
  khi có MacBook - không đăng ký Apple Developer trước đó.

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
