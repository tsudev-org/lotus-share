# Giao thức Lotus v2 - hợp đồng cho client trong hệ tsudev

> Đặc tả này viết từ mã thật của lõi Rust (`packages/core/src/`), nơi chạy cả khám phá thiết bị lẫn máy chủ HTTP của
> ứng dụng Lotus Share và CLI `lotus-share-cli`. Mẫu thông điệp: [`giao-thuc-mau/`](giao-thuc-mau/) - test
> `packages/core/tests/protocol_samples.rs` buộc mẫu khớp kiểu dữ liệu của lõi (đọc được và ghi lại y hệt).
> Hằng số mạng đối chiếu Dart/Rust ở `packages/core/tests/protocol_constants.rs`.
> Hiện chưa có client nào ngoài Lotus Share + CLI (TsuFiles bỏ kế hoạch làm client 19/11/2026 - phiếu
> `logs/handover/20261119-TC2_*`; ứng dụng khác muốn gửi tệp qua Lotus Share dùng hợp đồng
> [`MO-KEM-TEP.md`](MO-KEM-TEP.md)). Đặc tả giữ làm hợp đồng cho client tương lai trong hệ.

## 1. Cam kết ổn định

- Phiên bản giao thức hiện hành: **`2.2`** (trường `version`; hằng `PROTOCOL_VERSION_V2`). Đường dẫn `/api/lotus/v2/`.
- Trong v2 chỉ được **thêm** trường tùy chọn (bên nhận phải bỏ qua trường lạ) hoặc thêm endpoint. Đổi phá vỡ (đổi
  cổng, nhóm multicast, tên/kiểu trường bắt buộc, ý nghĩa mã trạng thái, cách tính vân tay) => tăng **`/api/lotus/v3/`**,
  nâng `toiThieu` ở `website/public/phien-ban.json` và mở phiếu cho mọi client trong hệ (nếu có) TRƯỚC khi phát hành.
- `/api/lotus/v3/nonce`, `/api/lotus/v3/register` đang thử nghiệm, chưa thuộc hợp đồng - client ngoài KHÔNG dùng.
- `/api/lotus/v2/show` là nội bộ (chỉ nhận từ máy cục bộ để đưa cửa sổ lên trước) - không thuộc hợp đồng.

## 2. Hằng số mạng

| Hằng | Giá trị |
| --- | --- |
| Cổng mặc định (UDP khám phá + TCP máy chủ của Lotus Share) | `53420` |
| Nhóm multicast IPv4 | `224.0.0.168`, TTL 1 |
| Nhóm multicast IPv6 | `ff12::1075:5ea0` (link-local), hop limit 1 |
| Thời hạn mỗi yêu cầu `register` khi khám phá | 500 ms |
| Quét mạng con | /24 của từng card mạng, 50 máy song song, chỉ cổng của chính máy quét (53420) |

## 3. Khám phá thiết bị

### 3.1. Gói chào (UDP)

Mỗi lần "chào", thiết bị gửi **3 lượt** cách khởi điểm 100 ms, 500 ms rồi 2 s; mỗi lượt gửi một datagram JSON UTF-8
tới nhóm multicast (`224.0.0.168:53420`, và `[ff12::1075:5ea0]:53420` khi có IPv6) trên **từng** card mạng, kèm một
bản tới **địa chỉ broadcast có hướng** của mạng con (vd `192.168.1.255:53420`) cho mạng chặn multicast. Bên nhận lọc
trùng theo (vân tay, địa chỉ) trong một đợt và bỏ gói của chính mình theo vân tay.

Mẫu: [`giao-thuc-mau/multicast.json`](giao-thuc-mau/multicast.json).

| Trường | Kiểu | Bắt buộc | Ghi chú |
| --- | --- | --- | --- |
| `alias` | chuỗi | có | Tên hiển thị |
| `version` | chuỗi | có | `"2.2"` |
| `deviceModel` | chuỗi | không | Tự do, hiện cho người dùng (tên ứng dụng hoặc đời máy) |
| `deviceType` | chuỗi | không | `mobile` \| `desktop` \| `web` \| `headless` \| `server`; giá trị lạ được hiểu là `desktop` |
| `fingerprint` | chuỗi | có | HTTPS: vân tay chứng thư (mục 5.1); HTTP: chuỗi ngẫu nhiên định danh thiết bị |
| `port` | số | có | Cổng TCP máy chủ HTTP(S) của **chính thiết bị gửi** - được khác 53420 |
| `protocol` | chuỗi | có | `https` \| `http` |
| `download` | bool | không (mặc định `false`) | API tải xuống qua trình duyệt đang bật |
| `announce` | bool | có khi gửi | `true` = gói chào, mong được trả lời |

