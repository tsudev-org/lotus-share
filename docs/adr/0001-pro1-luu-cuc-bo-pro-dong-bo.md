# ADR-0001: PRO1 - lưu cục bộ mặc định, TsuDEV Pro chỉ thêm đồng bộ danh sách thiết bị và cài đặt

- **Trạng thái**: ĐÃ CHẤP NHẬN (20/11/2026) - phần mã chờ thành phần dùng chung (mục 5)
- **Bối cảnh quyết định**: phiếu `logs/handover/20261119-PRO1_luu-cuc-bo-pro-dong-bo.md` (mục 5 "Đã chốt"), phiếu gốc
  `~/projects/logs/handover/20261119-PRO1_ke-hoach-luu-cuc-bo-pro-dong-bo-toan-he.md`, chuẩn `.standards/docs/PRODUCT_POLICY.md`
  mục 7 (v3.9.1). Chủ dự án xác nhận 19/11/2026: chưa có người dùng thật.

## 1. Kiểm kê: dữ liệu nào rời thiết bị (bản hiện tại, 26.11.1901)

Đo bằng đọc mã (`app/lib`, `cli/src`, `packages/core/src`) và lệnh `grep` các thư viện đo lường/báo lỗi (Sentry,
Firebase, Crashlytics, PostHog, analytics, telemetry): **không có**.

| # | Đường đi | Dữ liệu gửi | Tới đâu | Ai khởi động | Kết luận PRO1 |
| --- | --- | --- | --- | --- | --- |
| 1 | Khám phá thiết bị (UDP multicast `224.0.0.168` / `ff12::1075:5ea0`, cổng 53420) + đăng ký HTTPS `/api/lotus/v2/register` | Bí danh, kiểu máy, loại thiết bị, vân tay chứng thư TLS, cổng | Máy khác **trong mạng LAN**, không qua máy chủ | Tự động khi mở app | Giữ miễn phí - không rời mạng cục bộ (N2 nói về internet/đám mây) |
| 2 | Truyền tệp/chữ (`/api/lotus/v2/prepare-upload`, `upload`, chia sẻ qua liên kết `web_link`) | Tệp người dùng (D3) | Máy nhận trong LAN, HTTPS đầu-cuối bằng chứng thư tự ký của thiết bị | Người dùng | Giữ miễn phí (phiếu PRO1 mục 1). Tệp D3 KHÔNG BAO GIỜ đi qua máy chủ |
| 3 | Kiểm tra cập nhật bắt buộc: `GET https://lotus.tsudev.com/phien-ban.json` (app `app/lib/util/update_check.dart`, CLI `cli/src/update_check.rs`) | Không có dữ liệu người dùng; máy chủ thấy IP + User-Agent (`lotus-share-cli/<phiên bản>` ở CLI, mặc định Dart ở app) | Cloudflare Pages (tĩnh) | Tự động khi mở | Giữ - không phải dữ liệu người dùng; bắt buộc theo `docs/vi/CAP-NHAT-BAT-BUOC.md` |
| 4 | Mở liên kết (trang chủ, Ủng hộ, quyền riêng tư, GitHub) | Không (trình duyệt hệ thống mở URL) | tsudev.com, lotus.tsudev.com, github.com | Người dùng bấm | Giữ |
| 5 | WebRTC: tín hiệu `wss://signal.lotus.tsudev.com/v1/ws` + STUN Cloudflare | (Nếu bật) mô tả phiên, địa chỉ IP | Internet | - | **TẮT lúc biên dịch** (`webRTCEnabled = false`), không có kết nối. Bật lại = relay/ghép nối qua internet ⇒ cần 👤 duyệt (N7) - ngoài phạm vi ADR này |

Dữ liệu chỉ nằm trên thiết bị (SharedPreferences, `app/lib/provider/persistence_provider.dart`): cài đặt (`ls_alias`,
`ls_theme`, `ls_color`, `ls_locale`, `ls_port`, `ls_destination`, `ls_quick_save`, danh sách mạng cho phép/chặn...),
**thiết bị yêu thích** (`ls_favorites`), lịch sử nhận (`ls_receive_history`), khóa riêng + chứng thư TLS của thiết bị
(`ls_security_context`). Không máy chủ nào của hệ đang giữ dữ liệu người dùng Lotus Share.

