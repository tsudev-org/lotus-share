# Kiến trúc bảo mật - tsudev-lotus

> Tài liệu sống. Cập nhật mỗi khi đổi cơ chế bảo mật, nâng phụ thuộc mật mã hoặc chấp nhận rủi ro mới.
> Lần rà soát đầu: 10/11/2026, trên upstream `localsend/localsend@8476c091` (v1.18.2).

## 1. Phạm vi và tài sản cần bảo vệ

| Tài sản | Mức | Nơi ở |
| --- | --- | --- |
| Tệp, tin nhắn người dùng đang truyền | D3 | Bộ nhớ + đĩa của máy gửi/nhận |
| Khóa riêng TLS của thiết bị (danh tính máy) | D3 | Cài đặt ứng dụng (shared preferences) trên máy |
| Danh sách thiết bị yêu thích (đã ghép đôi) | D2 | Cài đặt ứng dụng |
| Mã PIN nhận tệp, PIN chia sẻ qua liên kết | D2 | Cài đặt ứng dụng |
| Tên thiết bị, kiểu máy | D1 | Phát quảng bá trong mạng LAN |

## 2. Ranh giới tin cậy

- **Không có máy chủ trung gian.** Mọi trao đổi diễn ra trực tiếp giữa hai máy trong cùng mạng nội bộ. Tính năng
  WebRTC (cần máy chủ tín hiệu ngoài Internet) đang TẮT trong mã (`webRTCEnabled = false`).
- Kẻ tấn công giả định: một máy khác **trong cùng mạng LAN/Wi-Fi** (quán cà phê, văn phòng, Wi-Fi công cộng),
  có thể nghe lén, giả mạo gói multicast, dò cổng, đoán PIN.
- Ứng dụng KHÔNG chống được: máy đã bị chiếm quyền (mã độc đọc được cài đặt ứng dụng), người dùng tự bấm chấp
  nhận tệp từ máy lạ.

## 3. Các lớp bảo vệ

| Lớp | Cơ chế | Mã nguồn |
| --- | --- | --- |
| Danh tính | Mỗi máy tự sinh chứng thư TLS (RSA 2048); danh tính = SHA-256 của chứng thư (DER, hex hoa) | `packages/core/src/crypto/cert.rs` |
| Kênh truyền | HTTPS (TLS 1.2/1.3, rustls + ring), mặc định BẬT (`ls_https`) | `packages/core/src/http/` |
| Xác thực hai chiều | Máy khách bắt buộc trình chứng thư (mTLS); máy chủ bỏ qua gói đăng ký có dấu vân tay không khớp chứng thư | `http/server/common/client_cert_verifier.rs` |
| Ghim chứng thư | Máy khách chỉ chấp nhận chứng thư có đúng dấu vân tay đã biết; kiểm ngay trong bắt tay TLS, trước khi gửi byte dữ liệu nào | `http/client/server_cert_verifier.rs` |
| Phê duyệt | Mọi phiên nhận tệp cần người dùng bấm Chấp nhận; "Lưu nhanh" mặc định chỉ áp dụng cho thiết bị yêu thích (`QuickSaveMode.paired`), nhận diện bằng dấu vân tay mTLS (không tin dấu vân tay tự khai ở chế độ HTTP) | `app/lib/provider/persistence_provider.dart` |
| Mã PIN | Tùy chọn PIN khi nhận; tối đa 3 lần sai mỗi địa chỉ, sau đó trả 429 | `http/server/common/pin.rs` |
| Chống quá tải | Tối đa 64 kết nối đồng thời, 8 kết nối mỗi IP; một phiên tải lên tại một thời điểm | `http/server/connection_limit.rs` |
| Không đi vòng | Máy khách tắt proxy hệ thống và không theo chuyển hướng HTTP | `http/client/mod.rs` |
| Lọc mạng | Danh sách cho phép/chặn giao diện mạng (Cài đặt > Mạng) | `app/lib/util/network_interfaces.dart` |
| Kiểm tra toàn vẹn | Có thể tạo checksum cho tệp nhận (`ls_create_checksums`, mặc định BẬT) | `app/lib/provider/persistence_provider.dart` |

## 4. Thay đổi bảo mật của bản fork

