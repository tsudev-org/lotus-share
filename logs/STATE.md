# STATE.md - Trạng thái project Lotus Share (repo tsudev-org/lotus-share, trước đây tsudev-lotus)

> **Phiên kế tiếp (phiếu toàn hệ 20261117-P2):** đọc `~/projects/logs/handover/20261117-P2_ke-hoach-phan-phoi-tin-cay-da-nen-tang.md` hàng 3 (`lotus-share`) ở mục 3
> và `.standards/docs/DISTRIBUTION_TRUST.md` (chuẩn v3.7.0) + `.standards/docs/VERSIONING.md` mục 2. Khuôn thẻ/tên tệp mới chỉ áp
> cho bản phát hành KẾ TIẾP, đọc mục 2.4 (updater đã cài) trước khi đổi.

> **Phiên kế tiếp (từ 20/11/2026): đọc TRƯỚC phiếu `logs/handover/20261119-03_ban-giao-phien-sau-uy-quyen-moi.md`** - ủy
> quyền mới của chủ dự án 19/11 (tự duyệt/gộp PR + xử lý GitGuardian; tự mở trình duyệt nộp báo nhầm antivirus và lập
> phiếu cho mọi repo cần nộp; tự làm việc phía agent của `docs/vi/APPLE-IOS-MACOS.md`) kèm giới hạn, và thứ tự việc.

> Agent đọc file này ở đầu mỗi phiên và cập nhật ở cuối mỗi phiên.
> Quy trình: `.standards/docs/AGENT_PROTOCOL.md`.

## Hàng đợi task (làm từ trên xuống)

- [ ] 👤 **Duyệt `xuat-ban` của linux-packages** (2 run chờ: 44332608025, 44376379671 + lượt mới) để APT/RPM lên
      `lotus-share 26.11.1901` - người đang dùng 26.11.1801 qua APT/RPM KHÔNG mở được ứng dụng tới lúc đó. Agent đo
      `pkg.tsudev.com/catalog.json` sau khi duyệt.
- [ ] 👤 GitGuardian sự cố 40268788 ("Generic Password", `scripts/apple/nhap-khoa.sh` dòng 7 ở commit 02ad20e): báo nhầm
      (chỉ kiểm biến môi trường, không có giá trị) - đánh dấu false positive trên dashboard. Mã đã viết lại.
- [ ] Báo nhầm antivirus **26.11.1901** (4 tệp Windows, 1-2/74 engine - bảng trong Release notes): quét lại + nộp như
      26.11.1801 (phiếu `20261118-02` mục 6).
- [ ] Dependabot #82 (cargo, 5 gói) + #83 (pub, 30 gói): CHƯA gộp - xem kỹ từng gói (sự cố 26.11.1801 đến từ lượt nâng
      hàng loạt); cổng `frb_version_test` + `apple.yml` (Simulator/macOS chạy thử) phải xanh. `libc` >= 0.2.191 cần bản
      chép `nix` (packages/vendor) - giữ khi nâng.
- [ ] Báo nhầm antivirus 26.11.1801: ĐÃ NỘP cả 3 hãng 19/11 (phiếu `logs/handover/20261118-02_*`). Từ 20/11: quét lại
      VirusTotal (workflow tạm dùng `VT_API_KEY`, mục 3.2), ghi số engine; theo dõi thư trả lời ở dev.nguyentrangtinhsu@gmail.com.
- [ ] winget: khi PR microsoft/winget-pkgs#478033 (2.0.0) được gộp, gửi PR cập nhật `tsudev.LotusShare` **26.11.1901**
      (KHÔNG dùng 26.11.1801 - bản lỗi; bộ cài `lotus-share_26.11.1901_windows-{x64,arm64}-setup.exe`, SHA-256 từ SHA256SUMS.txt).
