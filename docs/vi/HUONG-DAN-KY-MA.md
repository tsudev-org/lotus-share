# Hướng dẫn từng bước cho chủ dự án: nộp đơn SignPath (Windows) và ký mã Apple (macOS, iOS)

> Viết 12/11/2026. Điều khoản SignPath đọc lại cùng ngày tại <https://signpath.org/terms>; tài liệu tích hợp tại
> <https://docs.signpath.io/trusted-build-systems/github>. Phần việc của agent (sửa workflow) nằm ở
> [`KE-HOACH-KY-MA-12-2026.md`](KE-HOACH-KY-MA-12-2026.md); tài liệu này chỉ gồm việc **chủ dự án** phải tự làm vì
> cần danh tính, thanh toán hoặc bí mật của chủ dự án.
>
> Quy tắc chung: mọi khóa, chứng thư, token lưu NGOÀI repo ở `~/.config/lotus-share/keys/` (quyền 0600) và sao lưu
> ngoại tuyến. Không dán bí mật vào chat, Issue, PR hay tệp trong repo. Hai script `tools/dat-bien-signpath.sh` và
> `tools/day-khoa-apple.sh` đẩy bí mật thẳng lên GitHub Secrets, nhập ẩn.

## Tóm tắt thứ tự

| # | Việc | Ai | Thời gian chờ |
| --- | --- | --- | --- |
| A1-A2 | Bật 2FA tài khoản GitHub + bắt buộc 2FA ở org `tsudev-org` | Chủ dự án | 10 phút |
| A3-A4 | Nộp đơn SignPath Foundation | Chủ dự án (nội dung soạn sẵn ở A4) | Vài ngày đến vài tuần |
| B1-B2 | Đăng ký Apple Developer Program | Chủ dự án | 1-2 ngày (có khi lâu hơn) |
| B3-B8 | Định danh, chứng thư, khóa API, hồ sơ App Store Connect | Chủ dự án | 1 giờ + chờ Apple duyệt quyền multicast |
| A6, B9 | Chạy 2 script đẩy bí mật, báo agent | Chủ dự án | 5 phút |
| - | Sửa `release-lotus.yml`, build thử, phát hành | Agent (KE-HOACH mục 1.5, 2.2) | 1 phiên |

Nên làm A1-A4 và B1-B2 **ngay** vì phần chờ duyệt nằm ở phía SignPath/Apple.

---

## A. SignPath Foundation - chứng thư ký mã Windows miễn phí

### A0. Đối chiếu điều kiện (12/11/2026)

| Điều kiện (signpath.org/terms) | Hiện trạng | Việc |
| --- | --- | --- |
| Giấy phép OSI, không cấp phép kép thương mại | Apache-2.0 | Đạt |
| Không mã độc, không thành phần độc quyền | Đã gỡ `in_app_purchase`, StoreKit (PR #18) | Đạt |
| Đang bảo trì, đã phát hành đúng dạng cần ký | `v1.18.2-lotus.3` (exe, zip, CLI) | Đạt |
| Chức năng mô tả trên trang tải | `lotus.tsudev.com/tai-ve/` | Đạt |
| Build từ mã nguồn kiểm chứng được, mỗi lần ký được duyệt tay | GitHub Actions + nhãn bất biến; SignPath bắt duyệt | Đạt |
| **MFA cho mọi thành viên** (GitHub và SignPath) | Org `tsudev-org` đã bắt buộc 2FA (đo 12/11/2026) | Đạt (A1, A2 xong) |
| Trang "Code signing policy": câu ghi công có 2 liên kết, vai trò "Committers and reviewers" / "Approvers", tuyên bố quyền riêng tư; liên kết từ trang chủ và trang tải | `lotus.tsudev.com/chinh-sach-ky-ma/` - đủ (bổ sung phần tiếng Anh 12/11/2026) | Đạt |
| Metadata: tên sản phẩm = tên dự án, phiên bản như nhau | `Runner.rc`: ProductName "Lotus Share"; Inno AppName "Lotus Share" | Đạt (đặt tên dự án SignPath là "Lotus Share") |
| **Bản fork phải "dùng fork hiển nhiên, ví dụ tính năng fork của GitHub"** | `tsudev-org/lotus-share` **không** phải GitHub fork (`fork=false`) | Rủi ro - trả lời theo A5 |

### A1. Bật 2FA cho tài khoản GitHub `tsudev-tsudev`

1. <https://github.com/settings/security> > **Two-factor authentication** > **Enable**.
2. Chọn ứng dụng TOTP (Google Authenticator, Microsoft Authenticator, 1Password...) hoặc passkey/khóa bảo mật.
3. Tải **recovery codes**, cất ngoại tuyến (giấy hoặc trình quản lý mật khẩu). Mất cả điện thoại lẫn mã này = mất tài
   khoản quản trị mọi repo tsudev.

### A2. Bắt buộc 2FA ở org `tsudev-org`

1. <https://github.com/organizations/tsudev-org/settings/security> > tích **Require two-factor authentication for
   everyone in the tsudev-org organization** > Save.
2. Cảnh báo của GitHub: thành viên/cộng tác viên ngoài **chưa** bật 2FA sẽ bị gỡ khỏi org. Xem danh sách trước ở
   <https://github.com/orgs/tsudev-org/people> (lọc "2FA disabled").
3. Kiểm (agent làm được): `gh api orgs/tsudev-org -q .two_factor_requirement_enabled` phải ra `true`.

### A3. Kiểm trang chính sách ký mã (1 phút)

Mở <https://lotus.tsudev.com/chinh-sach-ky-ma/>: có câu "Free code signing provided by SignPath.io, certificate by
SignPath Foundation" (2 liên kết), mục "Committers and reviewers" / "Approvers", câu "This program will not transfer any
information...". Chân trang chủ và trang Tải về có liên kết "Code signing policy".

### A4. Nộp đơn

1. Mở <https://signpath.org/apply> (biểu mẫu nạp bằng JavaScript; ô có thể thay đổi theo thời gian - điền theo bảng
   dưới, ô nào không có trong bảng thì trả lời đúng sự thật, ngắn gọn bằng tiếng Anh).
