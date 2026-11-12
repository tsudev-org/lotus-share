# Phát hành và ký mã - Lotus Share

> Workflow: `.github/workflows/release-lotus.yml`. Cập nhật tài liệu này mỗi khi đổi khóa, nền tảng hay chuỗi tin cậy.

## 1. Định danh của sản phẩm

| Nền tảng | Định danh | Ghi chú |
| --- | --- | --- |
| Android | `applicationId` `com.tsudev.lotusshare` | `namespace` Kotlin giữ `org.localsend.localsend_app` (nội bộ, gộp upstream dễ) |
| iOS / macOS | bundle `com.tsudev.lotusshare`, nhóm ứng dụng `group.com.tsudev.lotusshare` | `DEVELOPMENT_TEAM` để trống tới khi có tài khoản Apple Developer |
| Windows | `lotus_share.exe`, bộ cài Inno `AppId` `{21D09887-EE8E-478B-B43F-BD492DE6EFE3}` | Không bao giờ dùng lại AppId của LocalSend: bộ cài sẽ ghi đè/gỡ LocalSend |
| Linux | ứng dụng GTK `com.tsudev.lotusshare`, tệp chạy `lotus_share`, gói `lotus-share` | AppImage tự cập nhật từ `gh-releases-zsync|tsudev-org|lotus-share` |
| CLI | `lotus-share-cli`, cấu hình `~/.config/lotus-share-cli` | Danh tính riêng, không dùng chung với LocalSend CLI |

Định danh đổi từ bản `tsudev-lotus` (`com.tsudev.lotus`, `tsudev_lotus.exe`, AppId `E6A866CD-...`) sang Lotus Share
ngày 12/11/2026 theo quyết định chủ dự án: bản cũ KHÔNG tự cập nhật; người dùng cài Lotus Share rồi gỡ bản cũ (hướng
dẫn ở trang Tải về, mục "Đã cài bản tsudev-lotus?").

Từ bản sau `1.18.2-lotus.4`, bộ cài Windows tự gỡ im lặng bản `tsudev-lotus` cũ (cùng máy, theo AppId cũ), tắt tiến
trình `tsudev_lotus.exe` và xóa khóa tự khởi động cũ, vì hai bản chạy song song tranh cổng 53420.

**Tên tệp phát hành** (từ bản sau `1.18.2-lotus.4`): bộ cài Windows `lotus-share-<ver>-windows-<x86-64|arm-64>-setup.exe`
(trước đó không có hậu tố `-setup`, dễ nhầm với CLI `.exe`), bản di động `...-windows-<arch>.zip` (giữ nguyên - Scoop
dùng), kèm `chan-doan-mang.ps1`. Đường dẫn ngắn luôn trỏ bản mới nhất: `lotus.tsudev.com/tai/<windows|android|macos|linux|
windows-arm|android-universal|linux-arm>` (sinh lúc build website vào `_redirects`, xem `docs/vi/KHAM-PHA-THIET-BI.md`
cho phần tường lửa của bộ cài).

Từ 2.0 Lotus Share có định danh, thư mục cấu hình (Windows `%APPDATA%\Lotus Share`) và giao thức mạng riêng (cổng
53420, xem `docs/vi/KHAM-PHA-THIET-BI.md`), không dùng chung gì với ứng dụng khác.

## 2. Phát hành một bản mới

1. Phiên bản: `app/pubspec.yaml` (`x.y.z+<số build>`), `support/scripts/compile_windows_exe-inno.iss` (`MyAppVersion`),
   `cli/Cargo.toml`, `support/build/appimage/*.yml` phải trùng nhau (CI `packaging` kiểm). Nhãn phát hành
   `v<x.y.z>-lotus.<n>`. **Số build tăng sau mỗi bản phát hành** - kiểm tra cập nhật so sánh bằng số build.
2. Cập nhật `website/public/phien-ban.json` (xem `docs/vi/CAP-NHAT-BAT-BUOC.md`): `moiNhat` = số build mới; nâng
   `toiThieu` khi bản cũ không còn dùng được (đổi giao thức, lỗ hổng bảo mật). Deploy website SAU khi bản phát hành
   đã Publish, để người dùng bị yêu cầu cập nhật luôn tải được bản mới.
3. Mọi cổng kiểm xanh trên `main`, rồi gắn nhãn có chú thích và đẩy:

   ```bash
   git tag -a v2.0.0-lotus.6 -m "Lotus Share 2.0.0-lotus.6"
   git push origin v2.0.0-lotus.6
   ```