- [ ] winget `tsudev.LotusShare`: chờ người kiểm duyệt cộng đồng duyệt PR microsoft/winget-pkgs#478033 (18/11 đã nâng
      manifest lên **2.0.0** + bộ cài arm64; SHA-256 đo trên tệp tải về). Khi merge: chuyển `winget` từ `planned` sang
      `channels` trong `packaging/package.json`; khối "Cài bằng lệnh" tự hiện lệnh winget ở lần build/deploy kế tiếp.
- [ ] **Phát hành kế tiếp theo khuôn V1** (`v26.M.DDNN`, phiếu `logs/handover/20261117-V1_*` mục 6 - khảo sát đã xong):
      số build = `YYMDDNN`; AppImage + `.zsync` GIỮ tên cũ (AppImage đã cài dò `lotus-share-*-linux-x86-64.AppImage.zsync`);
      đổi cùng PR `packaging/package.json` tagRegex/assets, scoop-bucket checkver/autoupdate, homebrew-tap livecheck,
      bước `prepare` của `release-lotus.yml`, `phien-ban.json`. Kèm P1 phiếu P2: VirusTotal (workflow dùng chung
      `tsudev-org/.github`, chờ Sound Db phát hành thật kiểm mẫu).
- [ ] SignPath: bảng 6 ngưỡng ĐÃ soạn (phiếu 20261115-01, Kết quả 18/11): 0/6 đạt trọn, chưa nộp lại. Đo lại hằng
      tuần (lệnh ghi trong phiếu), chép dòng tổng vào mục 7 `~/projects/logs/handover/20261113-02_*`.
- [ ] **Thử thật 2.0.0-lotus.7** (đã phát hành 13/11/2026): mọi thiết bị cùng cài 2.0 (1.x không thấy 2.x). Windows cài
      `lotus.tsudev.com/tai/windows` (cài cho mọi người dùng, giữ dấu chọn tường lửa; bộ cài gỡ `tsudev-lotus` cũ) - lần
      đầu mở có tên thiết bị tiếng Việt mới, thấy cả Android lẫn laptop Linux; laptop Linux chạy
      `bash chan-doan-mang.sh` (trong tar.gz; `--sua` mở cổng 53420 ufw/firewalld). Hộp thoại cập nhật chỉ thử thật được
      khi phát hành build 66 (URL tệp phiên bản cố định trong ứng dụng). Chi tiết `docs/vi/KHAM-PHA-THIET-BI.md`.
- [ ] Phiếu cả hệ `~/projects/logs/handover/20261112-04_yeu-cau-bat-buoc-cap-nhat-he-sinh-thai.md`: theo dõi mục Kết quả.
- [ ] **Apple (iOS + macOS)** - PR #80 ĐÃ GỘP (`apple.yml` xanh: Simulator mở app tiếng Việt, macOS mở app; script ký
      viết sẵn, `docs/vi/APPLE-IOS-MACOS.md`, `docs/store/app-store.md`). Còn: 👤 thử iPhone thật bằng `.ipa` không ký (mục 2 tài liệu, ghi kết quả
      `logs/thu-thiet-bi/`); khi có Mac + Apple Developer (đầu 2027): làm mục 4 tài liệu - xin quyền multicast NGAY,
      ghim `APPLE_TEAM_ID_GHIM`, thử sandbox macOS trên Mac thật. Phiếu toàn hệ `~/projects/logs/handover/20261119-AP1_*`.
- [ ] Nâng `rsa` 0.9 -> 0.10 khi lõi upstream nâng (xóa chấp nhận RUSTSEC-2023-0071 trong `tools/osv_scan.py`).

## Đang thực hiện

| Task | Agent | Bắt đầu |
| --- | --- | --- |

## Đã hoàn thành (mới nhất trên cùng)

