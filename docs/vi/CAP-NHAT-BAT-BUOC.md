# Bắt buộc cập nhật - cơ chế và quy trình

> Có từ Lotus Share 2.0.0 (build 65), 12/11/2026. Mã: `app/lib/util/update_check.dart`,
> `app/lib/widget/dialogs/update_dialog.dart`; dữ liệu: `website/public/phien-ban.json`.

## 1. Cơ chế

1. Mở ứng dụng (sau khi máy chủ nhận tệp khởi động), ứng dụng tải `https://lotus.tsudev.com/phien-ban.json` ở nền
   (quá giờ 8 giây, không theo chuyển hướng, tối đa 16 KB):

   ```json
   { "schema": 1, "phienBan": "2.0.0", "moiNhat": 65, "toiThieu": 65 }
   ```

2. So **số build** của ứng dụng (phần sau `+` trong `app/pubspec.yaml`) với tệp:
   - nhỏ hơn `toiThieu`: dừng máy chủ nhận tệp, hiện hộp thoại **không đóng được** "Cần cập nhật Lotus Share" với nút
     *Tải bản mới* (mở `https://lotus.tsudev.com/tai-ve/`) và *Thoát* (iOS không có nút Thoát theo quy định Apple);
   - nhỏ hơn `moiNhat`: hộp thoại "Đã có Lotus Share x.y.z" bỏ qua được; bấm *Để sau* thì không hỏi lại cho bản đó.
3. `toiThieu` lớn nhất từng thấy được lưu (`ls_update_min_build`, chỉ tăng): lần mở sau **không có Internet** vẫn bị
   chặn. Không tải được tệp và chưa từng thấy mức tối thiểu: ứng dụng chạy bình thường (ứng dụng mạng nội bộ, thường
   dùng khi không có Internet).
4. An toàn: địa chỉ tệp và liên kết tải về **cố định trong ứng dụng**; nội dung tệp chỉ là số. Kẻ chiếm được tên miền
   chỉ có thể chặn ứng dụng (từ chối dịch vụ), không dẫn người dùng tới tệp cài độc hại. Tệp sai khuôn bị bỏ qua.

## 2. Khi nào nâng `toiThieu`

- Đổi giao thức mạng (cổng, nhóm multicast, đường dẫn API, định dạng gói tin) - bản cũ không còn thấy bản mới.
- Lỗ hổng bảo mật nghiêm trọng ở bản cũ.
- Không nâng chỉ vì có tính năng mới (dùng `moiNhat` để nhắc).

## 3. Quy trình khi phát hành

1. Tăng số build trong `app/pubspec.yaml` (mỗi bản phát hành một số mới, không dùng lại).
2. Gắn nhãn, chờ bản phát hành Publish xong (`docs/vi/PHAT-HANH.md`).
3. Sửa `website/public/phien-ban.json`: `phienBan` + `moiNhat` = bản vừa phát hành; nâng `toiThieu` nếu cần (mục 2,
   cần chủ dự án duyệt). Build website kiểm `toiThieu <= moiNhat <= số build pubspec`.
4. Deploy website **sau** khi bản phát hành đã công khai - tránh chặn người dùng khi chưa có bản để tải.

## 4. Giới hạn

- Bản phát hành trước 2.0.0 (`1.18.2-lotus.2` đến `.5`) **không có** cơ chế này nên không thể hiện hộp thoại. Từ 2.0
  các bản đó cũng không thấy thiết bị chạy 2.x (giao thức riêng); trang Tải về và mục "Không thấy thiết bị?" hướng
  dẫn cập nhật.
- CLI `lotus-share-cli` chưa kiểm phiên bản (task trong `logs/STATE.md`).
