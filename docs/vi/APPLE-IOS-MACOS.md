# Quy trình Apple: iOS + macOS - phát triển ngay, ký khi có Mac + Apple Developer

> Lập 19/11/2026 (phiên lotus-share-fc) theo PRODUCT_POLICY mục 2.1 (bộ quy ước v3.8.1). Phần việc của **chủ dự án**
> (tài khoản, chứng thư, khóa API, secrets): [`HUONG-DAN-KY-MA.md`](HUONG-DAN-KY-MA.md) phần B. Kế hoạch gốc:
> [`KE-HOACH-KY-MA-12-2026.md`](KE-HOACH-KY-MA-12-2026.md) mục 2. Tài liệu này là quy trình đầy đủ và trạng thái thật.

## 0. Hiện trạng

| Nền tảng | Hôm nay | Khi có Mac + Apple Developer Program (dự kiến đầu 2027) |
| --- | --- | --- |
| iOS | CI dựng `.ipa` KHÔNG ký + chạy thử trên Simulator mỗi PR (`.github/workflows/apple.yml`); chủ dự án tự ký lại bằng Apple ID cá nhân để thử trên iPhone của mình (mục 2) | TestFlight -> App Store (job `ios` trong `release-lotus.yml`, đã viết sẵn, tự bật khi có `vars.APPLE_TEAM_ID`) |
| macOS | DMG ký ad-hoc trong mỗi bản phát hành; CI dựng + chạy thử mỗi PR | Ký Developer ID + Hardened Runtime + công chứng + staple (bước đã viết sẵn trong job `macos`) |

Tại sao chưa có iOS cho người dùng: (1) ký và phân phối iOS bắt buộc Apple Developer Program (99 USD/năm), (2) tìm
thiết bị bằng multicast trên iOS 14+ cần quyền `com.apple.developer.networking.multicast` mà Apple chỉ cấp cho tài khoản
trả phí, (3) iOS không cho cài ứng dụng ngoài App Store/TestFlight trừ bản ký bằng Apple ID cá nhân (7 ngày, chỉ máy
của chính người ký).

## 1. CI không ký - `.github/workflows/apple.yml`

Chạy khi PR đụng `app/`, `packages/`, khóa phụ thuộc; khi `main` đổi `app/ios`, `app/macos`; thứ Hai hằng tuần (bắt
sớm lỗi do Xcode của máy chạy đổi); chạy tay `gh workflow run apple.yml`. Repo công khai => phút macOS miễn phí.

| Job | Làm gì | Sản phẩm (artifact 14 ngày) |
| --- | --- | --- |
| `ios` | Kiểm tĩnh (entitlements có multicast, không còn `aps-environment`, chuỗi xin quyền, mã hóa xuất khẩu, bundle id) -> `flutter build ios --release --no-codesign` -> kiểm gói (bundle id, tên, `PrivacyInfo.xcprivacy` nằm trong `.app`, arm64) -> đóng `.ipa` không ký -> dựng bản Simulator, đặt ngôn ngữ máy `vi`, cài, mở, kiểm còn chạy sau 45 giây và KHÔNG có dấu hiệu `LOTUS_SHARE_INIT_ERROR` (màn hình lỗi khởi động - sự cố 26.11.1801 tiến trình vẫn sống), chụp màn hình; lặp lại trên iPad Pro 13" giả lập (ảnh App Store 2064x2752, kiểm cỡ) | `ios-unsigned-ipa` (`Lotus-Share-<ver>-unsigned.ipa` + SHA256SUMS), `ios-simulator-screenshot` |
| `macos` | `flutter build macos --release` -> kiểm entitlements Release trong chữ ký Xcode (sandbox, mạng) -> ký ad-hoc GIỐNG bản phát hành -> chạy thẳng tệp thực thi, kiểm còn chạy sau 30 giây và không có `LOTUS_SHARE_INIT_ERROR`, chụp màn hình | `macos-screenshot` |

Lỗi thường gặp: máy chạy chưa có Xcode 26 (connectivity_plus cần SDK 26) => đọc nhật ký bước "Chọn Xcode 26";
ứng dụng sập trên Simulator => bước in 80 dòng log cuối của tiến trình `Runner`.

Tải `.ipa`: `gh run download <run-id> -R tsudev-org/lotus-share -n ios-unsigned-ipa`.
`MUST NOT` đăng `.ipa` không ký lên Release hay gửi cho người khác (PRODUCT_POLICY 2.1).

## 2. Thử trên iPhone thật bây giờ (Apple ID miễn phí, máy Windows)

Chỉ để 👤 thử trên máy của chính mình. Mật khẩu Apple ID chỉ 👤 nhập vào công cụ ký; agent `MUST NOT` nhận hay lưu.

1. iPhone: Cài đặt > Quyền riêng tư & Bảo mật > **Chế độ nhà phát triển** > Bật (máy khởi động lại). Chế độ này chỉ
   hiện sau khi đã cài thử một ứng dụng ký bằng tài khoản phát triển lần đầu - nếu chưa thấy, làm bước 3 trước rồi bật.
2. Windows: cài iTunes + iCloud bản tải từ apple.com (không dùng bản Microsoft Store - công cụ ký cần thư viện của bản
   apple.com), rồi cài **Sideloadly** (sideloadly.io). Kiểm lại công cụ còn hỗ trợ phiên bản iOS của máy trước khi dùng.