2. Dùng email liên hệ của chủ dự án (không dùng email cá nhân khác lộ ra công khai nếu không muốn).

| Ô (ý nghĩa) | Nội dung dán vào |
| --- | --- |
| Project name | Lotus Share |
| Repository URL | https://github.com/tsudev-org/lotus-share |
| Project homepage | https://lotus.tsudev.com |
| Download page | https://lotus.tsudev.com/tai-ve/ |
| Code signing policy URL | https://lotus.tsudev.com/chinh-sach-ky-ma/ |
| License | Apache-2.0 |
| Short description | Cross-platform app to share files and messages between nearby devices on the local network, without Internet or accounts. |
| Long description / notes | Lotus Share is a Vietnamese-first, security-hardened fork of LocalSend (Apache-2.0, whose Windows releases are signed via SignPath). It stays protocol-compatible with LocalSend v2. Release binaries are built only on GitHub-hosted runners by `.github/workflows/release-lotus.yml` from immutable, admin-only tags `v*-lotus.*`; every change to `main`, including upstream merges, requires a reviewed pull request and all required checks. Releases already ship SHA256SUMS signed with Sigstore and SLSA build provenance. |
| Build system | GitHub Actions (GitHub-hosted runners, github.com) |
| Files to sign | `lotus_share.exe` and the app DLLs built from this repository; Inno Setup installer `lotus-share-<version>-windows-x86-64-setup.exe` and `-windows-arm-64-setup.exe` (up to 1.18.2-lotus.4 without the `-setup` suffix); CLI `lotus-share-cli-<version>-windows-x86-64.exe` and `-windows-arm-64.exe` |
| Number of maintainers / team | 1 - @tsudev-tsudev (author, reviewer, approver), MFA enabled on GitHub and SignPath |
| Existing releases | https://github.com/tsudev-org/lotus-share/releases (latest v1.18.2-lotus.3) |
| Upstream / fork | Fork of https://github.com/localsend/localsend - see A5 |

3. Nộp xong: ghi **ngày nộp** vào `logs/STATE.md` mục "Quyết định quan trọng" (hoặc nhắn agent ghi).

### A5. Nếu SignPath hỏi về quan hệ fork

Repo không mang nhãn "forked from" của GitHub (được tạo mới rồi nhập lịch sử LocalSend). Trả lời bằng đoạn sau, KHÔNG
xóa/tạo lại repo để lấy nhãn fork (gãy chuyển hướng tên cũ `tsudev-lotus`, gãy updater, manifest winget/Scoop/Homebrew -
xem quy tắc tên repo trong CLAUDE.md toàn cục):

