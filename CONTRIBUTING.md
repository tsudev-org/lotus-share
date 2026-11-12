# Đóng góp cho Lotus Share

Lotus Share là ứng dụng truyền tệp trong mạng nội bộ của hệ sinh thái [tsudev](https://tsudev.com), mã nguồn mở
theo giấy phép Apache-2.0. Trang sản phẩm: <https://lotus.tsudev.com>.

## Báo lỗi, đề xuất tính năng

- Dùng mẫu **Bug report** / **Feature request** ở tab Issues. Ghi phiên bản (cuối màn hình Cài đặt), hệ điều hành
  và các bước tái hiện.
- **Lỗ hổng bảo mật: KHÔNG mở issue công khai** - làm theo [SECURITY.md](SECURITY.md).

## Gửi mã

1. Đọc [AGENTS.md](AGENTS.md) (quy ước tsudev + riêng repo) và mục "Chạy trong 5 phút".
2. Tạo nhánh từ `main`, commit theo `.standards/docs/GIT_WORKFLOW.md`, mở PR. Mọi PR phải qua đủ kiểm tra bắt buộc
   (flutter analyze/test, cargo test, CodeQL, gitleaks, quét phụ thuộc, i18n, website).
3. Sửa chuỗi giao diện: `app/assets/i18n/vi.json` + `en.json`, rồi `dart run slang` và
   `python3 -I tools/fix_slang_format.py`.
4. Đổi giao thức mạng (cổng, nhóm multicast, đường dẫn API, định dạng gói tin) là thay đổi phá vỡ: cần chủ dự án
   duyệt và nâng phiên bản tối thiểu ở `website/public/phien-ban.json` để bản cũ được yêu cầu cập nhật.

## Giấy phép

Đóng góp được phát hành theo Apache License 2.0 (xem [LICENSE](LICENSE) và [NOTICE](NOTICE)).