3. Cắm cáp, bấm "Tin cậy" trên iPhone. Sideloadly: kéo `Lotus-Share-<ver>-unsigned.ipa` vào, nhập Apple ID, Start.
4. iPhone: Cài đặt > Cài đặt chung > Quản lý VPN & Thiết bị > tin cậy Apple ID của mình.
5. Giới hạn của bản ký Apple ID miễn phí: hết hạn sau **7 ngày** (cài lại), tối đa 3 ứng dụng; KHÔNG có quyền multicast
   => **iPhone không tự thấy thiết bị khác**. Cách thử gửi/nhận: trên iPhone bấm nút thêm thiết bị bằng tay (Nhập địa
   chỉ -> Địa chỉ IP của máy tính, xem ở thẻ Nhận của máy tính); chiều ngược lại máy tính nhập IP của iPhone. Máy tính và
   iPhone cùng Wi-Fi; máy tính đã mở cổng 53420 (bộ cài Windows tự mở).
6. Ghi kết quả vào `logs/thu-thiet-bi/YYYYMMDD-iphone.md`: đời máy, phiên bản iOS, bản Lotus Share, lần đầu mở có đúng
   ngôn ngữ + giao diện của máy không, gửi/nhận tệp (cả hai chiều) với Windows/Android, lỗi gặp (kèm ảnh).
7. (Không bắt buộc) đọc log thiết bị từ WSL: `usbipd-win` chuyển USB vào WSL, rồi `idevicesyslog` (libimobiledevice).

## 3. Đã chuẩn bị sẵn trong mã (để ngày có tài khoản chỉ còn bước ký)

- `app/ios/Runner/PrivacyInfo.xcprivacy` (có trong Copy Bundle Resources; CI kiểm có trong `.app`): không theo dõi,
  không thu dữ liệu; API required-reason: UserDefaults `CA92.1`, FileTimestamp `C617.1`+`3B52.1`, SystemBootTime
  `35F9.1`. Đổi mã dùng thêm API trong danh sách của Apple => sửa cùng PR.
- `Runner.entitlements` đã bỏ `aps-environment` (không dùng push - tránh phải bật Push Notifications cho App ID).
- `app/ios/ExportOptions-AppStore.plist`: `app-store-connect`, `destination=upload` (xuất xong tải thẳng lên App Store
  Connect, không cần altool/Transporter).
- `scripts/apple/`: `nhap-khoa.sh` (keychain tạm), `khoa-api.sh` (.p8), `ky-cong-chung-macos.sh` (ký từ trong ra ngoài,
  Hardened Runtime, DMG, `notarytool --wait`, staple, `spctl` phải ra `Notarized Developer ID`), `ios-testflight.sh`
  (`xcodebuild archive` + `-exportArchive`, hồ sơ cấp phép tự tạo qua khóa API), `xoa-khoa.sh` (luôn chạy cuối job).
- `release-lotus.yml`: `vars.APPLE_TEAM_ID` trống => y như cũ (ad-hoc, không job iOS). Có => job `macos` ký Developer ID
  + công chứng, job `ios` (chỉ khi đẩy nhãn) lên TestFlight. Script dừng nếu Team ID khác dòng ghim `APPLE_TEAM_ID_GHIM`.
- Các script CHƯA chạy thật (chưa có tài khoản): lần đầu phải làm đúng mục 4 bước 3-5.

## 4. Ngày có Mac + Apple Developer Program - thứ tự làm

1. 👤 `HUONG-DAN-KY-MA.md` B1-B9: tài khoản, **xin quyền multicast NGAY** (Apple duyệt tay, vài ngày), App ID + App
   Group, chứng thư Developer ID + Apple Distribution, khóa API (vai trò **Admin**, hoặc App Manager có quyền
   Certificates/Identifiers/Profiles - xcodebuild cần quyền này để tự tạo hồ sơ cấp phép), hồ sơ app trên App Store
   Connect, `tools/day-khoa-apple.sh`. Báo agent Team ID + trạng thái quyền multicast.
2. Agent, một PR: `APPLE_TEAM_ID_GHIM` = Team ID trong `release-lotus.yml`; `docs/vi/PHAT-HANH.md` mục 3-5; trang
   Tải về (macOS "đã công chứng"; mục iOS với liên kết TestFlight/App Store).
3. **macOS - sandbox bật thật lần đầu.** Bản ad-hoc hiện tại ký lại bằng `codesign --force --deep --sign -` nên MẤT
   entitlements (chạy ngoài sandbox). Bản Developer ID ký kèm `Release.entitlements` => chạy TRONG sandbox. Trên Mac
   thật, thử trước khi phát hành: nhận tệp vào Tải về và thư mục tự chọn (bookmark giữ sau khi mở lại), gửi tệp kéo
   thả, khởi động cùng hệ thống, khay, tìm thấy + được thấy bởi Windows/Android. Thiếu quyền nào thì thêm entitlement
   tương ứng (không tắt sandbox).
4. Build thử macOS: `gh workflow run release-lotus.yml --ref main` -> tải artifact `macos` -> trên Mac:
   `spctl -a -vvv -t install lotus-share_*.dmg` ra `accepted, source=Notarized Developer ID`; mở không cảnh báo.
5. **iOS - quyền multicast phải được duyệt trước** lần lưu trữ đầu: entitlements có multicast mà App ID chưa được cấp
   => xcodebuild báo hồ sơ cấp phép thiếu `com.apple.developer.networking.multicast`. Chưa duyệt mà cần thử TestFlight
   nội bộ: nhánh tạm bỏ dòng multicast (iPhone sẽ không tự thấy máy khác) - không phát hành nhánh đó.
6. Phát hành: nhãn mới theo VERSIONING -> job `ios` tải bản lên App Store Connect -> TestFlight > Internal Testing
   (👤 cài ứng dụng TestFlight trên iPhone) -> thử mục 2 bước 5-6 nhưng lần này phải TỰ THẤY thiết bị -> ghi kết quả.
7. Gửi duyệt App Store theo `docs/store/app-store.md` (phiên nộp duyệt, STORE_SUBMISSION mục 2).