> The repository is a fork of localsend/localsend that contains the full upstream git history, but it was created as a
> standalone repository rather than with GitHub's fork button, so GitHub does not show the "forked from" label. The fork relationship is stated in the README,
> NOTICE, the in-app About screen and https://lotus.tsudev.com/ban-quyen/. Upstream is configured as the `upstream`
> remote; upstream changes are merged only through reviewed pull requests (for example PR #29, merging upstream
> 2e7ef197). Our release branch `main` is based on upstream `main`, which is the branch LocalSend signs. If the GitHub
> fork label is required, we can ask GitHub Support to attach the repository to the localsend/localsend fork network.

Nếu SignPath vẫn yêu cầu nhãn fork: mở yêu cầu tại <https://support.github.com> xin gắn repo vào mạng fork của
`localsend/localsend` (GitHub thường chỉ hỗ trợ tách, không chắc nhận gắn) - không tự xử lý bằng cách tạo repo mới.

> **Tình trạng:** đã nộp đơn 12/11/2026, chờ SignPath duyệt. Có email trả lời thì báo agent (dán nội dung, KHÔNG dán
> token/mật khẩu).

### A6. Khi được duyệt (email từ SignPath)

1. Đăng nhập <https://app.signpath.io>, bật **MFA** cho tài khoản SignPath ngay.
2. Organization > **Trusted Build Systems**: thêm hệ thống có sẵn **GitHub.com** vào tổ chức, rồi liên kết với Project.
3. (Nên làm) Cài **SignPath GitHub App** cho repo `tsudev-org/lotus-share` (SignPath dùng để đối chiếu nhật ký build).
4. Users: tạo **người dùng CI** (CI user), cấp vai trò **Submitter** trong Project; tạo **API token** cho người dùng đó.
5. Ghi lại: Organization ID (UUID), Project slug, Signing policy slug (thường `release-signing`; nếu được cấp
   `test-signing` cũng ghi lại để agent build thử).
6. Trong thư mục repo chạy: `./tools/dat-bien-signpath.sh` (hỏi 3 giá trị + token nhập ẩn; đẩy lên GitHub).
7. Báo agent "SignPath đã duyệt, đã đặt biến" - agent làm KE-HOACH mục 1.5 (cấu hình artifact XML để chủ dự án dán vào
   SignPath, sửa workflow, build thử).

### A7. Mỗi lần phát hành về sau

Đẩy nhãn như cũ; workflow dừng chờ ở bước ký -> mở liên kết `signing-request-web-url` trong log (hoặc app.signpath.io >
Signing Requests) > kiểm tệp, phiên bản, commit > **Approve**. Workflow tự chạy tiếp. Quá 10 phút không duyệt thì
bước ký hết giờ; chạy lại job.

---

## B. Apple Developer - macOS (Developer ID + công chứng) và iOS (TestFlight/App Store)

### B1. Apple Account

Dùng một Apple Account (Apple ID) dành cho phát hành, bật **xác thực hai yếu tố** (bắt buộc với Developer Program).

### B2. Đăng ký Apple Developer Program

1. Nhanh nhất: cài ứng dụng **Apple Developer** trên iPhone/iPad > Account > **Enroll Now** (quét giấy tờ tùy thân trong
   ứng dụng). Hoặc web: <https://developer.apple.com/programs/enroll/>.
2. Chọn **Individual / Sole Proprietor** (cá nhân) - không cần số D-U-N-S, duyệt thường 1-2 ngày (có trường hợp lâu
   hơn). Lưu ý: với tài khoản cá nhân, tên người bán hiển thị trên App Store là **họ tên pháp lý** của chủ tài khoản. Muốn
   hiển thị "tsudev" phải đăng ký **Organization** (cần pháp nhân + D-U-N-S, lâu hơn) - quyết định của chủ dự án.
3. Phí 99 USD/năm (hiển thị theo nội tệ lúc thanh toán; quên gia hạn = ứng dụng bị gỡ khỏi App Store, chứng thư
   Developer ID đã ký vẫn hợp lệ cho bản đã công chứng).
4. Khi xong: <https://developer.apple.com/account> > Membership details > ghi **Team ID** (10 ký tự).

### B3. Xin quyền Multicast Networking (BẮT BUỘC với iOS - làm sớm)

Lotus Share tìm thiết bị qua multicast (224.0.0.167, cổng 53317). Trên iOS 14+ việc này cần quyền đặc biệt
`com.apple.developer.networking.multicast` (đã có trong `app/ios/Runner/Runner.entitlements`); Apple duyệt tay.

