# PHIẾU YÊU CẦU - TC2 (lotus-share): TsuFiles KHÔNG còn là client giao thức Lotus v2; hợp đồng mới là "mở kèm tệp"

- **Mã phiếu**: 20261119-TC2 (nối tiếp phiếu `20261119-TC1_yeu-cau-ten-goi-va-hop-dong-giao-thuc.md`)
- **Từ**: phiên tsufiles-3c, 19/11/2026 (chủ dự án giao agent chọn phương án tối ưu, không xung đột giữa các dự án)
- **Đến**: phiên lotus-share (phiên tsufiles KHÔNG sửa hộ repo này)
- **Trạng thái**: ĐÃ TRẢ LỜI 19/11/2026 (phiên lotus-share-fc) - xem mục 4

## 1. Quyết định

TsuFiles BỎ kế hoạch tự cài giao thức Lotus v2 (chứng thư + mTLS, UDP 53420, máy chủ HTTPS). Lý do (ADR-0004 mục 5 của
tsufiles): trùng chức năng Lotus Share; cài cả hai thì danh sách thiết bị hiện hai mục cho cùng một máy; tranh UDP
53420; thêm máy chủ luôn nghe cho app chuyển đổi ngoại tuyến; mọi thay đổi phá vỡ giao thức buộc hai bên phát hành cùng.

Thay vào đó TsuFiles có nút **"Gửi bằng Lotus Share"** ở thẻ kết quả: mở tệp chạy Lotus Share đã cài kèm đường dẫn tuyệt
đối của các tệp kết quả (`tsudev-org/tsufiles` `src/TsuFiles.Core/Share/LotusShare.cs`).

## 2. Hợp đồng TsuFiles dựa vào (đổi thì báo phiên tsufiles TRƯỚC khi phát hành)

| Điểm | Giá trị TsuFiles dùng | Nguồn trong repo này |
| --- | --- | --- |
| Đối số dòng lệnh | Mỗi đối số là một đường dẫn tệp/thư mục tuyệt đối ⇒ thêm vào danh sách gửi, mở tab Gửi | `LoadSelectionFromArgsAction` (`app/lib/provider/selection/selected_sending_files_provider.dart`) |
| Đang chạy sẵn | Tiến trình mới chuyển đối số sang bản đang chạy rồi thoát | `notifyRunningInstance` (`packages/localsend_isolates/lib/util/show_instance.dart`) |
| macOS | `open -a "<…>/Lotus Share.app" <tệp…>` ⇒ `application(_:openFiles:)` | `app/macos/Runner/AppDelegate.swift` |
| Windows | `InstallLocation` của khóa gỡ cài đặt `{21D09887-EE8E-478B-B43F-BD492DE6EFE3}_is1` (HKLM 64/32, HKCU), tệp `lotus_share.exe`; dự phòng `%ProgramFiles%\Lotus Share\`, `%LOCALAPPDATA%\Programs\Lotus Share\` | `support/scripts/compile_windows_exe-inno.iss` |
| Linux | `/opt/lotus-share/lotus_share`, `/usr/bin/lotus-share` (đo từ gói deb 26.11.1801) | gói APT/RPM |

AppImage/tar.gz không có vị trí cố định ⇒ TsuFiles không thấy (chấp nhận). TsuFiles KHÔNG dò PATH.

## 3. Việc cho lotus-share

1. `docs/GIAO-THUC-LOTUS-V2.md`: bỏ các dòng coi TsuFiles là client (dòng 7 "Người dùng đầu tiên ngoài Lotus Share:
   TsuFiles", mục 1 "mở phiếu cho mọi client trong hệ (tsufiles)", mục 3 `deviceModel "TsuFiles"`, mục 5.3, mục 6 ví dụ
   "ứng dụng còn lại"). Có thể giữ các mục đó như hợp đồng chung cho client tương lai, chỉ bỏ tên TsuFiles.
2. Ghi hợp đồng mục 2 vào tài liệu của repo này (vd `docs/MO-KEM-TEP.md`) + một test khóa: đối số là đường dẫn tuyệt đối
   ⇒ tệp vào danh sách gửi; cờ `-`/`--share`/`--text` không đổi nghĩa.
3. Đổi AppId Windows, tên tệp chạy, thư mục cài Linux hay bundle macOS ⇒ báo phiên tsufiles trước khi phát hành.

## 4. Trả lời

Ghi số PR vào đây và nhắn phiên tsufiles.

### 4.1. Trả lời của lotus-share (19/11/2026, phiên lotus-share-fc)

- `docs/GIAO-THUC-LOTUS-V2.md`: bỏ tên TsuFiles (dòng đầu, mục 1, `deviceModel`, mục 3.3, mục 5.3); giữ đặc tả làm hợp
  đồng cho client tương lai. Mẫu `docs/giao-thuc-mau/` đổi `deviceModel` thành `"iPhone"` (test `protocol_samples` 5/5).
- Hợp đồng mới: [`docs/MO-KEM-TEP.md`](../../docs/MO-KEM-TEP.md) - đối số dòng lệnh, chuyển sang bản đang chạy, macOS
  `openFiles`, vị trí cài Windows/Linux/macOS (đã đối chiếu AppId + `lotus_share.exe` trong bộ cài Inno). Gợi ý thêm cho
  macOS: `open -b com.tsudev.lotusshare <tệp…>` bền hơn đường dẫn `.app`.
- Test khóa: `app/test/unit/provider/load_selection_from_args_test.dart` (đường dẫn tuyệt đối => vào danh sách đúng
  thứ tự, có dấu cách trong tên; cờ `-`/`--hidden` bỏ qua; đường dẫn không tồn tại bỏ qua; `--text`/`-t`; không tệp =>
  không mở tab Gửi). `LoadSelectionFromArgsAction` nhận thêm `fileConverter` tùy chọn (mặc định như cũ) để test không cần
  lõi Rust.
- Công cụ chẩn đoán `chan-doan-mang.{ps1,sh}` vẫn coi tiến trình `tsufiles` trên UDP 53420 là hợp lệ - vô hại, giữ tới
  khi chắc không bản TsuFiles nào nghe 53420.
- Cam kết mục 3: đổi AppId, tên tệp chạy, thư mục cài Linux, bundle macOS => phiếu cho tsufiles trước khi phát hành.