- 19/11/2026 (lotus-share-fc) - **SỰ CỐ 26.11.1801 + bản sửa `v26.11.1901`**: 26.11.1801 không mở được trên Windows,
  Linux, macOS, Android (màn hình lỗi "codegen version (2.12.0) should be the same as runtime version (2.13.0)"); CLI
  không ảnh hưởng. Nguyên nhân: `ceb85a9d` (nâng phụ thuộc) nâng gói Dart `flutter_rust_bridge` 2.13.0, mã sinh + crate
  Rust `=2.12.0`. Phát hiện nhờ ảnh chụp macOS của `apple.yml` (PR #80). Sửa #81: ghim Dart `2.12.0`, test
  `frb_version_test` (kiểm ngược: lock 2.13.0 => đỏ), Dependabot bỏ qua gói này. Phát hành `v26.11.1901` (22 tệp,
  SHA256SUMS khớp, `gh attestation verify` đạt); VirusTotal gắn cờ 4 tệp Windows 1-2/74 => chủ dự án chọn **Publish
  ngay** (01:11 UTC, ghi chú VirusTotal + thông báo bản sửa trong Release notes). PR #84 `phien-ban.json` 26111901 + deploy
  (đo: `/tai/*` 7 đường dẫn -> 26.11.1901). Scoop + Homebrew tự lên 26.11.1901 (hash khớp). Bài học: phép chạy thử phải
  bắt màn hình lỗi khởi động (`LOTUS_SHARE_INIT_ERROR: `, `app/lib/config/init_error.dart`).
- 19/11/2026 (lotus-share-fc) - **Apple** PR #80: `apple.yml` (iOS không ký + Simulator, macOS chạy thử, ảnh chụp),
  PrivacyInfo, bỏ `aps-environment`, `scripts/apple/*` + bước gated trong `release-lotus.yml`, tài liệu + hồ sơ App
  Store. iOS cần vá `nix` 0.26.4 (`libc` 0.2.191 bỏ `sockaddr_ctl` trên iOS) => bản chép `packages/vendor/nix-0.26.4` +
  `[patch.crates-io]`; CodeQL bỏ qua `packages/vendor/**` (chủ dự án đồng ý). Phiếu toàn hệ AP1 gửi phiên điều phối.
- 19/11/2026 (lotus-share-fc) - **TC2** PR #85: TsuFiles không còn là client giao thức; hợp đồng "mở kèm tệp"
  `docs/MO-KEM-TEP.md` + test khóa; bỏ tên TsuFiles khỏi `GIAO-THUC-LOTUS-V2.md`. tsufiles#119 đã dùng.

- 19/11/2026 (lotus-share-fc) - **T3 + T2 (phần Lotus Share)** PR #79: app người dùng mới theo ngôn ngữ + giao diện hệ
  thống (chưa có bản dịch => tiếng Anh), `_migrate6` giữ tiếng Việt + Tối cho máy đã cài chưa từng chọn; test bắt buộc
  PRODUCT_POLICY 1.4 (`system_defaults_test.dart`). Website `tsudev-theme` mặc định `system` (check-theme kiểm khách mới
  theo máy). Chữ hiển thị `TsuDEV` (website, bản dịch vi/en, CompanyName/LegalCopyright, AppPublisher Inno, CLI,
  README); định danh máy đọc giữ nguyên. Tím hoa sen giữ (chủ dự án chốt 19/11). Áp vào bản phát hành kế tiếp.
- 19/11/2026 (lotus-share-fc) - Kho APT/RPM: chủ dự án đã duyệt run 44113082063; đo `pkg.tsudev.com`: `lotus-share` +
  `tsudev-lotus` 26.11.1801-1 (amd64, arm64), RPM x86_64/aarch64 trong `catalog.json`, tệp trả 200. Còn 2 run
  `xuat-ban` chờ duyệt (44332608025, 44376379671) - không chặn Lotus Share.

- 18/11/2026 (lotus-share-9c) - **Phát hành `v26.11.1801`** (chủ dự án ủy quyền): Publish 15:53 UTC (ngoại lệ VirusTotal
  có ghi, phiếu 20261118-02); PR #72 (package.json + phien-ban.json `moiNhat` 26111801); website deploy - đo production:
  `/tai/*` 7 đường dẫn 302 tới tệp 26.11.1801, `phien-ban.json` mới, trang Tải về hiện 26.11.1801. Scoop
  scoop-bucket#23 (`lotus-share` + `tsudev-lotus`, hash đo trên tệp), Homebrew homebrew-tap#12 (2 cask + `cap-nhat.py`,
  CI nâng cấp thật tên cũ đạt). Mô tả kênh bỏ "tương thích/bản Việt hóa LocalSend". Phiếu V1 mục 6 đã ghi.