1. Mở <https://developer.apple.com/contact/request/networking-multicast> (đăng nhập tài khoản developer).
2. Bundle ID: `com.tsudev.lotusshare`. Phần giải thích (dán):

> Lotus Share sends files between nearby devices on the same local network without Internet or accounts. It is
> protocol-compatible with LocalSend (which uses the same entitlement): devices announce themselves by sending a small
> JSON packet to the multicast group 224.0.0.167 on UDP port 53317 and listen on that group to discover peers, then
> transfer files directly over HTTPS. Discovery only runs while the user has the app open, and the user is asked for
> Local Network permission (NSLocalNetworkUsageDescription) before any traffic.

3. Chờ email duyệt (vài ngày). Sau đó ở App ID (B4) mục **Additional Capabilities** bật **Multicast Networking**.

### B4. Định danh (Certificates, Identifiers & Profiles)

<https://developer.apple.com/account/resources/identifiers/list>

1. **App Groups** > "+" > `group.com.tsudev.lotusshare` (mô tả "Lotus Share").
2. **App IDs** > "+" > App > Explicit:
   - `com.tsudev.lotusshare` (mô tả "Lotus Share"), nền tảng iOS. Capabilities: **App Groups** (gán nhóm ở bước 1).
     **Multicast Networking**: bật sau khi B3 được duyệt.
   - `com.tsudev.lotusshare.ShareExtension` ("Lotus Share Share Extension"), iOS, **App Groups** cùng nhóm.
   - Push Notifications: KHÔNG bật - agent bỏ khóa `aps-environment` thừa trong entitlements (ứng dụng không dùng push).
3. macOS phát hành bằng DMG ngoài App Store với Developer ID: **không cần** App ID/provisioning profile.

### B5. Chứng thư

> **Kế hoạch (12/11/2026):** làm phần B vào tháng 12/2026 trên MacBook của chủ dự án.
>
> **Trên MacBook:** Keychain Access > Certificate Assistant > *Request a Certificate From a Certificate Authority*
> (nhập email Apple ID, chọn *Saved to disk*) -> tạo 2 chứng thư bên dưới trên developer.apple.com bằng tệp CSR đó ->
> tải `.cer` về, mở đúp để nhập vào Keychain -> trong Keychain chọn chứng thư (kèm khóa riêng) > *Export* thành
> `developer-id.p12` và `distribution.p12` (cùng một mật khẩu) -> chép vào `~/.config/lotus-share/keys/apple/`, `chmod 600`.
> Cách dùng openssl dưới đây là phương án khi không có Mac.

Cách không cần máy Mac (Linux/WSL):

Cần 2 chứng thư: **Developer ID Application** (ký app macOS ngoài App Store; chỉ Account Holder tạo được) và
**Apple Distribution** (ký bản iOS gửi TestFlight/App Store).

```bash
umask 077
mkdir -p ~/.config/lotus-share/keys/apple && cd ~/.config/lotus-share/keys/apple
for n in developer-id distribution; do
  openssl req -new -newkey rsa:2048 -nodes -keyout "$n.key" -out "$n.csr" -subj "/CN=Lotus Share $n/C=VN"
done
```

1. <https://developer.apple.com/account/resources/certificates/add>:
   - Chọn **Developer ID Application** > Profile Type **G2 Sub-CA** > tải lên `developer-id.csr` > Download (`.cer`).
   - Lặp lại với **Apple Distribution** > tải lên `distribution.csr`.
2. Đặt 2 tệp tải về vào thư mục trên, đổi tên `developer-id.cer`, `distribution.cer`, rồi gộp khóa + chứng thư thành
   `.p12` (định dạng 3DES để keychain macOS cũ trên máy chạy CI nhập được), đặt **một** mật khẩu mạnh cho cả hai:

```bash
cd ~/.config/lotus-share/keys/apple
read -r -s -p "Mật khẩu .p12: " P; echo
for n in developer-id distribution; do
  openssl x509 -inform DER -in "$n.cer" -out "$n.pem"
  openssl pkcs12 -export -inkey "$n.key" -in "$n.pem" -out "$n.p12" -name "Lotus Share $n" \
    -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1 -passout "pass:$P"
  openssl x509 -in "$n.pem" -noout -subject -enddate   # kiểm: Subject có Team ID trong ngoặc
done
unset P; chmod 600 ./*
```

3. Sao lưu `*.p12` (và mật khẩu) ngoại tuyến. Có thể xóa `*.key`, `*.csr` sau khi đã có `.p12` và bản sao lưu.
   Mất khóa Developer ID: thu hồi và tạo lại được, nhưng bản đã phát hành vẫn hợp lệ; KHÔNG để lộ - kẻ có khóa ký được
   phần mềm mạo danh tsudev (khi đó thu hồi ngay tại trang Certificates).