**Kết luận kiểm kê**: bản miễn phí hiện ĐÃ đạt N2 - không có đường đồng bộ/sao lưu miễn phí nào phải tắt. Việc "tắt
đường gửi dữ liệu lên mạng ở bản miễn phí" của phiếu PRO1 với repo này là **không cần thay đổi mã**.

## 2. Quyết định: phần nào là Pro

| Tính năng | Gói | Ghi chú |
| --- | --- | --- |
| Khám phá + truyền tệp/chữ trong LAN, chia sẻ qua liên kết LAN, CLI | **Miễn phí, mãi mãi** | Cốt lõi sản phẩm; không tốn tài nguyên máy chủ (N7) |
| Xuất/nhập **tệp** cài đặt + thiết bị yêu thích (JSON, người dùng tự giữ) | **Miễn phí** | N2: quyền mang dữ liệu đi. Làm cùng đợt mã Pro (là liên kết "Sao lưu ra tệp (miễn phí)" của thông báo mục 7.3) |
| Đồng bộ **thiết bị yêu thích** (`ls_favorites`: bí danh + vân tay) và **cài đặt không gắn máy** giữa các thiết bị cùng tài khoản tsudev | **TsuDEV Pro** | Qua TsuDEV Sync (`tsudev-org/tsusync`, không gian tên `lotus-share`), mã hóa đầu cuối (PRODUCT_POLICY 7.4); hạn mức mặc định 100 MiB thừa xa (dữ liệu vài KiB) |
| Huy hiệu Pro/Ủng hộ cạnh tên tài khoản | Theo JWS | `TsuBadge` từ `tsudev_ui` |

**KHÔNG BAO GIỜ đồng bộ** (kể cả Pro): khóa riêng TLS + chứng thư thiết bị (`ls_security_context` - định danh riêng mỗi
máy; chép sang máy khác là hai máy trùng vân tay, phá mô hình tin cậy), lịch sử nhận (tên tệp người dùng, D3), cài đặt
gắn máy (`ls_port`, `ls_destination`, mạng cho phép/chặn, vị trí/cỡ cửa sổ, `ls_multicast_group`), tệp người dùng.
**Không thêm relay tệp qua internet** (băng thông trái N7) khi 👤 chưa duyệt ADR mới.

Không có tính năng Pro nào khác: Lotus Share không khóa bớt tính năng truyền tệp để bán Pro.

## 3. Ân hạn, hết hạn, kênh thanh toán

- Chưa có người dùng thật + chưa có đường đồng bộ miễn phí ⇒ không cần ân hạn chuyển tiếp.
- Pro hết hạn: theo PRODUCT_POLICY 7.2 (TsuDEV Sync chặn đẩy `402 pro_required`, kéo 90 ngày, báo trước 30/7 ngày).
  Danh sách yêu thích + cài đặt trên thiết bị không bao giờ bị xóa; app chỉ ngừng đẩy/kéo.
- Kênh (PRODUCT_POLICY 3.3, 4.3, 7.4): bản Google Play ⇒ IAP `tsudev_pro` (`thang`/`nam`), `ung_ho_*`; bản ngoài cửa
  hàng (Windows/Linux/macOS/APK GitHub, Scoop, Homebrew, APT/RPM, winget) ⇒ mở `https://tsudev.com/pro?app=<client_id>`
  và `https://tsudev.com/ung-ho?app=<client_id>`. Bản Play `MUST NOT` dẫn ra thanh toán web. Trang Ủng hộ hiện có
  (`forkSupportPageUrl`) chuyển sang tsudev.com/ung-ho khi B3 của tsudev xong (đổi `fork_config.dart` ⇒ 👤 duyệt).
- iOS/App Store (2027): theo `docs/store/app-store.md` khi có tài khoản Apple Developer.

## 4. Thiết kế kỹ thuật (để đợt mã sau làm đúng)