- 18/11/2026 (lotus-share-9c) - **Khuôn phiên bản V1** (PR #69): `26.11.1801+26111801`, nhãn `vYY.M.DDNN`, tệp
  `lotus-share_{ver}_{os}-{arch}` (AppImage giữ tên cũ - ngoại lệ AGENTS B.4), Runner.rc FileVersion `YY.M.DDNN.0` (số
  build cũ tràn 16 bit), job VirusTotal dùng chung. Build thử 44312597517 kiểm trên tệp: APK versionCode 26111801,
  FileVersion 26.11.1801.0, CLI `--version`, AppImage giữ thông tin zsync. Ruleset nhãn mở rộng `refs/tags/v*`. Nhãn
  `v26.11.1801` đã đẩy; run 44320817020 dựng đủ 22 tệp, VirusTotal gắn cờ 4 tệp Windows -> nháp (phiếu 20261118-02).

- 18/11/2026 - Chủ dự án xóa bản nháp Release `v2.0.0-lotus.6` (đo: `release not found`, nhãn còn trên origin).

- 18/11/2026 (lotus-share-a1) - **PR #66** (gộp, CI xanh 13 kiểm): nâng phụ thuộc Rust/Dart trong phạm vi tương thích
  thay Dependabot #8 (kéo `chrono-tz 0.10.4` dính RUSTSEC-2026-0555 + `webrtc` phá API) và #65 (`test ^1.32` không giải
  được) - đã đóng cả hai kèm ghi chú; **#60** clippy lõi `-D warnings` (sửa hết cảnh báo, ngoại lệ có lý do ở
  `packages/core/clippy.toml`) + CI chạy test CLI; **#58** CLI kiểm `phien-ban.json` lúc khởi động (`cli/src/update_check.rs`,
  bỏ kiểm `--khong-kiem-cap-nhat`), chạy thật với production: build 65 chạy tiếp, tạm hạ build 60 -> thoát 1. Bảng 6
  ngưỡng SignPath (0/6, Scorecard 6.8).