| Ngày | Thay đổi | Lý do |
| --- | --- | --- |
| 10/11/2026 | Nâng `rustls` 0.23.46, `rustls-webpki` 0.103.16, `webpki-roots`/`webpki-root-certs` 1.0.11, `tokio` 1.54.1, `h2` 0.4.20, `lru` 0.18.5 | Vá RUSTSEC-2026-0285/0346/0348/0349 (rustls), 0382 (webpki), 0381/0383 (gốc tin cậy emSign), 0386 (tokio), 0258 (h2), 0253 (lru) |
| 10/11/2026 | So sánh PIN thời gian hằng; đếm số lần sai theo khối /64 với IPv6 | Chặn đoán PIN bằng cách xoay vòng địa chỉ IPv6 (mỗi máy LAN tự sinh được vô số địa chỉ trong /64 của mình) |
| 10/11/2026 | Máy chủ tín hiệu WebRTC lấy từ cấu hình thay vì địa chỉ viết cứng; bỏ lệnh in khóa riêng ra nhật ký | Chuẩn bị tự dựng máy chủ tín hiệu; không để khóa riêng xuất hiện trong log |
| 10/11/2026 | CI: CodeQL (Rust, Actions), gitleaks toàn lịch sử, `tools/osv_scan.py` (Rust + Dart), Dependabot hằng tháng | Phát hiện sớm lỗ hổng mã và phụ thuộc |
| 10/11/2026 | Gỡ `winget.yml` của upstream | Workflow tự phát hành lên định danh winget của LocalSend - không thuộc bản fork |
| 10/11/2026 | Định danh cài đặt riêng (`com.tsudev.lotus`, AppId Inno mới, thư mục cấu hình CLI riêng); AppImage tự cập nhật từ repo tsudev | Không ghi đè/dùng chung dữ liệu, khóa TLS hay luồng cập nhật với LocalSend |
| 11/11/2026 | Nâng `rustix` 1.1.4 -> 1.1.6 | Vá RUSTSEC-2026-0486 (công bố 11/11/2026, CI `osv_scan` chặn) |
| 11/11/2026 | Thiết bị yêu thích chỉ được nhận diện bằng dấu vân tay lấy từ chứng thư mTLS; ở chế độ HTTP không còn "Lưu nhanh" hay tên yêu thích cho máy gửi | Ở HTTP, dấu vân tay trong JSON do máy gửi tự khai: máy lạ trong LAN mạo danh thiết bị yêu thích để tệp được lưu không cần bấm Chấp nhận (`app/lib/util/favorites.dart`) |
| 10/11/2026 | Phát hành: SHA256SUMS ký Sigstore keyless, chứng thực SLSA từng tệp, SBOM SPDX, APK ký khóa tsudev có ghim dấu vân tay | Người dùng kiểm được tệp tải về đến từ đúng workflow, đúng mã nguồn (`docs/vi/PHAT-HANH.md`) |

## 5. Rủi ro đã chấp nhận (có hạn xem lại)

Danh sách chính thức nằm trong `tools/osv_scan.py` (biến `ACCEPTED`); CI trượt lại khi hết hạn.

| Mã | Gói | Vì sao chấp nhận | Xem lại |
| --- | --- | --- | --- |
| RUSTSEC-2023-0071 | `rsa` 0.9 (Marvin) | Chỉ dùng để sinh khóa và xác minh chữ ký PSS bằng khóa công khai; không giải mã/ký bằng khóa riêng qua crate này. Bản vá chỉ có ở 0.10 (đổi API) | 31/03/2027 |
| RUSTSEC-2026-0387 | `crypto-bigint` 0.5 | Chỉ nằm trong nhánh WebRTC đang tắt | 31/03/2027 |
| RUSTSEC-2025-0141, 2026-0441 | `bincode`, `pin-utils` | Cảnh báo "ngừng bảo trì", không phải lỗ hổng | 31/03/2027 |

## 6. Khuyến nghị cho người dùng

1. Bật **Yêu cầu mã PIN** (Cài đặt > Nhận) khi dùng Wi-Fi công cộng; dùng PIN từ 6 chữ số.
2. Giữ "Lưu nhanh" ở chế độ **chỉ thiết bị yêu thích**; không bật cho mọi thiết bị.
3. Trước khi thêm thiết bị vào Yêu thích, so dấu vân tay (biểu tượng) hiển thị trên hai máy.
4. Không tắt HTTPS (Cài đặt > Mạng > Mã hóa) trừ khi cần tương thích với bản rất cũ.

## 7. Việc tiếp theo

Theo dõi trong `logs/STATE.md`: chứng thư Authenticode (SignPath Foundation) và Apple Developer ID, tự dựng máy chủ
tín hiệu khi bật WebRTC, nâng `rsa` lên 0.10.
