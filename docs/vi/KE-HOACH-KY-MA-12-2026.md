# Kế hoạch ký mã tháng 12/2026 - Windows (SignPath Foundation) + Apple (macOS, iOS)

> Lập: 10/11/2026. Thực hiện: **đầu tháng 12/2026**, khi chủ dự án đã có tài khoản **Apple Developer Program**.
> Hai việc làm cùng đợt vì cùng đụng `.github/workflows/release-lotus.yml`, `docs/vi/PHAT-HANH.md`, trang Tải về, và
> cùng kết thúc bằng một bản phát hành mới (`v<phiên bản>-lotus.<n+1>`).
>
> **Cập nhật 13/11/2026**: SignPath Foundation từ chối đơn đầu (12/11/2026) vì dự án chưa đủ mức độ được biết đến công
> khai; mời nộp lại sau. Phần 1 tạm dừng tới khi nộp lại được duyệt - xem `logs/STATE.md`.
>
> **Việc của chủ dự án** (đơn SignPath, tài khoản/chứng thư Apple): làm theo [`HUONG-DAN-KY-MA.md`](HUONG-DAN-KY-MA.md).
> Tài liệu này là phần việc của AGENT. Đối chiếu điều khoản SignPath + tài liệu action lần gần nhất: 12/11/2026.
>
> **Bắt buộc trước khi làm**: các chi tiết về SignPath dưới đây viết theo hiểu biết tại thời điểm lập kế hoạch. Agent
> `MUST` đọc lại trang chính thức (mục 1.1) và sửa tài liệu này nếu điều kiện, URL hay tên tham số đã đổi.

## 0. Hiện trạng (để biết đang thay cái gì)

| Nền tảng | Hiện tại (v1.18.2-lotus.2) | Sau đợt này |
| --- | --- | --- |
| Windows | Không ký Authenticode, SmartScreen cảnh báo | Ký bởi chứng thư của **SignPath Foundation** (miễn phí cho mã nguồn mở) |
| macOS | Ký ad-hoc (`CODE_SIGN_IDENTITY = "-"`), Gatekeeper chặn lần đầu | Ký **Developer ID Application** + công chứng (notarize) + staple |
| iOS | Chưa phát hành | TestFlight, sau đó App Store |
| Android | Ký khóa tsudev, ghim dấu vân tay | Giữ nguyên |
| Mọi gói | SHA256SUMS ký Sigstore + chứng thực SLSA | Giữ nguyên (ký Authenticode/Apple là lớp THÊM, không thay) |

---

## 1. Windows: chứng thư ký mã miễn phí qua SignPath Foundation

### 1.1. Đọc điều kiện chính thức (bắt buộc, trước mọi bước khác)

- Trang chủ, điều khoản, đơn đăng ký: <https://signpath.org> (mục "Apply", "Terms").
- Tài liệu tích hợp GitHub Actions: <https://docs.signpath.io> (mục "Trusted build systems" / "GitHub").
- Ghi lại vào phiếu bàn giao: ngày đọc, điều kiện nào đã đổi so với mục 1.2.

### 1.2. Điều kiện thường gặp và tình trạng của Lotus Share (đối chiếu lại ở 1.1)

| Điều kiện | Lotus Share | Việc cần làm |
| --- | --- | --- |
| Giấy phép mã nguồn mở được OSI công nhận | Apache-2.0 | Không |
| Mã nguồn công khai, đang được bảo trì, đã có bản phát hành | Repo công khai, v1.18.2-lotus.2 | Không |
| Không chứa thành phần độc quyền/đóng | Bản Android đã bỏ `in_app_purchase`; bản Windows không có | Kiểm lại `app/pubspec.yaml` lúc nộp |
| Build trên CI có xác minh nguồn gốc (GitHub-hosted runner) | `release-lotus.yml` chạy trên runner của GitHub | Tích hợp action của SignPath (1.5) |
| Mọi thành viên có quyền commit/duyệt bật **MFA** (GitHub và SignPath) | Chủ dự án | Bật MFA cho tài khoản `tsudev-tsudev` nếu chưa; bật "Require 2FA" ở org `tsudev-org` |
| Trang **chính sách ký mã** công khai trên website dự án, nêu vai trò (tác giả, người duyệt, người phê duyệt) và câu ghi công SignPath | Chưa có | Làm trang `lotus.tsudev.com/chinh-sach-ky-ma/` (1.3) |
| Tuyên bố quyền riêng tư: chương trình không gửi thông tin ra hệ thống mạng khác nếu người dùng không yêu cầu | Ứng dụng phát gói multicast trong LAN (tên thiết bị) để tìm máy - chức năng cốt lõi, người dùng chủ động mở ứng dụng | Ghi trung thực trên trang chính sách: dữ liệu chỉ đi trong mạng nội bộ, không ra Internet, WebRTC tắt |