### 3.2. Trả lời gói chào

Thiết bị nhận gói `announce: true` (và đang bật máy chủ) trả lời bằng **HTTP** `POST /api/lotus/v2/register` tới
`protocol://<IP nguồn của gói>:<port trong gói>` (IPv6 link-local kèm `%scope`), body là thông tin của mình (mục 4.1).
Với `https`, bên trả lời **ghim** vân tay đã chào: chứng thư máy chủ khác vân tay => không gửi. Không có trả lời bằng
multicast. Bên được trả lời thêm thiết bị đó vào danh sách từ chính yêu cầu `register` này.

### 3.3. Quét mạng con

Khi người dùng làm mới, ngoài việc chào, thiết bị gửi `POST register` tới mọi địa chỉ /24 ở **cổng 53420**. Hệ quả cho
client dùng cổng máy chủ khác 53420: chỉ được tìm thấy qua gói chào (mục 3.1) - hãy chào khi mở ứng dụng và
khi người dùng làm mới; quét mạng con của bên đó vẫn tìm thấy Lotus Share ở 53420.

## 4. API HTTP (`/api/lotus/v2/`)

Body và phản hồi là JSON UTF-8 (trừ `upload`). Lỗi trả `{"message": "..."}` ([mẫu](giao-thuc-mau/error-response.json)).
Đường dẫn khác => `404` không body.

### 4.1. `POST register` - đăng ký / trả lời gói chào

Body: [`register-request.json`](giao-thuc-mau/register-request.json) (các trường như mục 3.1, không có `announce`).
Phản hồi `200`: [`register-response.json`](giao-thuc-mau/register-response.json) (không có `port`, `protocol`).
Qua HTTPS, `fingerprint` trong body phải bằng vân tay chứng thư client của bắt tay TLS (so không phân biệt hoa thường);
lệch => vẫn `200` nhưng **bị bỏ qua** (không thêm vào danh sách thiết bị).

### 4.2. `GET info`

Phản hồi `200`: [`info-response.json`](giao-thuc-mau/info-response.json). Dùng để thăm dò một địa chỉ, không đăng ký.

### 4.3. `POST prepare-upload[?pin=<PIN>]` - xin gửi tệp

Body: [`prepare-upload-request.json`](giao-thuc-mau/prepare-upload-request.json): `info` (như 4.1) + `files` (khóa =
`id` của tệp). Mỗi tệp: `id`, `fileName`, `size` (byte), `fileType` (MIME), tùy chọn `sha256` (hex của nội dung - bên
nhận kiểm, lệch => `422` ở bước upload), `preview` (văn bản xem trước), `metadata.modified`/`metadata.accessed`
(ISO 8601). Tên tệp được chuẩn hóa NFC.

Yêu cầu **treo** đến khi người dùng bên nhận quyết định (không có thời hạn phía máy chủ).

| Mã | Nghĩa |
| --- | --- |
| `200` | Chấp nhận - [`prepare-upload-response.json`](giao-thuc-mau/prepare-upload-response.json): `sessionId` + token cho từng tệp ĐƯỢC NHẬN (có thể ít hơn số tệp gửi) |
| `204` | Chấp nhận nhưng không nhận tệp nào - không có phiên |
| `400` | `files` rỗng / JSON sai |
| `401` | Bên nhận đặt PIN mà thiếu hoặc sai `pin` |
| `403` | Người dùng từ chối (`"Rejected"`) hoặc bên gửi tự hủy khi đang chờ |
| `409` | Đang có phiên khác (`"Blocked by another session"`) - mỗi máy nhận một phiên tại một thời điểm |
| `429` | Sai PIN quá 3 lần (đếm theo địa chỉ; IPv6 theo /64) |

### 4.4. `POST upload?sessionId=&fileId=&token=` - gửi nội dung một tệp

Body là **byte thô** của tệp (không multipart). Mỗi tệp một yêu cầu, gửi song song được. Chỉ chấp nhận từ đúng địa
chỉ IP đã `prepare-upload`.

| Mã | Nghĩa |
| --- | --- |
| `200` | Đã lưu |
| `400` | Thiếu tham số |
| `403` | Sai phiên / token / IP, hoặc tệp không còn ở trạng thái chờ |
| `422` | `sha256` khai ở 4.3 không khớp nội dung |
| `500` | Lỗi ghi đĩa phía nhận |

