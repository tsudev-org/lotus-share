# PHIẾU YÊU CẦU - Tăng uy tín công khai (lotus-share)

- **Mã phiếu**: 20261113-03
- **Từ**: phiên `tsudev-06` (repo `tsudev`), chủ dự án yêu cầu 13/11/2026 - **Đến**: phiên kế tiếp của repo `lotus-share`
- **Trạng thái**: MỞ - P1.1/P1.3/P1.5 xong 18/11 (PR #53, issue #58-60); còn Best Practices (phiếu 20261115-01)

Kế hoạch đầy đủ (nguyên tắc, giai đoạn, ngưỡng, công cụ đo): `~/projects/logs/handover/20261113-02_ke-hoach-uy-tin-he-sinh-thai.md`.
ĐỌC mục 0 (nguyên tắc - chỉ tín hiệu thật, miễn phí trước) trước khi làm.

## Phần của repo này (mục 4 của kế hoạch)

Chủ lực ưu tiên 1: P1.1 README tiếng Anh làm README chính (README.vi.md giữ tiếng Việt), P1.3 chép workflow Scorecard, P1.5 >= 3 issue `good first issue`; Discussions đã bật - trả lời câu hỏi đầu tiên trong 48 giờ; bổ sung winget (phiếu toàn hệ 20261113-01).

Đo trước/sau: `cd ~/projects/tsudev && npm run he-sinh-thai:tin-hieu`. Xong mục nào thì đánh dấu ở mục 4 + ghi một dòng
vào mục 7 của kế hoạch, và ghi kết quả dưới đây.

## Kết quả xử lý (phiên nhận điền)

- 18/11/2026 - phiên lotus-share-5e: P1.1 README tiếng Anh là `README.md` (bản Việt `README.vi.md`, liên kết qua lại),
  P1.3 `.github/workflows/scorecard.yml` (mẫu tsucontact, huy hiệu README) - PR #53; P1.5 ba issue `good first issue`
  #58 (CLI kiểm phiên bản), #59 (tài liệu khám phá thiết bị tiếng Anh), #60 (clippy chặn CI). winget: PR
  microsoft/winget-pkgs#478033 nâng lên 2.0.0, chờ người kiểm duyệt.