### 1.3. Chuẩn bị trang chính sách ký mã (làm TRƯỚC khi nộp đơn)

1. Tạo `website/src/pages/chinh-sach-ky-ma.astro` (dùng `TaiLieu.astro`), thêm vào `TRANG` trong
   `website/src/pages/sitemap.xml.ts` và menu `TaiLieu.astro`. Nội dung (tiếng Việt + một đoạn tiếng Anh cho người xét
   duyệt của SignPath):
   - Câu ghi công đúng nguyên văn SignPath yêu cầu (lấy ở 1.1), dạng: "Free code signing provided by SignPath.io,
     certificate by SignPath Foundation".
   - Vai trò: Tác giả (committer) = `tsudev-tsudev`; Người duyệt (reviewer) = `tsudev-tsudev`; Người phê duyệt ký
     (approver) = `tsudev-tsudev`. Ghi rõ mọi thay đổi vào `main` phải qua PR + 11 kiểm tra bắt buộc (ruleset).
   - Quyền riêng tư: liên kết `https://tsudev.com/privacy` + mô tả mục 1.2 dòng cuối.
   - Liên kết `docs/vi/PHAT-HANH.md` (cách kiểm chứng gói).
2. `cd website && npm run build` (check-dist 0 lỗi) -> PR -> sau merge chủ dự án chạy `npm run deploy`.

### 1.4. Nộp đơn (chủ dự án làm, agent soạn sẵn nội dung)

1. Agent soạn sẵn câu trả lời cho form trong `logs/handover/` (tên dự án, URL repo, URL trang chính sách, mô tả ngắn,
   giấy phép, số người đóng góp, nền tảng build = GitHub Actions, tệp cần ký: `lotus_share.exe`, các DLL của ứng dụng,
   bộ cài `lotus-share-<ver>-windows-x86-64-setup.exe`, CLI `lotus-share-cli-<ver>-windows-x86-64.exe`).
2. Chủ dự án nộp ở trang "Apply" (1.1). Thời gian xét duyệt có thể vài tuần - ghi ngày nộp vào `logs/STATE.md`.
3. Khi được duyệt, SignPath cấp: tài khoản tổ chức (Organization ID), dự án (project slug), chính sách ký
   (signing policy slug, thường `release-signing`), và cách tạo API token cho CI.

### 1.5. Tích hợp vào `release-lotus.yml` (sau khi được duyệt)

1. **Secret/biến** - chủ dự án chạy `tools/dat-bien-signpath.sh` (đã có): secret `SIGNPATH_API_TOKEN` (người dùng CI,
   vai trò Submitter); Variables `SIGNPATH_ORGANIZATION_ID`, `SIGNPATH_PROJECT_SLUG`, `SIGNPATH_POLICY_SLUG`.
   Action đã đối chiếu 12/11/2026: `signpath/github-action-submit-signing-request@v3` (ghim SHA khi dùng). Đầu vào:
   `api-token`, `organization-id`, `project-slug`, `signing-policy-slug`, `artifact-configuration-slug` (tùy chọn),
   `github-artifact-id` (BẮT BUỘC: `outputs.artifact-id` của bước `actions/upload-artifact` có `id`),
   `wait-for-completion` (mặc định true), `wait-for-completion-timeout-in-seconds` (mặc định 600 - nâng lên vì người
   duyệt bấm tay), `output-artifact-directory` (thiếu thì không tải bản đã ký về). `upload-artifact` mặc định nén ZIP nên
   gốc cấu hình artifact phải là `<zip-file>`; dùng `archive: false` thì đặt `skip-decompress: true`. Repo công khai:
   không cần thêm quyền `actions: read`.
2. **Cấu hình artifact trên SignPath** (artifact configuration, XML): khai báo gói ZIP chứa `*.exe`, `*.dll` của
   ứng dụng cần ký Authenticode; cấu hình thứ hai cho bộ cài Inno đơn lẻ.