- 18/11/2026 (lotus-share-5e) - **Bảo mật + uy tín + giao diện** (nhận #49/#51 từ phiên điều phối projects-e4):
  #49 quy ước v3.7.0 + astro/marked về devDependencies (chủ dự án chọn phương án (a), phiếu 20261118-01 mục 3.3) +
  chấp nhận RUSTSEC-2026-0543; #51 ci.yml ghim SHA + `permissions: contents: read` (7 cảnh báo CodeQL Actions);
  #55 AppImage ARM64 urllib3 2.8.0 + lief 0.17.6 (9 cảnh báo Dependabot; build thử THẬT run 44165028549
  xanh cả 12 job, gồm Linux ARM64); #54 client `danger_accept_invalid_certs` chỉ còn sau tính năng `test-util` (CodeQL
  rust/disabled-certificate-check); #56 (Dependabot actions); phát hiện + sửa lỗ hổng thừa kế: công thức
  appimage-builder để `allow_unauthenticated: true` (thư viện đóng vào AppImage tải qua HTTP KHÔNG kiểm chữ ký, log
  `NO_PUBKEY 871920D1991BC93C`) - ghim khóa Ubuntu Archive 2018, bỏ
  `allow_unauthenticated` (#61; build thử run 44169959283 x64 + ARM64 xanh, `NO_PUBKEY` 0). Uy tín: #53 README
  tiếng Anh (README.vi.md) + OpenSSF Scorecard; #57 hồ sơ Best Practices `docs/best-practices.json`, CHANGELOG ghi
  RUSTSEC đã vá, CONTRIBUTING/SECURITY tiếng Anh; issue good first #58 #59 #60. Giao diện (phiếu 20261113-07): quét
  production 10 trang x 390/1280 x Tối/Sáng = OK; soi ảnh thấy chân trang di động một cột dài -> #52 lưới 2 cột.
  winget-pkgs#478033 nâng 2.0.0. Phiếu V1: khảo sát updater (mục 6 bản sao). **OpenSSF Best Practices passing 100%**
  (dự án 16860, nộp bằng `bp.cjs`, huy hiệu README). Website deploy (Version 30616e5e): quét production 7 trang OK.
  Scorecard 6.5 (đo 18/11 sau huy hiệu; trừ điểm không sửa được: Maintained - repo < 90 ngày, Code-Review - một người
  bảo trì, Fuzzing). Sửa được (#63): ghim digest ảnh Docker `server/Dockerfile` + Dependabot docker; bỏ 3 DLL MSVC x64
  khỏi repo (lấy từ Redist Visual Studio của máy chạy, kiểm chữ ký Authenticode Microsoft).

- 12-13/11/2026 (lotus-share-9e) - **Phát hành `v2.0.0-lotus.7` - Lotus Share độc lập** (chủ dự án đồng ý phát hành):
  PR #38 (máy Linux không hiện: bỏ quét mạng con khi đã có thiết bị trả lời; Windows dùng chung `settings.json` với
  LocalSend -> tên "Strategic Tomato"; tên tiếng Anh tự đổi sang tiếng Việt; nút sửa tường lửa Linux;
  `chan-doan-mang.sh`), PR #39 (giao thức riêng 53420 / `224.0.0.168` / `ff12::1075:5ea0` / `/api/lotus/v2`, di trú
  cấu hình v5, gỡ workflow/tài nguyên/liên kết LocalSend, vendor `device_apps` + `permission_handler_windows`, trang
  Giới thiệu + Giấy phép mới, bắt buộc cập nhật qua `phien-ban.json`, 2.0.0+65), PR #42 (hằng multicast Rust vẫn
  224.0.0.167 -> CLI nghe sai nhóm; test `protocol_constants.rs` đối chiếu Dart/Rust). Nhãn `v2.0.0-lotus.6` KHÔNG
  phát hành (bản nháp đã xóa vì lỗi CLI; nhãn bất biến nên còn lại). Kiểm trên tệp thật lotus.7: 22 tệp, SHA256SUMS
  khớp, `gh attestation verify` đạt + từ chối tệp sửa 1 byte, CLI nghe UDP/TCP 53420 và tham gia `224.0.0.168` (đo
  `/proc/net/igmp`), `/api/localsend/v2/info` 404. Website deploy: `/tai/{windows,windows-arm,android,linux,macos}` =
  302 tới tệp lotus.7, `phien-ban.json` 200 `max-age=300`. Scoop + Homebrew `2.0.0-lotus.7`; pkg.tsudev.com APT
  `lotus-share 2.0.0-7` amd64/arm64 (agent duyệt run 43267747308). Phiếu cả hệ bắt buộc cập nhật: `~/projects/logs/handover/20261112-04_yeu-cau-bat-buoc-cap-nhat-he-sinh-thai.md`
  (tsudev: không áp dụng; tsudev-files: làm ở 2.4.1).