### 4.5. `POST cancel[?sessionId=]` - hủy

Bên gửi hủy phiên (hoặc yêu cầu `prepare-upload` đang chờ - khi đó có thể bỏ `sessionId`). Chỉ nhận từ đúng IP bên
gửi. Luôn trả `200` không body (cả khi không có phiên khớp - thiết bị nhận khi đó chỉ báo cho ứng dụng biết bên kia
đã hủy); idempotent, gọi lại không sao.

### 4.6. `POST prepare-download`, `GET download` - chia sẻ qua trình duyệt

Phục vụ trang web "Chia sẻ qua liên kết" cho trình duyệt; client ứng dụng không cần dùng. Ngoài phạm vi hợp đồng.

## 5. Bảo mật

### 5.1. TLS hai chiều (mặc định `https`)

- Mỗi thiết bị tự sinh **chứng thư X.509 tự ký** (Lotus Share: RSA 2048) và giữ cố định.
- **Vân tay** = SHA-256 của chứng thư dạng **DER**, viết **hex chữ HOA**, không dấu phân cách (64 ký tự) - hàm
  `fingerprint_from_cert_der`.
- Máy chủ Lotus Share **bắt buộc chứng thư client** (mTLS) khi không bật chia sẻ qua trình duyệt; chấp nhận mọi chứng
  thư tự ký còn hạn và chữ ký hợp lệ (không cần CA). Client ngoài PHẢI gửi chứng thư của mình và khai đúng vân tay đó ở
  trường `fingerprint`.
- Client phải **ghim** vân tay máy chủ đã biết từ gói chào/`register`, bỏ qua tên máy (thiết bị gọi nhau bằng IP) -
  xem `packages/core/tests/v2_tls_pinning.rs` (chứng thư lạ bị từ chối).
- Không có lớp mã hóa nào ngoài TLS. "Mã hóa đầu-cuối" nghĩa là kênh TLS đi **thẳng** giữa hai thiết bị trong mạng
  nội bộ, không qua máy chủ trung gian; vân tay ghim là thứ chống người đứng giữa.

### 5.2. Chế độ `http`

Người dùng có thể tắt mã hóa trong Cài đặt; khi đó máy chủ chạy HTTP thường, `fingerprint` là chuỗi ngẫu nhiên. Hai
bên phải cùng chế độ. Client ngoài NÊN dùng `https`.

### 5.3. Chấp nhận client khác trong hệ

Không có danh sách trắng: mọi thiết bị nói đúng giao thức (vd `deviceModel: "iPhone"`, `deviceType: "mobile"`) được
hiển thị và **bên nhận Lotus Share hỏi người dùng** trước khi nhận tệp, trừ khi chính người dùng đó bật "tự nhận"
(cho mọi thiết bị, hoặc chỉ thiết bị yêu thích - khi đó tin bằng vân tay chứng thư client đã xác minh qua mTLS, không
tin trường `fingerprint` tự khai).

## 6. Hai ứng dụng trên cùng một máy

- Socket UDP khám phá của lõi mở `SO_REUSEADDR` (Linux/macOS thêm `SO_REUSEPORT`), bind `0.0.0.0:53420` /
  `[::]:53420` (chỉ IPv6) rồi tham gia nhóm; multicast loopback bật => hai ứng dụng trên cùng máy nhận gói chào của
  nhau (`packages/core/src/multicast/socket.rs`).
- Đã kiểm thật 19/11/2026 (Linux): `lotus-share-cli` đang chạy, một tiến trình thứ hai bind UDP 53420 với
  `SO_REUSEADDR`+`SO_REUSEPORT`, tham gia `224.0.0.168` => bind được và nhận gói chào của CLI.
- Yêu cầu với ứng dụng còn lại: cũng phải đặt `SO_REUSEADDR` (Linux/macOS thêm `SO_REUSEPORT`) TRƯỚC khi bind; ứng dụng
  nào bind độc quyền (Windows `SO_EXCLUSIVEADDRUSE`) sẽ chặn bên kia. Chỉ nhận multicast/broadcast trên 53420 - datagram
  unicast tới 53420 có thể chỉ tới một socket (Linux chia tải theo `SO_REUSEPORT`); giao thức không dùng UDP unicast.
- **TCP 53420 là của Lotus Share**: ứng dụng khác dùng cổng máy chủ riêng và khai trong trường `port`.
