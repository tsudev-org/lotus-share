# PHIẾU BÀN GIAO - Ký mã Windows trả phí cho cả hệ tsudev (sau khi SignPath Foundation từ chối)

- **Mã phiếu**: 20261113-02
- **Từ**: phiên lotus-share-9e (13/11/2026) - **Đến**: phiên kế tiếp của repo `tsudev-org/lotus-share`
- **Trạng thái**: MỞ - chờ chủ dự án xác nhận nhà cung cấp
- **Đọc kèm**: `logs/STATE.md` (hàng đợi), `logs/handover/20261113-01_ket-phien-lotus-share-doc-lap-lotus7.md` (trạng
  thái phát hành 2.0.0-lotus.7), `CODE_SIGNING.md`, `docs/vi/KE-HOACH-KY-MA-12-2026.md`, `docs/vi/HUONG-DAN-KY-MA.md`.

## 0. Trạng thái khi bàn giao

- `main` sạch, mọi PR của phiên đã gộp (#38, #39, #42, #43, #44). Không có khóa trong `logs/LOCKS.md`, không có tiến
  trình nền nào của phiên này còn chạy.
- Bản mới nhất: `v2.0.0-lotus.7` (2.0.0+65) đã Publish; website deploy; Scoop/Homebrew/APT đã lên bản này.
- SignPath Foundation TỪ CHỐI đơn (email 12/11/2026 21:49): chưa đủ tín hiệu được biết đến công khai; mời nộp lại hoặc
  dùng gói trả phí. `CODE_SIGNING.md` (trang `/chinh-sach-ky-ma/`) đã ghi trạng thái thật + quyền riêng tư nêu ngoại lệ
  tải `phien-ban.json` (PR #44).
- Chủ dự án chọn **hướng 2 (trả phí)** và hỏi giá nếu áp dụng cho cả hệ. Agent đã trả lời (mục 1), đang chờ chủ dự án
  xác nhận chọn Certum. CHƯA mua gì, CHƯA sửa workflow.

## 1. Kết quả tìm hiểu (13/11/2026 - đối chiếu lại trang chính thức trước khi làm, trang Certum lúc đó lỗi 503)

| Lựa chọn | Giá | Cả hệ | Kết luận |
| --- | --- | --- | --- |
| Certum Open Source Code Signing, SimplySign (cloud) | từ €49/năm (bộ thẻ+đầu đọc €69; mã kích hoạt €25) | Có - cấp cho 1 cá nhân, ký mọi dự án mã nguồn mở của người đó | **Đề xuất** |
| SignPath trả phí (Starter) | $500/năm/dự án (Basic $1.000) | Tính theo dự án | Quá đắt |
| Azure Artifact Signing | $9.99/tháng | Có | Không dùng được: cá nhân chỉ Mỹ/Canada |
| Chứng thư IV/OV thương mại | vài trăm USD/năm (chưa kiểm) | Có, kể cả phần mềm bán | Chỉ khi có phần mềm thương mại |

Tổng chi phí/năm cả hệ (đã báo chủ dự án): Certum ~€49 (~1,5 triệu đồng) + Apple Developer $99 (~2,6 triệu, đã có kế
hoạch tháng 12) + Android/Linux 0 đồng ≈ **4 triệu đồng/năm** (tỷ giá ước lượng).

Điều kiện Certum Open Source (nguồn: my-ssl.com/learn/open-source-code-signing-certificate, kiểm 22/10/2026):
- Chỉ cá nhân; tên trên chứng thư: "Open Source Developer, <họ tên>" (KHÔNG hiện "tsudev"); không chứa tên miền.
- Hồ sơ: giấy tờ tùy thân, hóa đơn tiện ích đứng tên, URL dự án công khai thể hiện vai trò; cấp 1-5 ngày.
- Chỉ ký phần mềm mã nguồn mở, phi thương mại (ký phần mềm bán -> bị thu hồi). Hiệu lực tối đa ~459-460 ngày/chứng thư.
- Cloud: tối đa 5.000 chữ ký/tháng. SmartScreen: hết "Unknown Publisher" ngay, nhưng uy tín tăng dần theo lượt tải.
- CHƯA XÁC NHẬN: Certum có cấp cho người ở Việt Nam không.

Giấy phép các phần mềm cài đặt của hệ (đo 13/11/2026 qua `gh api .../contents/LICENSE`):
- Apache-2.0: lotus-share, tsudev-swico, tsudev-contact. MIT: tsudev-cwico, tsudev-files -> đạt.
- **tsudev-trafficmonitor: "Anti 996 License"** (không thuộc danh sách OSI) -> phải hỏi Certum trước, hoặc không ký.
- Ngoài ra có `app-la-ban` (tsudev-tsudev) và gói `tsudev-luyen-go-phim` (TsuGameLabs, linux-packages) - kiểm giấy phép
  nếu cần ký Windows.

## 2. Bước tiếp theo CỤ THỂ (theo thứ tự)

1. **Hỏi chủ dự án ở đầu phiên**: đã xác nhận chọn Certum chưa? Đã mua/nộp hồ sơ chưa? Agent không mua, không thanh toán,
   không nộp hồ sơ thay (danh tính + tiền của chủ dự án).
2. Chủ dự án xác nhận -> agent soạn `docs/vi/HUONG-DAN-KY-MA.md` phần mới "A' - Certum Open Source": câu hỏi gửi Certum
   trước khi mua (cấp cho Việt Nam? Anti 996 có được không?), các bước mua bản cloud, hồ sơ, cài SimplySign (ứng dụng
   OTP trên điện thoại). KHÔNG chép số giấy tờ/khóa/mã OTP vào repo.
3. Thiết kế ký trong CI (`release-lotus.yml`), chọn 1 trong 2 rồi hỏi chủ dự án:
   - (a) tự động trên runner Windows: SimplySign Desktop + bí mật OTP (seed TOTP) trong GitHub Environment có người
     duyệt -> tiện nhưng seed nằm trên GitHub (rủi ro, ghi vào `docs/vi/KIEN-TRUC-BAO-MAT.md`);
   - (b) ký tay trên máy chủ dự án: CI build bản chưa ký -> chủ dự án chạy script ký (signtool + SimplySign) -> tải lên
     bản nháp -> CI/agent tính lại SHA256SUMS + chứng thực. An toàn hơn, chậm hơn.
   Ký cả `lotus_share.exe` + DLL trong ZIP, rồi bộ cài `-setup.exe`; ghim Subject/Thumbprint chứng thư trong workflow
   (như ghim chứng thư APK); build thử `gh workflow run release-lotus.yml --ref <nhánh>` trước khi gắn nhãn.
4. Cập nhật `CODE_SIGNING.md` (bỏ câu ghi công SignPath nếu không dùng SignPath; nêu Certum + tên trên chứng thư), trang
   Tải về (cách xem chữ ký), `docs/vi/KE-HOACH-KY-MA-12-2026.md` phần 1 -> Certum, `docs/vi/PHAT-HANH.md`.
5. Áp dụng cả hệ: viết phiếu `~/projects/logs/handover/<ngày>-NN_yeu-cau-ky-ma-windows-chung-certum.md` (cùng kiểu phiếu
   20261112-04), nhắn các phiên đang chạy (ListAgents -> SendMessage): tsudev-standards (quy ước chung), tsudev-files,
   tsudev-cwico, tsudev-swico, tsudev-contact, tsudev-trafficmonitor. KHÔNG sửa hộ repo khác.
6. Phát hành bản đã ký đầu tiên: build 66 (`docs/vi/CAP-NHAT-BAT-BUOC.md` mục 3 - cập nhật `phien-ban.json` `moiNhat`
   sau Publish, deploy website).

## 3. Cảnh báo

- Chứng thư cá nhân: chỉ ký phần mềm mã nguồn mở, không bán. Có phần mềm thương mại -> cần chứng thư khác.
- Không bao giờ commit chứng thư, khóa, seed OTP, ảnh giấy tờ (`/secrets` đã ignore; xem SECURITY_BASELINE).
- macOS runner arm64 hay bị hủy vì thiếu máy chạy: kiểm đủ 22 tệp trước khi Publish (phiếu 20261113-01 mục 3).
- Deploy website: `XDG_CONFIG_HOME=$HOME/.config/wrangler-tsudev`, kiểm `wrangler whoami` là tài khoản tsudev.
