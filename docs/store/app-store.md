# Hồ sơ App Store Connect / TestFlight - Lotus Share (iOS)

> Soạn sẵn 19/11/2026 theo STORE_SUBMISSION mục 4.3 (nộp khi có Apple Developer Program, dự kiến đầu 2027).
> Quy trình kỹ thuật: [`../vi/APPLE-IOS-MACOS.md`](../vi/APPLE-IOS-MACOS.md). Trước khi điền: đối chiếu lại từng trường với
> giao diện App Store Connect và App Review Guidelines ngày nộp, sửa tệp này nếu đã đổi, ghi ngày đối chiếu ở cuối.
> Dòng đánh dấu ⚠ là chỗ phải kiểm lại / 👤 quyết.

## 1. Thông tin ứng dụng (App Information)

| Trường | Giá trị |
| --- | --- |
| Tên (Name, tối đa 30) | `Lotus Share` (nếu đã có người dùng: `Lotus Share - Gửi tệp`) |
| Phụ đề vi (Subtitle, tối đa 30) | `Gửi tệp trong mạng nội bộ` |
| Phụ đề en | `Share files on local network` |
| Bundle ID | `com.tsudev.lotusshare` (+ `com.tsudev.lotusshare.ShareExtension`) |
| SKU | `lotus-share-ios` |
| Ngôn ngữ chính | Vietnamese; thêm bản địa hóa English (U.S.) cùng nội dung |
| Danh mục | Chính: Utilities (Tiện ích); phụ: Productivity (Năng suất) |
| Bản quyền | `2026 TsuDEV` |
| URL hỗ trợ | `https://lotus.tsudev.com/huong-dan/` |
| URL tiếp thị | `https://lotus.tsudev.com` |
| URL chính sách quyền riêng tư | `https://tsudev.com/privacy` |

## 2. Mô tả

**vi - Văn bản quảng bá (Promotional, tối đa 170):** Gửi ảnh, video, tài liệu giữa iPhone, máy tính và điện thoại
Android trong cùng Wi-Fi - không cần Internet, không cần tài khoản.

**vi - Mô tả:**

```text
Lotus Share gửi tệp và tin nhắn giữa các thiết bị trong cùng mạng Wi-Fi hoặc mạng LAN. Tệp đi thẳng từ máy này sang máy kia, không qua máy chủ, không cần Internet, không cần tạo tài khoản.

- Gửi ảnh, video, tài liệu, thư mục và đoạn văn bản tới Windows, macOS, Linux, Android và iPhone khác đang chạy Lotus Share.
- Tự tìm thấy thiết bị ở gần; có thể nhập địa chỉ IP khi mạng chặn tìm kiếm.
- Kết nối được mã hóa HTTPS giữa hai thiết bị; có mã PIN cho người gửi lạ, chặn dò mã PIN.
- Giao diện theo ngôn ngữ và chế độ sáng/tối của máy; hơn 60 ngôn ngữ, tiếng Việt đầy đủ.
- Không quảng cáo, không theo dõi, không thu thập dữ liệu.

Lotus Share là phần mềm mã nguồn mở (Apache 2.0) của TsuDEV.
```

**en - Promotional:** Send photos, videos and documents between iPhone, computers and Android phones on the same Wi-Fi -
no Internet, no account.

**en - Description:**

```text
Lotus Share sends files and messages between devices on the same Wi-Fi or LAN. Files go directly from one device to the other - no server, no Internet, no account.

- Send photos, videos, documents, folders and text to Windows, macOS, Linux, Android and other iPhones running Lotus Share.
- Finds nearby devices automatically; enter an IP address when the network blocks discovery.
- HTTPS-encrypted connection between the two devices; PIN for unknown senders with brute-force protection.
- Follows your system language and light/dark mode; 60+ languages.
- No ads, no tracking, no data collection.

Lotus Share is open-source software (Apache 2.0) by TsuDEV.
```

**Từ khóa vi (tối đa 100, phẩy không cách):** `gửi tệp,chia sẻ tệp,wifi,lan,airdrop,truyền ảnh,không internet,máy tính,android`
**Keywords en:** `file transfer,share files,wifi,lan,send photos,offline,nearby,windows,android,local network`
⚠ Không dùng nhãn hiệu người khác làm từ khóa nếu App Review từ chối (`airdrop`) - bỏ ngay khi bị nhắc.

Không ghi số tài khoản, QR, lời kêu gọi ủng hộ, liên kết thanh toán ngoài trong mô tả/ứng dụng bản iOS (PRODUCT_POLICY
mục 3.3: App Store chỉ dùng In-App Purchase; Ủng hộ trên iOS là IAP hoặc ẩn hẳn theo phiếu `20261112-02`).
Không nhắc tên sản phẩm/dự án khác (AGENTS.md B.5); thông báo bản quyền gốc chỉ ở Giới thiệu > Giấy phép.

