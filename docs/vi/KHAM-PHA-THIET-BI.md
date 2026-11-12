# Khám phá thiết bị - cơ chế, nguyên nhân "không thấy nhau" và công cụ chẩn đoán

> Cập nhật 12/11/2026 (nhánh `fix/kham-pha-thiet-bi`). Giữ tương thích giao thức LocalSend v2: cổng 53317, nhóm
> multicast `224.0.0.167`, định dạng gói tin không đổi.

## 1. Cơ chế

1. Mỗi máy mở một socket UDP cổng 53317 trên **từng** card mạng IPv4 (lõi Rust `packages/core/src/multicast/`), gửi
   chuỗi thông báo (100 ms, 500 ms, 2 s) tới nhóm multicast `224.0.0.167:53317`.
2. Máy nhận thông báo trả lời bằng yêu cầu HTTP(S) `POST /api/localsend/v2/register` tới máy kia. Thiết bị chỉ hiện
   trong danh sách khi một chiều HTTP thành công (`discovery/mod.rs`: `answer_announcement`).
3. Sau 1 giây chưa thấy ai, ứng dụng quét HTTP tối đa 3 mạng con đầu tiên trong danh sách địa chỉ đã xếp hạng
   (`app/lib/provider/network/scan_facade.dart`, `local_ip_provider.dart`).

Hệ quả: chỉ cần **một** trong ba đường (multicast tới máy kia, HTTP vào máy kia, quét HTTP) thông là hai máy thấy nhau.
"Không thấy nhau" nghĩa là cả ba đường đều đứt.

## 2. Nguyên nhân đã xác định và cách đã sửa

| # | Nguyên nhân | Biểu hiện | Đã sửa |
| --- | --- | --- | --- |
| 1 | Tường lửa Windows chặn kết nối đến. Bộ cài không tạo quy tắc; hộp thoại tường lửa lần chạy đầu bị bỏ qua, hoặc bấm Hủy (Windows tự tạo quy tắc **Chặn**, thắng mọi quy tắc cho phép), hoặc mạng đặt "Công cộng" | Điện thoại không thấy máy tính; máy tính đôi khi thấy điện thoại | Bộ cài Inno tạo quy tắc cho phép TCP + UDP theo **chương trình** (mọi loại mạng), xóa quy tắc cũ/chặn gắn với chương trình trước; gỡ cài đặt xóa sạch. Tùy chọn có dấu chọn sẵn, cần cài với quyền quản trị (`support/scripts/compile_windows_exe-inno.iss`) |
| 2 | Bộ phát Wi-Fi / router bỏ gói multicast (IGMP snooping, "multicast to unicast", Wi-Fi mesh) | Cả hai chiều không thấy nhau dù cùng mạng | Lõi Rust gửi **thêm** gói broadcast có hướng (vd `192.168.1.255:53317`) cùng nội dung trên mỗi card mạng có địa chỉ broadcast (bỏ /31, /32, VPN điểm-điểm). Máy LocalSend v2 nghe `0.0.0.0:53317` nên nhận được không cần sửa gì. Mỗi người gửi chỉ được trả lời một lần trong 300 ms (`RecentAnswers`) để không nhân đôi yêu cầu register |
| 3 | Android lọc gói multicast khi ứng dụng không giữ `WifiManager.MulticastLock` (tùy chip Wi-Fi/hãng) | Điện thoại không nghe được máy tính | `MainActivity.kt` giữ MulticastLock khi ứng dụng hiển thị (`onStart`/`onStop`), quyền thường `CHANGE_WIFI_MULTICAST_STATE` |
| 4 | Laptop có card mạng ảo (WSL, Hyper-V, VirtualBox, VMware, Docker) hoặc VPN (Tailscale, ZeroTier, Radmin, Hamachi): 3 mạng con được quét HTTP có thể toàn là mạng ảo | Bước quét dự phòng không bao giờ chạm tới mạng Wi-Fi thật | `local_ip_provider.dart`: card ảo/VPN (theo tên card và dải 100.64/10, 25/8, 26/8, 169.254/16) xếp cuối danh sách |
| 5 | Bản cũ `tsudev-lotus` (AppId khác) hoặc LocalSend gốc chạy nền ở khay hệ thống, giữ cổng 53317 | Lotus Share mở sau không bật được máy chủ nhận tệp | Bộ cài tự gỡ im lặng bản `tsudev-lotus` cũ (AppId `{E6A866CD-...}`), tắt tiến trình cũ, xóa khóa tự khởi động cũ. Không đụng LocalSend gốc; công cụ chẩn đoán báo tiến trình nào giữ cổng |
| 6 | Wi-Fi cơ quan/quán cà phê bật cách ly thiết bị (client isolation), Wi-Fi khách, tách mạng 2,4/5 GHz | Không ứng dụng chia sẻ nội bộ nào hoạt động | Không sửa được từ ứng dụng. Công cụ chẩn đoán đếm thiết bị thấy được qua bảng ARP để nhận ra; hướng dẫn dùng điểm phát Wi-Fi |

