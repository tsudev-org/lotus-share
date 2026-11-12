# Lotus Share

Chia sẻ tệp và tin nhắn giữa các thiết bị trong cùng mạng nội bộ (Wi-Fi, LAN) - không cần Internet, không cần
tài khoản, không qua máy chủ trung gian. Giao diện tiếng Việt mặc định, cấu hình bảo mật chặt.

Một sản phẩm của [tsudev](https://tsudev.com).

- Trang sản phẩm: <https://lotus.tsudev.com>
- Tải bản phát hành: <https://github.com/tsudev-org/lotus-share/releases/latest>

## Đặc điểm

| Hạng mục | Lotus Share |
| --- | --- |
| Ngôn ngữ | Tiếng Việt mặc định cho người dùng mới (vẫn chọn được "Theo hệ thống" hoặc 60+ ngôn ngữ khác); bản dịch tiếng Việt đủ 100% khóa, kể cả tên thiết bị ngẫu nhiên kiểu "Xoài Thông Minh" |
| Giao thức | Giao thức riêng của Lotus Share (cổng 53420, nhóm multicast 224.0.0.168); mọi thiết bị cần cùng chạy Lotus Share 2.0 trở lên. Bản quá cũ bị yêu cầu cập nhật khi mở |
| Phụ thuộc | Đã vá 7 thư viện Rust có lỗ hổng công bố (rustls, rustls-webpki, webpki-roots, tokio, h2, lru...) |
| Cổng kiểm CI | CodeQL (Rust, Actions), gitleaks toàn lịch sử, soát lỗ hổng OSV cho Rust + Dart, kiểm bản dịch, đối chiếu mã sinh |
| Liên kết | Trang chủ, chính sách quyền riêng tư, mã nguồn thuộc hệ sinh thái tsudev |

Chi tiết mô hình bảo mật: [docs/vi/KIEN-TRUC-BAO-MAT.md](docs/vi/KIEN-TRUC-BAO-MAT.md).

## Cách hoạt động (tóm tắt)

1. Mỗi thiết bị tự sinh một chứng thư TLS riêng; **dấu vân tay** (SHA-256 của chứng thư) là danh tính của máy.
2. Các máy tìm nhau bằng gói multicast UDP trong mạng nội bộ (cổng 53420), trả lời bằng HTTPS.
3. Tệp truyền trực tiếp giữa hai máy qua HTTPS, cả hai phía xác thực chứng thư của nhau (mTLS). Tệp và tin nhắn
   không đi ra Internet; Internet chỉ dùng để tải tệp số phiên bản công khai khi mở ứng dụng (`docs/vi/CAP-NHAT-BAT-BUOC.md`).

## Phát triển

Xem [AGENTS.md](AGENTS.md) mục B.2 (lệnh chạy, kiểm tra) và [docs/KIEN-TRUC-KY-THUAT.md](docs/KIEN-TRUC-KY-THUAT.md)
(kiến trúc kỹ thuật). Trạng thái công việc: [logs/STATE.md](logs/STATE.md).

```bash
cd app && flutter pub get && flutter run          # Flutter 3.47.9 (ghim trong .fvmrc)
python3 -I tools/check_i18n_vi.py                 # kiểm bản dịch tiếng Việt
python3 -I tools/osv_scan.py                      # soát lỗ hổng phụ thuộc
```

## Báo lỗi bảo mật

Không mở Issue công khai. Xem [SECURITY.md](SECURITY.md).

## Giấy phép

Apache License 2.0 - xem [LICENSE](LICENSE) và [NOTICE](NOTICE). (c) 2026 tsudev.