- 12/11/2026 (lotus-share-d7) - **Phát hành `v1.18.2-lotus.5`** (chủ dự án đồng ý): sửa khám phá thiết bị + bộ cài tường
  lửa (PR #35). 22 tệp, bộ cài mang tên `-setup.exe`. Đã kiểm trên tệp thật: SHA256SUMS khớp, `gh attestation verify` đạt
  + từ chối tệp sửa 1 byte, APK có `CHANGE_WIFI_MULTICAST_STATE`, ZIP Windows có `chan-doan-mang.ps1`. Website deploy lại,
  `/tai/windows` -> `...-windows-x86-64-setup.exe` lotus.5. Scoop + Homebrew tự lên lotus.5 (đo tệp trong repo). Kho
  pkg.tsudev.com: chờ chủ dự án duyệt (mục đầu hàng đợi).

- 12/11/2026 (lotus-share-d7) - **Sửa "không thấy nhau" + chuẩn hóa bộ cài/tải về** (PR #35, đã gộp; website đã deploy,
  đo `/tai/windows` = 302). Build thử run 43191034629 xanh mọi nền tảng; bộ cài x64 cài/gỡ thật (chế độ người dùng)
  trên máy phát triển đạt, lối tắt tiếng Việt đúng: lõi Rust gửi thêm
  broadcast có hướng song song multicast + chống trả lời trùng; Android giữ MulticastLock; card mạng ảo/VPN xếp cuối
  khi quét; bộ cài Inno tạo/xóa quy tắc tường lửa theo chương trình (xóa cả quy tắc Chặn), tự gỡ `tsudev-lotus` cũ, xóa
  khóa tự khởi động khi gỡ; công cụ `chan-doan-mang.ps1` (menu Start + ZIP; đã chạy thật trên máy phát triển); bộ cài
  đổi tên `-setup.exe`; website khối Tải nhanh + `/tai/<nen-tang>` (302, `_redirects`) + mục "Không thấy thiết bị?".
  Phiếu đồng bộ cả hệ: `~/projects/logs/handover/20261112-03_yeu-cau-bo-cai-chuan-tuong-lua-chan-doan-mang.md`.

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

- 12/11/2026 - **Chủ dự án: Lotus Share là sản phẩm độc lập**, loại bỏ cấu hình/cơ chế/thông tin LocalSend. THAY THẾ các
  quyết định cũ "giữ tương thích giao thức LocalSend v2" và "giữ tên nội bộ để gộp upstream": giao thức riêng (cổng
  53420, `224.0.0.168`, `/api/lotus/v2/`), không gộp upstream nữa, bỏ remote `upstream` + `.standards-upstream`. Giữ dòng
  bản quyền gốc trong LICENSE/NOTICE/thông tin tệp chạy (Apache-2.0 mục 4c bắt buộc); trong app chỉ hiện ở Giấy phép.
- 12/11/2026 - Chủ dự án: bản cũ phải hiện hộp thoại bắt buộc cập nhật; áp dụng cả hệ (phiếu 20261112-04). Phiên bản
  2.0.0+65; so sánh bằng số build.
- 13/11/2026 - Chủ dự án chọn ký mã Windows TRẢ PHÍ (hướng 2) và hỏi chi phí cho cả hệ; agent đề xuất Certum Open
  Source (~€49/năm cả hệ) + Apple $99/năm. Chưa chốt nhà cung cấp, chưa mua (phiếu 20261113-02).
- 12/11/2026 - SignPath Foundation từ chối đơn đầu (lý do: dự án chưa đủ mức độ được biết đến công khai; mời nộp
  lại). Bản Windows tiếp tục chưa ký Authenticode; `CODE_SIGNING.md` ghi trạng thái thật.
- 13/11/2026 - Agent: `v2.0.0-lotus.6` bỏ (CLI sai nhóm multicast, chưa từng công khai), phát hành `v2.0.0-lotus.7` giữ
  build 65. Nhãn chỉ dùng một lần; bản kế tiếp là build 66.

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