3. **Thứ tự ký trong job Windows** (bộ cài nhúng các tệp đã ký nên phải ký 2 lượt):
   1. Build `flutter build windows` -> nén thư mục `Release` thành artifact `windows-unsigned`.
   2. Gửi yêu cầu ký bằng action chính thức của SignPath (tên action và tham số lấy ở 1.1, ghim theo SHA như mọi
      action khác), chờ hoàn tất, tải về thư mục đã ký.
   3. Kiểm chữ ký tại chỗ: `Get-AuthenticodeSignature lotus_share.exe` phải `Valid`, `SignerCertificate.Subject` chứa
      `SignPath Foundation` - GHIM chuỗi Subject/Thumbprint trong workflow giống cách ghim chứng thư APK.
   4. Dựng ZIP di động từ thư mục đã ký; dựng bộ cài Inno từ thư mục đã ký với `/DSkipSignTool`.
   5. Gửi bộ cài lên SignPath ký lượt 2, kiểm lại như bước 3. (Trình gỡ cài đặt nhúng trong bộ cài sẽ không được ký
      Authenticode - chấp nhận được; ghi vào `docs/vi/PHAT-HANH.md` mục 5.)
   6. CLI Windows: thêm vào yêu cầu ký lượt 1 (hoặc lượt riêng).
   7. Làm cho CẢ job `windows-arm64` và CLI ARM64 (thêm từ 12/11/2026): tệp `*-windows-arm-64.*`.
4. Mỗi yêu cầu ký cần **người phê duyệt bấm duyệt** trên SignPath (theo chính sách) - workflow sẽ chờ. Ghi vào
   `docs/vi/PHAT-HANH.md` mục 2: sau khi đẩy nhãn, mở SignPath để duyệt.
5. Thử trước bằng `gh workflow run release-lotus.yml --ref <nhánh>` (build thử, KHÔNG gắn nhãn) - SignPath có chính
   sách thử (test-signing) nếu được cấp; nếu không, chỉ thử đến bước gửi yêu cầu.

### 1.6. Hoàn tất

- `docs/vi/PHAT-HANH.md`: bảng mục 3 thêm dòng Authenticode (SignPath), mục 4 thêm
  `Get-AuthenticodeSignature`, mục 5 bỏ cảnh báo SmartScreen (SmartScreen vẫn có thể cảnh báo vài tuần đầu cho tới
  khi chứng thư tích lũy uy tín - nói rõ).
- Trang Tải về (`website/src/pages/tai-ve.astro`): đổi đoạn "Bản Windows hiện chưa có chứng thư" thành thông tin nhà
  phát hành là "SignPath Foundation" và cách xem chữ ký (chuột phải > Properties > Digital Signatures).

---

## 2. Apple: macOS Developer ID + công chứng, iOS TestFlight/App Store

### 2.1. Chủ dự án chuẩn bị (agent không làm thay được)

> Lịch (12/11/2026): chủ dự án làm vào tháng 12/2026 khi có MacBook. Có MacBook thì agent build + chạy thử bản macOS
> đã ký/công chứng trên máy thật (Gatekeeper: `spctl -a -vv`, `stapler validate`) trước khi phát hành.

1. Đăng ký Apple Developer Program (99 USD/năm). Cá nhân: dùng Apple ID có xác thực 2 yếu tố. Tổ chức: cần số
   D-U-N-S - lâu hơn, nên chọn cá nhân nếu muốn kịp đầu tháng 12.
2. Ghi lại **Team ID** (10 ký tự) - agent sẽ ghim vào workflow.
3. Trong Certificates, Identifiers & Profiles:
   - App ID `com.tsudev.lotusshare` (iOS) và `com.tsudev.lotusshare` (macOS), kèm `com.tsudev.lotusshare.ShareExtension`; bật
     capability **App Groups** với nhóm `group.com.tsudev.lotusshare` (iOS) - khớp `app/ios/Runner/Runner.entitlements`.
   - Chứng thư **Developer ID Application** (macOS ngoài App Store) và **Apple Distribution** (iOS). Xuất `.p12` có
     mật khẩu, lưu NGOÀI repo: `~/.config/lotus-share/keys/apple/` (quyền 0600), sao lưu ngoại tuyến.
4. App Store Connect > Users and Access > Integrations: tạo **API key** (vai trò App Manager) -> Issuer ID, Key ID,
   tệp `.p8` (chỉ tải được một lần). Dùng cho `notarytool` và tải bản iOS lên TestFlight.
5. Tạo ứng dụng trong App Store Connect với bundle `com.tsudev.lotusshare`, tên "Lotus Share".

### 2.2. Agent làm (sau khi có các thứ ở 2.1)