### B6. Khóa API App Store Connect (cho công chứng và tải bản iOS)

1. <https://appstoreconnect.apple.com/access/integrations/api> > **Team Keys** (lần đầu: **Request Access**, Account
   Holder đồng ý điều khoản).
2. **Generate API Key**: tên "lotus-share-ci", vai trò **App Manager**.
3. **Download API Key** - tệp `AuthKey_<KEYID>.p8` **chỉ tải được một lần** - lưu vào `~/.config/lotus-share/keys/apple/`
   và `chmod 600`. Ghi **Issuer ID** (UUID hiện phía trên danh sách khóa).

### B7. Tạo hồ sơ ứng dụng iOS trên App Store Connect

1. <https://appstoreconnect.apple.com/apps> > "+" > **New App**: Platforms **iOS**; Name **Lotus Share** (nếu tên đã có
   người dùng, chọn "Lotus Share - Gửi tệp"); Primary Language **Vietnamese**; Bundle ID `com.tsudev.lotusshare`;
   SKU `lotus-share-ios`; User Access: Full Access.
2. App Privacy > **Data Not Collected** (ứng dụng không thu dữ liệu; trao đổi trực tiếp giữa thiết bị). Privacy Policy
   URL: `https://tsudev.com/privacy`.
3. Mô tả cửa hàng: KHÔNG ghi số tài khoản, QR hay lời kêu gọi ủng hộ (quyết định ủng hộ theo nền tảng - iOS ẩn hoàn
   toàn); được ghi website `https://lotus.tsudev.com`. Ghi công LocalSend trong mô tả.
4. Mã hóa xuất khẩu: `Info.plist` đặt `ITSAppUsesNonExemptEncryption = false` như LocalSend gốc (chỉ dùng mã hóa chuẩn
   TLS để bảo vệ kết nối). Nếu App Review hỏi, trả lời đúng như vậy.

### B8. Kiểm tra trước khi giao cho agent

```bash
ls -l ~/.config/lotus-share/keys/apple/   # developer-id.p12, distribution.p12, AuthKey_<KEYID>.p8 - tất cả -rw-------
```

### B9. Đẩy lên GitHub và báo agent

```bash
cd ~/projects/lotus-share && ./tools/day-khoa-apple.sh
```

Script hỏi Team ID, Issuer ID, mật khẩu `.p12` (nhập ẩn), kiểm mở được `.p12`, rồi đặt Secrets
`APPLE_DEVID_P12_BASE64`, `APPLE_DIST_P12_BASE64`, `APPLE_P12_PASSWORD`, `APPLE_ASC_KEY_P8_BASE64` và Variables
`APPLE_TEAM_ID`, `APPLE_ASC_KEY_ID`, `APPLE_ASC_ISSUER_ID`. Báo agent "Apple xong, Team ID ..., multicast đã/chưa
duyệt" - agent làm KE-HOACH mục 2.2 (macOS ký + công chứng; iOS lên TestFlight).

### B10. Sau khi agent tích hợp

- macOS: bản DMG kế tiếp mở được không cảnh báo Gatekeeper. Tự kiểm trên máy Mac:
  `spctl -a -vvv -t install "Lotus Share.dmg"` ra `accepted ... source=Notarized Developer ID`.
- iOS: App Store Connect > TestFlight > thêm mình vào **Internal Testing**, cài ứng dụng TestFlight trên iPhone để thử
  (nhận/gửi tệp với máy Windows/Android). Mời người ngoài (External Testing) cần Apple duyệt bản beta (1-2 ngày).
- Gửi duyệt App Store: chọn bản build trong trang phiên bản > Add for Review. Đọc lại App Review Guidelines mục 3.1.1 và
  phiếu `~/projects/logs/handover/20261112-02_quyet-dinh-ung-ho-theo-nen-tang.md` ngay trước khi gửi, ghi ngày đối chiếu
  vào `logs/STATE.md`.

---

## C. Ghi lại sau mỗi bước

Nhắn agent (hoặc tự ghi) vào `logs/STATE.md`: ngày nộp SignPath, ngày SignPath duyệt, ngày Apple duyệt tài khoản,
ngày duyệt quyền multicast, Team ID (không bí mật). Không ghi token, mật khẩu, nội dung tệp khóa.
