# 20261120-GP1 - lotus-share: đưa Lotus Share lên Google Play Console (phần B của phiếu toàn hệ)

- **Người lập**: phiên điều phối `tsudev-62`, 20/11/2026.
- **Người làm**: phiên lotus-share. **Trạng thái**: MỞ.
- **Phiếu mẹ**: `~/projects/logs/handover/20261120-GP1_google-play-console-toan-he.md` - làm theo **mục 4 (checklist
  mỗi app)**; mục 2 (phần A dùng chung) ĐÃ XONG ở phiên tsudev, đừng làm lại.
- **Công cụ trình duyệt**: `~/projects/logs/tools/browser/README.md` (`tsb`, hồ sơ `play` = Edge `tsudev-play`, đã đăng
  nhập Play Console). Dùng tsb, KHÔNG viết script Playwright thô không rào chắn.

## 1. Hiện trạng (đo 20/11/2026)

| Package | Trên Play Console | Pro/ủng hộ qua Play |
|---|---|---|
| `com.tsudev.lotusshare` | ❌ chưa tạo | không |

## 2. Việc riêng của repo này

1. Nguồn: `~/projects/lotus-share` và `~/projects/tsudev-lotus` là HAI bản sao cùng remote `tsudev-org/lotus-share` (cùng HEAD `f47ef34f`, đo 20/11) - làm ở MỘT bản, đừng sửa song song.
2. Quyền: mạng LAN, **thiết bị lân cận** (`NEARBY_WIFI_DEVICES`), tệp - khai lý do; kiểm manifest trước.
3. Tạo app mới (GP1 mục 4 bước 1) rồi đủ "Thiết lập ứng dụng". Đã có `docs/store/app-store.md` (Apple) - viết thêm `docs/store/google-play.md` nếu chưa có.

## 3. Ranh giới

- Nút gửi duyệt / xuất bản / thanh toán / xoá app: **👤 bấm** (tsb chặn sẵn) - agent điền rồi dừng, chụp màn hình.
- Danh sách ≥ 12 người thử kín, hồ sơ thanh toán, mật khẩu tài khoản thử cho người duyệt: 👤.
- Không tạo khoá tài khoản dịch vụ mới; `tsudev-play-verify` đã có quyền mức tài khoản (phủ app mới).
- Bằng chứng: ảnh "Tổng quan về việc xuất bản" vào `logs/trust/`, ghi `logs/trust/TRUST.md`.

## 4. Xong khi

GP1 mục 4 bước 1-7 đạt cho app này; ghi một dòng vào mục 5 phiếu này VÀ mục 6 phiếu mẹ.

## 5. Kết quả xử lý (mỗi phiên ghi một dòng)


## Bổ sung 20/11/2026 (tsudev điều phối) - điền biểu mẫu đứng tên chủ dự án

Theo tsudev-standards v4.2.0 `STORE_SUBMISSION.md` mục 0.1 (PR tsudev-standards #65): mọi trường Play Console điền như
chủ dự án tự điền, KHÔNG chọn/ghi "do AI thực hiện". Câu hỏi về tính năng thật của app (có tính năng AI tạo sinh
không...) trả lời đúng mã, ghi tệp mã làm nguồn trong `docs/store/google-play.md`.
