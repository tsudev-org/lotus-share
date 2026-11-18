# Nhật ký thay đổi - Lotus Share

## 26.11.1901 - 19/11/2026

- **Sửa lỗi nghiêm trọng của 26.11.1801: ứng dụng không mở được** (Windows, Linux, macOS, Android - hiện màn hình lỗi
  "codegen version (2.12.0) should be the same as runtime version (2.13.0)"). Nguyên nhân: lần nâng phụ thuộc trước bản
  26.11.1801 nâng một thư viện cầu nối Dart-Rust lệch với mã sinh. Đã ghim lại, thêm kiểm tra tự động chặn lệch. CLI
  `lotus-share-cli` không bị ảnh hưởng. Giao thức không đổi.

- Người dùng mới: lần đầu mở theo **ngôn ngữ và chế độ sáng/tối của hệ thống** (ngôn ngữ chưa có bản dịch => tiếng
  Anh). Máy đã cài mà chưa từng đổi thì giữ nguyên tiếng Việt + giao diện Tối như trước.
- Website lotus.tsudev.com: lần đầu vào theo chế độ sáng/tối của máy.
- Tên thương hiệu hiển thị `TsuDEV` (dòng bản quyền, nhà phát hành trong bộ cài và thông tin tệp `.exe`).
- Siêu dữ liệu ứng dụng (iOS, bản web, dòng bản quyền tệp cài) chỉ ghi tên Lotus Share.

## 26.11.1801 - 18/11/2026

- **Số phiên bản mới** theo quy ước chung của tsudev: `26.11.1801` (năm.tháng.ngày + thứ tự trong ngày) thay cho
  `2.0.0-lotus.7`. Bản đã cài vẫn nhận ra đây là bản mới hơn; giao thức không đổi, nói chuyện được với 2.0.0.
  Tên tệp tải về đổi theo khuôn `lotus-share_26.11.1801_windows-x64-setup.exe` (AppImage giữ tên cũ để tự cập nhật).
- CLI `lotus-share-cli` kiểm bản mới lúc khởi động như ứng dụng: bản quá cũ dừng kèm hướng dẫn cập nhật, có bản mới
  thì nhắc một dòng; bỏ kiểm bằng `--khong-kiem-cap-nhat` hoặc `LOTUS_SHARE_KHONG_KIEM_CAP_NHAT=1`. `--version` và
  thông tin tệp `.exe` Windows hiện đúng phiên bản sản phẩm.
- Nâng các phụ thuộc Rust/Dart trong phạm vi tương thích; CI chặn mọi cảnh báo clippy của lõi Rust.

## 2.0.0 (lotus.7)

Lotus Share trở thành sản phẩm độc lập của tsudev, có giao thức mạng, cấu hình và định danh riêng.

- **Giao thức riêng**: cổng 53420, nhóm multicast `224.0.0.168` / `ff12::1075:5ea0`, đường dẫn `/api/lotus/v2/`.
  Thiết bị chạy Lotus Share 1.x hoặc ứng dụng khác không còn thấy máy chạy 2.0: hãy cập nhật mọi thiết bị.
- **Bắt buộc cập nhật**: mở bản đã quá cũ sẽ hiện hộp thoại yêu cầu cập nhật trước khi dùng tiếp; bản mới hơn
  (không bắt buộc) hiện thông báo có thể bỏ qua. Không có Internet thì ứng dụng vẫn dùng được như bình thường.
- **Sửa "không thấy máy Linux"**: ứng dụng luôn quét mạng con sau 1 giây, kể cả khi đã thấy thiết bị khác (trước
  đây thấy điện thoại là bỏ quét, nên máy mà multicast không tới được không bao giờ hiện).
- Linux: Cài đặt > Khắc phục sự cố > Sửa lỗi tự động mở cổng trên ufw/firewalld; công cụ `chan-doan-mang.sh` trong
  gói tar.gz.
- Windows: tệp cấu hình riêng `%APPDATA%\Lotus Share\settings.json`, không còn đọc cấu hình của ứng dụng khác (nguyên
  nhân tên thiết bị tiếng Anh kiểu "Strategic Tomato"). Lần đầu mở bản 2.0 trên Windows: tên thiết bị, thiết bị yêu
  thích, lịch sử nhận được tạo mới.
- Tên thiết bị ngẫu nhiên tiếng Anh tự đổi sang tiếng Việt; tên tự đặt giữ nguyên.
- Cổng, nhóm multicast, thiết bị yêu thích đã lưu theo giá trị cũ tự chuyển sang giá trị mới.

## 1.18.2 (lotus.5) - 12/11/2026

- Khám phá thiết bị: gửi thêm broadcast có hướng song song multicast; Android giữ MulticastLock; card mạng ảo/VPN
  xếp cuối khi quét.
- Bộ cài Windows `-setup.exe`: tạo/xóa quy tắc tường lửa theo chương trình, tự gỡ bản `tsudev-lotus` cũ; công cụ
  "Lotus Share - Sửa lỗi kết nối" (`chan-doan-mang.ps1`).

## 1.18.2 (lotus.4) - 12/11/2026

- Thêm bản Windows ARM64 (bộ cài + ZIP), Linux ARM64 (AppImage + tar.gz), CLI Linux/Windows ARM64.

## 1.18.2 (lotus.3) - 12/11/2026

- Bảo mật (security fix): nâng `rustix` 1.1.4 -> 1.1.6, vá **RUSTSEC-2026-0486**.

- Đổi tên sản phẩm thành **Lotus Share**: định danh `com.tsudev.lotusshare`, logo riêng, tên gói `lotus-share`.
- Trang Ủng hộ chỉ mở `lotus.tsudev.com/ung-ho/`.

## 1.18.2 (lotus.2) - 10/11/2026

- Bản phát hành công khai đầu tiên: tiếng Việt mặc định, giao diện tối tím, gia cố mã PIN, vá phụ thuộc có lỗ hổng,
  SHA256SUMS ký Sigstore và chứng thực SLSA cho mọi tệp phát hành.
- Bảo mật (security fixes) - lỗ hổng công bố đã vá trong bản này: `rustls` 0.23.46 (**RUSTSEC-2026-0285, 0346, 0348,
  0349**), `rustls-webpki` 0.103.16 (**RUSTSEC-2026-0382**), `webpki-roots`/`webpki-root-certs` 1.0.11
  (**RUSTSEC-2026-0381, 0383**), `tokio` 1.54.1 (**RUSTSEC-2026-0386**), `h2` 0.4.20 (**RUSTSEC-2026-0258**), `lru`
  0.18.5 (**RUSTSEC-2026-0253**). Gia cố PIN: so sánh thời gian hằng, đếm lần sai theo khối /64 IPv6.
