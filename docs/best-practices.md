# OpenSSF Best Practices - Lotus Share

Câu trả lời hồ sơ <https://www.bestpractices.dev> (mức passing) nằm ở [`best-practices.json`](best-practices.json) -
nguồn sự thật nằm trong repo, công cụ `~/projects/logs/tools/bestpractices/bp.cjs` điền lên trang web từ tệp này.

Nguyên tắc: mỗi `Met` có bằng chứng kiểm được (URL tới tệp/workflow/PR trên `main`). Điều chưa làm ghi `Unmet` hoặc
`N/A` kèm lý do. Đổi cơ chế bảo mật, quy trình kiểm thử hay phát hành thì sửa tệp JSON trong cùng PR rồi điền lại.

Tiêu chí ghi `Unmet` (không bắt buộc ở mức passing): `dynamic_analysis_unsafe` - chưa chạy sanitizer cho các khối
`unsafe` bọc mô tả tệp (`File::from_raw_fd`, Android).
