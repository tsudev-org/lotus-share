# PHIẾU YÊU CẦU - T1 (lotus-share): đồng bộ bộ quy ước lên v3.8.1

- **Mã phiếu**: 20261119-T1 (phiếu tổng `~/projects/logs/handover/20261119-01_ke-hoach-toan-he-v3.8.0.md` mục 4, phase T1)
- **Từ**: phiên điều phối projects-45, 19/11/2026
- **Đến**: phiên lotus-share đang mở
- **Trạng thái**: XONG 19/11/2026 (phiên lotus-share-9c)

## Việc

1. Nhánh riêng từ `origin/main`: `bash scripts/sync-standards.sh --ref v3.8.1` (tự xác minh MANIFEST.sha256), rồi
   `bash scripts/check-standards.sh` phải đạt.
2. Một PR `chore(standards): đồng bộ bộ quy ước lên v3.8.1` (chỉ `.standards/`, `.standards-version`,
   `scripts/check-standards.sh` nếu đổi); gộp khi CI xanh. Có thể gộp chung PR đang làm nếu tiện.
3. Đọc mới: `.standards/docs/PRODUCT_POLICY.md` (không quảng cáo, Pro/Ủng hộ, ngôn ngữ + giao diện theo hệ thống) và
   `STORE_SUBMISSION.md` - là đầu vào cho các phase T2-T8, M1-M4 sau này; chưa cần làm ngay.

## Nghiệm thu

`.standards-version` trên main = 3.8.1. Trả lời: ghi số PR vào mục Kết quả dưới đây và nhắn phiên điều phối.

## Kết quả

- 19/11/2026 - phiên lotus-share-9c: `sync-standards.sh --ref v3.8.1` (MANIFEST.sha256 xác minh) + `check-standards.sh`
  ĐẠT 0 lưu ý (gồm 5b thẻ `v26.11.1801` đúng khuôn). AGENTS.md bảng tra cứu thêm PRODUCT_POLICY + STORE_SUBMISSION.
  PR #77 (đã gộp, CI xanh 13/13 - lần đầu job `format` đỏ do tải Flutter SDK đứt mạng, chạy lại xanh).
