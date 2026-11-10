# Phát hành và ký mã - tsudev-lotus

> Workflow: `.github/workflows/release-lotus.yml`. Cập nhật tài liệu này mỗi khi đổi khóa, nền tảng hay chuỗi tin cậy.

## 1. Định danh của sản phẩm

| Nền tảng | Định danh | Ghi chú |
| --- | --- | --- |
| Android | `applicationId` `com.tsudev.lotus` | `namespace` Kotlin giữ `org.localsend.localsend_app` (nội bộ, gộp upstream dễ) |
| iOS / macOS | bundle `com.tsudev.lotus`, nhóm ứng dụng `group.com.tsudev.lotus` | `DEVELOPMENT_TEAM` để trống tới khi có tài khoản Apple Developer |
| Windows | `tsudev_lotus.exe`, bộ cài Inno `AppId` `{E6A866CD-B32E-4718-9EF0-CE04D53F9263}` | Không bao giờ dùng lại AppId của LocalSend: bộ cài sẽ ghi đè/gỡ LocalSend |
| Linux | ứng dụng GTK `com.tsudev.lotus`, tệp chạy `tsudev_lotus`, gói `tsudev-lotus` | AppImage tự cập nhật từ `gh-releases-zsync|tsudev-org|tsudev-lotus` |
| CLI | `tsudev-lotus-cli`, cấu hình `~/.config/tsudev-lotus-cli` | Danh tính riêng, không dùng chung với LocalSend CLI |

Vì định danh và thư mục dữ liệu khác nhau, tsudev-lotus **cài song song** được với LocalSend, nhưng hai ứng dụng
dùng chung cổng 53317 nên không nên **chạy** cùng lúc trên một máy.

## 2. Phát hành một bản mới

1. Gộp upstream nếu cần (`git fetch upstream && git merge upstream/main`), nâng `ref` trong `.standards-upstream`.
2. Phiên bản theo upstream: `app/pubspec.yaml`, `support/scripts/compile_windows_exe-inno.iss` (`MyAppVersion`),
   `cli/Cargo.toml` phải trùng nhau (CI upstream kiểm). Bản phát hành riêng của fork đánh số `-lotus.<n>`.
3. Mọi cổng kiểm xanh trên `main`, rồi gắn nhãn có chú thích và đẩy:

   ```bash
   git tag -a v1.18.2-lotus.1 -m "tsudev-lotus 1.18.2-lotus.1"
   git push origin v1.18.2-lotus.1
   ```

4. Workflow build Windows, Linux, Android, macOS, CLI; sinh SBOM, `SHA256SUMS.txt`, ký Sigstore, chứng thực SLSA, rồi
   tạo **bản nháp** phát hành. Chủ dự án kiểm (mục 4) rồi bấm Publish. Sau đó chạy lại `npm run deploy` ở `website/`
   để trang Tải về cập nhật phiên bản và SHA-256.

Chạy tay (Actions > Phát hành > Run workflow) = build thử, có ký và chứng thực nhưng không tạo bản phát hành.

## 3. Khóa và chứng thư

| Thứ | Ở đâu | Ai giữ |
| --- | --- | --- |
| Khóa ký APK (RSA 4096, PKCS12, hạn 30 năm) | `~/.config/tsudev-lotus/keys/android-release.jks` + `key.properties` (0600, NGOÀI repo) | Chủ dự án - **sao lưu ngoại tuyến**: mất khóa = người dùng phải gỡ ứng dụng để cài bản sau |
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
  --certificate-identity-regexp '^https://github.com/tsudev-org/tsudev-lotus/\.github/workflows/release-lotus\.yml@refs/tags/v.*-lotus\.[0-9]+$'

# 3) Tệp được build trên GitHub Actions từ mã nguồn của repo này (chứng thực SLSA)
gh attestation verify tsudev-lotus-<phiên bản>-windows-x86-64.exe -R tsudev-org/tsudev-lotus

# 4) APK ký bằng khóa tsudev (Android SDK build-tools)
apksigner verify --print-certs tsudev-lotus-<phiên bản>-android-universal.apk   # SHA-256 phải khớp mục 3
```

## 5. Giới hạn hiện tại (nói thẳng với người dùng)

- **Windows**: chưa ký Authenticode, SmartScreen cảnh báo ở lần chạy đầu. Hướng xử lý không tốn phí: đăng ký SignPath
  Foundation (miễn phí cho mã nguồn mở) hoặc Azure Trusted Signing khi có ngân sách; workflow chỉ cần bỏ `/DSkipSignTool`.
- **macOS**: ký ad-hoc, chưa công chứng; Gatekeeper yêu cầu "Vẫn mở". Cần Apple Developer Program (99 USD/năm).
- **iOS**: chưa phát hành được (App Store/TestFlight cần Apple Developer Program). Người dùng iOS dùng LocalSend trên App
  Store - tương thích giao thức với tsudev-lotus.
- **MSIX / menu chia sẻ Windows 11**: bỏ khỏi bản fork (gói thưa cần chứng thư ký mã); menu chuột phải dùng "Gửi tới".