## 3. Công cụ chẩn đoán Windows `support/scripts/chan-doan-mang.ps1`

Đi kèm bộ cài (lối tắt **Lotus Share - Sửa lỗi kết nối** trong menu Start) và bản ZIP di động. Không gửi gì ra Internet.

1. Ứng dụng có chạy không, tiến trình nào giữ TCP/UDP 53317 (phát hiện LocalSend/bản cũ tranh cổng).
2. Tường lửa: trạng thái từng hồ sơ, quy tắc cho phép/chặn theo chương trình và theo cổng, chính sách nhóm cấm quy tắc
   cục bộ.
3. Loại mạng (Công cộng/Riêng tư).
4. Card mạng IPv4: card thật/ảo/VPN, VPN giữ đường mặc định, địa chỉ 169.254 (không nhận được DHCP).
5. Quét mạng `/24` của từng card thật: TCP 53317 rồi `GET /api/localsend/v2/info` - liệt kê mọi thiết bị đang mở Lotus
   Share/LocalSend; đếm hàng xóm ARP để nhận ra cách ly thiết bị.
6. Không thấy ai: hỏi IP của điện thoại (tab Nhận) và kết nối thử - tách lỗi tường lửa máy này với lỗi mạng.

Tìm thấy lỗi thì hỏi trước khi sửa (tự xin UAC): tạo quy tắc tường lửa + xóa quy tắc chặn; đổi mạng Công cộng sang
Riêng tư chỉ khi người dùng đồng ý riêng.

Chạy tay (máy phát triển, từ WSL):

```bash
cp support/scripts/chan-doan-mang.ps1 /mnt/c/Users/Public/
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'C:\Users\Public\chan-doan-mang.ps1' -NoPause -Exe 'C:\Program Files\Lotus Share\lotus_share.exe'
```

Đã chạy thật 12/11/2026 trên máy phát triển (Windows 11, Wi-Fi Intel AC 8260 + vEthernet WSL): nhận đúng mạng Wi-Fi
đặt Công cộng, card WSL là card ảo, quy tắc cổng 53317 cũ của LocalSend/tsudev-lotus, mạng không cách ly (11 thiết bị
ARP), không có thiết bị Lotus Share/LocalSend nào khác đang mở lúc đo.

## 4. Kiểm thử

- Rust: `cd packages/core && cargo test --features full` (`util::interface` - địa chỉ broadcast; `discovery` -
  `RecentAnswers`).
- Dart: `flutter test test/unit/provider/network_info_provider_test.dart` (xếp hạng card ảo, nhận diện tên card).
- Bộ cài + Android: build thử `release-lotus.yml` (workflow_dispatch) - ISCC biên dịch `[Code]`/`[CustomMessages]`,
  Gradle biên dịch `MainActivity.kt`.
- Thử thật cần 2 thiết bị: Windows mới cài (tường lửa mặc định) + điện thoại Android cùng Wi-Fi; kiểm cả mạng đặt
  Công cộng. Ghi kết quả vào `logs/STATE.md`.
