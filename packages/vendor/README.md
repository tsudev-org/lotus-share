# Phụ thuộc đã đưa vào repo

Chép nguyên văn (giữ LICENSE của tác giả) để bản build không tải mã từ kho git bên ngoài.

| Thư mục | Nguồn | Commit | Lý do |
| --- | --- | --- | --- |
| `device_apps` | `github.com/Tienisto/device_apps` | `5dc7956d938541254d2e175766b3b84ea38bb85b` | Bản vá của gói `device_apps` đã ngừng bảo trì (liệt kê ứng dụng Android); bỏ thư mục `example` |
| `permission_handler_windows` | `github.com/localsend/permission_handler_windows_noop` | `2dadd8afbf81e0e3e4791d7144e689555e58f649` | Bản rỗng thay `permission_handler_windows` (gây lỗi trên Windows 7) |
| `nix-0.26.4` | crates.io `nix` 0.26.4 (MIT) | bản phát hành crates.io | `webrtc-util` 0.12 kéo vào; `libc` >= 0.2.191 bỏ `sockaddr_ctl`/`SYSPROTO_*` trên iOS => không biên dịch được cho iOS. Thu hẹp các mục đó về macOS + cho phép cảnh báo (`lib.rs`); nối bằng `[patch.crates-io]` ở `Cargo.toml` gốc. Bỏ khi nâng `webrtc` |

Sửa mã trong các thư mục này thì ghi chú `lotus-share:` tại chỗ sửa.
