# Đóng góp cho tsudev-lotus

tsudev-lotus là ứng dụng truyền tệp trong mạng nội bộ của hệ sinh thái [tsudev](https://tsudev.com), mã nguồn mở
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
4. Sửa trong phần mã kế thừa: giữ tối thiểu, đánh dấu chú thích `tsudev-lotus:` tại chỗ sửa.
5. Không đổi định dạng gói tin: tsudev-lotus giữ tương thích giao thức LocalSend v2.

## Ghi công

tsudev-lotus dựa trên mã nguồn mở LocalSend (c) Tien Do Nam và cộng đồng đóng góp, giấy phép Apache-2.0 (xem
[NOTICE](NOTICE)). Hướng dẫn đóng góp gốc lưu tại [docs/CONTRIBUTING.upstream.md](docs/CONTRIBUTING.upstream.md)
để tham khảo kỹ thuật.