- **Đăng nhập tùy chọn**: OIDC PKCE tới `https://tsudev.com/oidc` (app công khai, loopback trên desktop, app link trên
  Android), scope `openid tsudev.entitlements`; app có access token ⇒ `GET /api/me/entitlements` (thân `{"jws": ...}`).
  Không đăng nhập ⇒ app chạy y nguyên như hiện tại. Cần 👤/phiên tsudev đăng ký `client_id` cho Lotus Share.
- **Mã cài đặt**: 128 bit ngẫu nhiên (`Random.secure`), sinh lần đầu, lưu cục bộ, gửi `X-Tsu-Installation`
  (AUTH_AND_ACCOUNT 14.3). Không dùng vân tay TLS làm mã cài đặt (vân tay đã công khai trong LAN).
- **Lớp `Entitlements`**, **`ProNotice`** (5 test bắt buộc), **`TsuBadge`**: dùng gói `tsudev_ui`
  (`tsudev-org/tsudev-ui-flutter`, phase PRO-C2) - KHÔNG viết riêng ở repo này.
- **Đồng bộ**: thư viện Dart `tsusync` (git, ghim commit), tài liệu đồng bộ một bản ghi `favorites+settings` (JSON
  chuẩn hóa), mã hóa `crypto_secretstream_xchacha20poly1305`, khóa từ mật khẩu đồng bộ (Argon2id ≥ 64 MiB/3 lượt). Đồng
  bộ khi mở app / khi sửa yêu thích-cài đặt / khi quay lại app, nền không quá mỗi 10 phút; 429/5xx ⇒ chỉ hiện "Chưa đồng
  bộ". Gộp xung đột: yêu thích hợp theo vân tay (bí danh mới nhất thắng theo `updatedAt`), cài đặt theo khóa (mới nhất
  thắng). Chạy trong isolate sẵn có, không chặn giao diện (N1).
- **Tin cậy thiết bị**: yêu thích kéo về từ máy khác chỉ là gợi ý ghép theo vân tay; kết nối vẫn kiểm vân tay TLS như
  hiện tại. Kẻ chiếm tài khoản tsudev không đọc được (E2EE) và không thể làm máy nhận tệp từ máy lạ (vân tay vẫn kiểm,
  "lưu nhanh từ yêu thích" chỉ tin yêu thích đã giải mã bằng mật khẩu đồng bộ).
- **CLI**: không đăng nhập, không Pro (CLI dùng trên máy chủ/không màn hình).

## 5. Phụ thuộc và thứ tự

| Bước | Phụ thuộc | Trạng thái 20/11/2026 |
| --- | --- | --- |
| Kiểm kê + ADR + sync quy ước v3.9.1 | - | Xong (PR này) |
| Xuất/nhập tệp cài đặt + yêu thích (miễn phí) | - | Xong 20/11/2026: Cài đặt > Khác > Sao lưu ra tệp (`app/lib/util/settings_backup.dart`). Không mang "lưu nhanh" (tự nhận tệp): tệp lạ có thể thêm vân tay rồi bật tự nhận từ yêu thích |
| Đăng nhập OIDC + `Entitlements` + `ProNotice` + `TsuBadge` + màn Pro/Ủng hộ | tsudev#336 gộp (👤 chạy migration Neon), `client_id` Lotus Share, gói `tsudev_ui` (PRO-C2) | Chờ |
| Đồng bộ Pro | `tsudev-org/tsusync` (PRO-D1..D2: Worker + thư viện Dart qua vector) | Chờ |
| Mua trên Play | tsudev B2 (Play Developer API) + 👤 tạo `tsudev_pro`/`ung_ho_*` trong Play Console | Chờ |

## 6. Hệ quả

- Không đổi giao thức mạng (cổng, multicast, `/api/lotus/v2/`) ⇒ không ảnh hưởng `docs/GIAO-THUC-LOTUS-V2.md`.
- THREAT_MODEL bổ sung khi viết mã đồng bộ: giả mạo JWS (kiểm `iss`/`aud`/`exp`/`alg=ES256`), dùng lại biên nhận (chỉ
  máy chủ tsudev xác minh), liệt kê thiết bị (`devices_30d` chỉ là số đếm), chiếm tài khoản (E2EE + kiểm vân tay TLS).
- Đo phản hồi thao tác chính (< 100 ms) trước/sau khi thêm đăng nhập + đồng bộ, ghi vào PR mã.