4. Workflow build Windows (x64 + ARM64), Linux (x64 + ARM64), Android, macOS, CLI (x64 + ARM64); sinh SBOM, `SHA256SUMS.txt`, ký Sigstore, chứng thực SLSA, rồi
   tạo **bản nháp** phát hành. Chủ dự án kiểm (mục 4) rồi bấm Publish. Sau đó chạy lại `npm run deploy` ở `website/`
   để trang Tải về cập nhật phiên bản và SHA-256.

Chạy tay (Actions > Phát hành > Run workflow) = build thử, có ký và chứng thực nhưng không tạo bản phát hành.

Job ARM64 (`windows-arm64` trên `windows-11-arm`, `linux-arm64` trên `ubuntu-22.04-arm`, CLI ARM64) và macOS chạy
`continue-on-error`: lỗi ở đó không chặn bản x64, nhưng bản phát hành sẽ THIẾU gói đó - kiểm danh sách tệp trước khi
Publish. AppImage Linux ARM64 dựng bằng appimage-builder chạy thẳng trên máy ARM (ảnh Docker của action chỉ có
amd64), phụ thuộc Python ghim hash ở `support/build/appimage/requirements-arm64.txt`; gói `.deb`/`.rpm` arm64 do kho
`pkg.tsudev.com` dựng từ tar.gz.

## 3. Khóa và chứng thư

| Thứ | Ở đâu | Ai giữ |
| --- | --- | --- |
| Khóa ký APK (RSA 4096, PKCS12, hạn 30 năm) | `~/.config/lotus-share/keys/android-release.jks` + `key.properties` (0600, NGOÀI repo) | Chủ dự án - **sao lưu ngoại tuyến**: mất khóa = người dùng phải gỡ ứng dụng để cài bản sau |
| Bản sao cho CI | GitHub Secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD` | Đẩy bằng `tools/day-khoa-ky-android.sh` |
| Dấu vân tay chứng thư APK | Ghim trong workflow (`ANDROID_CERT_SHA256`) | Secret bị tráo thì phát hành dừng |
| Ký `SHA256SUMS.txt` | Sigstore keyless (OIDC của GitHub Actions) | Không có khóa nào để lộ |
| Authenticode (Windows), Developer ID (macOS) | Chưa có | Việc mở trong `logs/STATE.md` |

SHA-256 chứng thư APK:
`ad1be603b39b0c211c3ac4c4f890e1c85509209807a029380738089399be1f45`

## 4. Người dùng kiểm chứng tệp tải về

```bash
# 1) Tệp khớp danh sách băm
sha256sum -c --ignore-missing SHA256SUMS.txt

# 2) Danh sách băm do đúng workflow phát hành của repo này ký (Sigstore)
cosign verify-blob SHA256SUMS.txt --bundle SHA256SUMS.txt.sigstore.json \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/tsudev-org/lotus-share/\.github/workflows/release-lotus\.yml@refs/tags/v.*-lotus\.[0-9]+$'

# 3) Tệp được build trên GitHub Actions từ mã nguồn của repo này (chứng thực SLSA)
gh attestation verify lotus-share-<phiên bản>-windows-x86-64-setup.exe -R tsudev-org/lotus-share

# 4) APK ký bằng khóa tsudev (Android SDK build-tools)
apksigner verify --print-certs lotus-share-<phiên bản>-android-universal.apk   # SHA-256 phải khớp mục 3
```

## 5. Giới hạn hiện tại (nói thẳng với người dùng)

- **Windows**: chưa ký Authenticode, SmartScreen cảnh báo ở lần chạy đầu. Hướng xử lý không tốn phí: đăng ký SignPath
  Foundation (miễn phí cho mã nguồn mở) hoặc Azure Trusted Signing khi có ngân sách; workflow chỉ cần bỏ `/DSkipSignTool`.
- **macOS**: ký ad-hoc (dự án Xcode đặt `CODE_SIGN_IDENTITY = "-"`, ký thủ công, không cần đội ký Apple), chưa công
  chứng; Gatekeeper yêu cầu "Vẫn mở". Có Developer ID thì đổi lại ký tự động + `DEVELOPMENT_TEAM`.
- **iOS**: chưa phát hành được (App Store/TestFlight cần Apple Developer Program, kế hoạch tháng 12/2026).
- **MSIX / menu chia sẻ Windows 11**: không dùng (gói thưa cần chứng thư ký mã); menu chuột phải dùng "Gửi tới".
