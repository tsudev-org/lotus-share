# Mở Lotus Share kèm tệp - hợp đồng cho ứng dụng khác trong hệ

> Lập 19/11/2026 theo phiếu `logs/handover/20261119-TC2_*`. Người dùng hiện tại: **TsuFiles** (nút "Gửi bằng Lotus
> Share" ở thẻ kết quả, `tsudev-org/tsufiles` `src/TsuFiles.Core/Share/LotusShare.cs`). Đây là cách ứng dụng khác gửi
> tệp qua Lotus Share **mà không phải cài giao thức** [`GIAO-THUC-LOTUS-V2.md`](GIAO-THUC-LOTUS-V2.md): chạy ứng dụng
> Lotus Share đã cài, truyền đường dẫn tệp; người dùng chọn thiết bị nhận trong Lotus Share như bình thường.

**Đổi bất kỳ điểm nào dưới đây (kể cả AppId Windows, tên tệp chạy, thư mục cài Linux, bundle macOS) => sửa tài liệu
này + báo phiên/phiếu cho tsufiles TRƯỚC khi phát hành.** Test khóa: `app/test/unit/provider/load_selection_from_args_test.dart`.

## 1. Đối số dòng lệnh (Windows, Linux)

| Đối số | Nghĩa | Nguồn |
| --- | --- | --- |
| `<đường dẫn>` | Đường dẫn tuyệt đối của tệp hoặc thư mục => thêm vào danh sách gửi theo đúng thứ tự, mở tab **Gửi**. Đường dẫn không tồn tại bị bỏ qua | `LoadSelectionFromArgsAction` (`app/lib/provider/selection/selected_sending_files_provider.dart`) |
| `--text <tin nhắn>` / `-t <tin nhắn>` | Đối số kế tiếp là tin nhắn văn bản (rỗng thì bỏ qua) | như trên |
| `--share <json>` | Nội dung chia sẻ từ trình chia sẻ của hệ điều hành (nội bộ) | như trên |
| `--hidden` | Khởi động thu nhỏ vào khay (dùng cho tự khởi động) - không mở tab Gửi | `app/lib/util/native/autostart_helper.dart` |
| đối số khác bắt đầu bằng `-` | Bị bỏ qua (không thành tệp) | như trên |

Không có tệp hợp lệ nào => ứng dụng mở như bình thường, không chuyển tab.

**Đang chạy sẵn**: tiến trình mới gửi đối số cho bản đang chạy (HTTP nội bộ `127.0.0.1`, `/api/lotus/v2/show`, có mã
`showToken` riêng của máy) rồi thoát; bản đang chạy hiện cửa sổ và thêm tệp như trên
(`notifyRunningInstance`, `packages/localsend_isolates/lib/util/show_instance.dart`). Bên gọi không cần làm gì thêm.

## 2. macOS

`open -a "/Applications/Lotus Share.app" <tệp…>` => `application(_:openFiles:)` (`app/macos/Runner/AppDelegate.swift`)
nhận tệp qua bookmark (ứng dụng sandbox) và thêm vào danh sách gửi. Bundle id `com.tsudev.lotusshare`; tìm ứng dụng
bằng `open -b com.tsudev.lotusshare <tệp…>` bền hơn đường dẫn.

## 3. Tìm ứng dụng đã cài

| Nền tảng | Vị trí | Ghi chú |
| --- | --- | --- |
| Windows | Giá trị `InstallLocation` của khóa gỡ cài đặt `{21D09887-EE8E-478B-B43F-BD492DE6EFE3}_is1` (HKLM 64-bit, HKLM 32-bit, HKCU), tệp `lotus_share.exe` | AppId + tên tệp: `support/scripts/compile_windows_exe-inno.iss`. Dự phòng `%ProgramFiles%\Lotus Share\`, `%LOCALAPPDATA%\Programs\Lotus Share\` (cài cho một người dùng). Bản ZIP di động/Scoop: không có khóa cố định |
| Linux | `/usr/bin/lotus-share` (lệnh), `/opt/lotus-share/lotus_share` | Gói APT/RPM ở `pkg.tsudev.com` (dựng ở `tsudev-org/linux-packages`). AppImage/tar.gz không có vị trí cố định |
| macOS | `/Applications/Lotus Share.app`, bundle id `com.tsudev.lotusshare` | DMG + Homebrew cask |
| Android, iOS | Không áp dụng (dùng trình chia sẻ của hệ điều hành) | |

## 4. Lịch sử

- 19/11/2026: tạo hợp đồng (TsuFiles bỏ kế hoạch làm client giao thức - phiếu TC2).