1. Script `tools/day-khoa-apple.sh` (đã có) - Secrets `APPLE_DEVID_P12_BASE64`, `APPLE_DIST_P12_BASE64` (.p12 3DES),
   `APPLE_P12_PASSWORD`, `APPLE_ASC_KEY_P8_BASE64`; Variables (không bí mật) `APPLE_TEAM_ID`, `APPLE_ASC_KEY_ID`,
   `APPLE_ASC_ISSUER_ID`. Ghim Team ID trong workflow và so với `vars.APPLE_TEAM_ID`.
   Trước đó dọn mã: bỏ `aps-environment` khỏi `app/ios/Runner/Runner.entitlements` (không dùng push - tránh phải bật
   Push Notifications); thêm `app/ios/Runner/PrivacyInfo.xcprivacy` (chưa có ở cấp ứng dụng; khai API "required reason"
   mà mã Dart/Rust dùng, đối chiếu manifest của từng plugin). Quyền multicast phải được Apple duyệt (HUONG-DAN B3) - chưa
   duyệt thì TestFlight build được nhưng không tìm thấy thiết bị.
2. Mã nguồn:
   - `app/ios/Runner.xcodeproj/project.pbxproj`, `app/macos/Runner.xcodeproj/project.pbxproj`: `DEVELOPMENT_TEAM` =
     Team ID. macOS: bản Release ký thủ công bằng "Developer ID Application", bật Hardened Runtime; giữ ad-hoc cho
     Debug để lập trình viên không có tài khoản vẫn build được.
   - Nhóm ứng dụng macOS `$(AppIdentifierPrefix)localsend.shared_group` (tên nội bộ upstream) vẫn hợp lệ khi có Team ID.
3. `release-lotus.yml`, job macOS (bỏ `continue-on-error` khi đã ổn định):
   1. Tạo keychain tạm, nhập `.p12`, chọn Xcode 26 (đã có).
   2. `flutter build macos --release`, ký lại sâu với `--options runtime --timestamp` và entitlements Release.
   3. Dựng DMG, ký DMG, `xcrun notarytool submit <dmg> --key ... --key-id ... --issuer ... --wait`, rồi
      `xcrun stapler staple <dmg>`.
   4. Kiểm: `spctl -a -vvv -t install <dmg>` phải "accepted, source=Notarized Developer ID"; `codesign -dv` ra đúng
      `TeamIdentifier` đã ghim -> sai thì dừng (giống kiểm APK).
   5. Xóa keychain tạm (`if: always()`).
4. Job iOS mới (runner macOS): `flutter build ipa --release --export-options-plist=...` (ký Apple Distribution), tải lên
   TestFlight bằng `xcrun altool --upload-package <ipa> --type ios --apiKey <KEYID> --apiIssuer <ISSUER>` (khóa `.p8`
   đặt ở `~/.appstoreconnect/private_keys/`). `--upload-app` đã deprecated; `altool` KHÔNG còn dùng cho công chứng
   (macOS dùng `notarytool`). Kiểm cờ bằng `xcrun altool --help` trên Xcode của máy chạy trước khi viết. IPA KHÔNG đưa vào GitHub Release (người dùng iOS cài qua TestFlight/App Store).
5. Kiểm trước khi gửi duyệt App Store: chuỗi xin quyền đã tiếng Việt (`Info.plist`), tệp `PrivacyInfo.xcprivacy`
   (kiểm có chưa), không còn mua trong ứng dụng dẫn tiền về tác giả gốc trên bản iOS (cân nhắc bỏ
   `in_app_purchase` như bản Android, hoặc giữ nếu chủ dự án đồng ý - quyết định của chủ dự án).

### 2.3. Hoàn tất

- `docs/vi/PHAT-HANH.md`: mục 1 (DEVELOPMENT_TEAM), mục 3 (khóa Apple), mục 4 (`spctl`), mục 5 bỏ giới hạn macOS/iOS.
- Trang Tải về: macOS "đã công chứng", thêm mục iOS (liên kết TestFlight/App Store).

---

## 3. Phát hành sau đợt này

1. Mọi thay đổi qua PR vào `main` (ruleset: 11 kiểm tra), chủ dự án chạy `gh pr merge <n> --merge --auto --delete-branch`.
2. Build thử: `gh workflow run release-lotus.yml -R tsudev-org/lotus-share --ref main` -> xanh toàn bộ.
3. Chủ dự án gắn nhãn `v<pubspec>-lotus.<n+1>`, duyệt yêu cầu ký trên SignPath, duyệt bản nháp, Publish, rồi
   `cd website && npm run deploy`.
