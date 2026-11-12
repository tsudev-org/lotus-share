# Nhật ký thay đổi - Lotus Share

## 2.0.0 (lotus.6)

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

- Đổi tên sản phẩm thành **Lotus Share**: định danh `com.tsudev.lotusshare`, logo riêng, tên gói `lotus-share`.
- Trang Ủng hộ chỉ mở `lotus.tsudev.com/ung-ho/`.

## 1.18.2 (lotus.2) - 10/11/2026

- Bản phát hành công khai đầu tiên: tiếng Việt mặc định, giao diện tối tím, gia cố mã PIN, vá phụ thuộc có lỗ hổng,
  SHA256SUMS ký Sigstore và chứng thực SLSA cho mọi tệp phát hành.