## 3. Quyền riêng tư (App Privacy)

- Nhãn: **Data Not Collected** - ứng dụng không gửi dữ liệu về TsuDEV; mọi trao đổi đi thẳng giữa thiết bị trong mạng
  nội bộ. Kiểm lại khi T7 thêm đăng nhập tài khoản TsuDEV / Pro (khi đó khai "Contact Info/User ID - App Functionality").
- Theo dõi (Tracking): Không. `PrivacyInfo.xcprivacy` khớp: `NSPrivacyTracking=false`, không loại dữ liệu thu thập.
- Quyền xin (đều có chuỗi tiếng Việt trong `Info.plist`): Mạng cục bộ (tìm + kết nối thiết bị), Thư viện ảnh (chọn để
  gửi / lưu tệp nhận), Vị trí khi dùng (iOS chỉ cho đọc tên Wi-Fi khi có quyền vị trí - ứng dụng không lấy tọa độ).
  ⚠ Người duyệt hay hỏi quyền vị trí: trả lời đúng mục đích trên; nếu không cần hiện tên Wi-Fi thì cân nhắc bỏ quyền.
  ⚠ Chuỗi xin quyền chỉ có tiếng Việt: thêm `en.lproj/InfoPlist.strings` trước khi nộp bản địa hóa English.

## 4. Tuân thủ xuất khẩu mã hóa (Export Compliance)

`Info.plist` hiện ghi `ITSAppUsesNonExemptEncryption = false`. ⚠ Phải xác minh lại trước lần nộp đầu: lõi Rust dùng
TLS chuẩn qua thư viện `rustls` (không phải TLS của hệ điều hành) - câu hỏi của Apple "dùng thuật toán mã hóa chuẩn thay
cho/bổ sung mã hóa của hệ điều hành" khi đó là **Có**. Đọc hướng dẫn Export Compliance hiện hành của Apple + quy định
EAR (mass market 5D992 / báo cáo tự phân loại hằng năm) ngày nộp, ghi kết luận và lý do vào đây; đổi khóa `Info.plist`
nếu kết luận khác. 👤 quyết nếu phải nộp báo cáo cho cơ quan Mỹ.

## 5. Xếp hạng tuổi (Age Rating)

Mọi câu hỏi nội dung: **None/No** (không bạo lực, không nội dung người lớn, không cờ bạc, không trình duyệt web không
giới hạn, không nội dung do người dùng tạo công khai - tệp chỉ đi giữa thiết bị riêng). Dự kiến **4+**.

## 6. Ảnh và xem trước

- iPhone 6,9" (1320 x 2868) bắt buộc; 6,5" tùy hệ thống yêu cầu ngày nộp. Ứng dụng hỗ trợ cả iPad
  (`TARGETED_DEVICE_FAMILY = "1,2"`) => BẮT BUỘC thêm ảnh iPad 13" (2064 x 2752); chụp trên Simulator iPad Pro 13".
- Nguồn ảnh: phase T8 (ảnh không dữ liệu thật) + ảnh chụp Simulator iPhone Pro Max của `apple.yml`
  (`ios-simulator-screenshot`). Lưu bộ chọn lọc ở `assets/store/ios/`.
- Nội dung 5 ảnh: (1) danh sách thiết bị ở gần, (2) chọn tệp gửi, (3) nhận tệp + PIN, (4) lịch sử, (5) cài đặt ngôn ngữ/
  giao diện. Chữ chú thích vi + en.

## 7. Thông tin cho người duyệt (App Review Information)

- Đăng nhập: không cần tài khoản.
- Ghi chú (en): `Lotus Share transfers files directly between devices on the same local network. To test, install Lotus
  Share on a second device (free on Windows/macOS/Linux/Android at https://lotus.tsudev.com/tai-ve/), connect both to
  the same Wi-Fi, open the app on both: devices appear automatically (multicast networking entitlement granted for
  com.tsudev.lotusshare). If discovery is blocked on your network, add the other device manually by its IP address (shown on its Receive tab).`
- Liên hệ: 👤 điền họ tên, số điện thoại, email lúc nộp (không ghi vào repo công khai).

## 8. TestFlight

Nội bộ (Internal) trước: 👤 + máy thử. Bên ngoài (External) cần Apple duyệt bản beta: thông tin "What to Test" = mục 2
bước 5-6 của `APPLE-IOS-MACOS.md`. Chỉ gửi App Store sau khi TestFlight nội bộ tự thấy thiết bị và gửi/nhận 2 chiều.

## 9. Đối chiếu

| Ngày | Ai | Đối chiếu gì | Thay đổi |
| --- | --- | --- | --- |
| 19/11/2026 | lotus-share-fc | Soạn từ STORE_SUBMISSION 4.3, PRODUCT_POLICY 2.1/3.3, Info.plist, PrivacyInfo | Bản đầu |
