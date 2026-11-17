# PHIẾU YÊU CẦU - Hồ sơ trên các nền tảng xác minh (Best Practices, Scorecard, phát hành, kênh gói) cho `lotus-share`

- **Mã phiếu**: 20261115-01 (phiếu con)
- **Từ**: phiên agent-files (repo `tsufiles`), chủ dự án yêu cầu 15/11/2026 - **Đến**: phiên kế tiếp của repo `lotus-share`
- **Trạng thái**: MỞ - đã gỡ hai chặn bắt buộc (PR #51 #54 #55), hồ sơ soạn xong (#57); còn nộp bằng bp.cjs
- **Phiếu mẹ (ĐỌC TRƯỚC, mục 0 nguyên tắc + mục 3 quy trình)**: `~/projects/logs/handover/20261115-01_yeu-cau-ho-so-xac-minh-toan-he.md`
- **Công cụ + mẫu đã đạt passing 100%**: `~/projects/logs/tools/bestpractices/` (`README.md`, `bp.cjs`, `mau-tsufiles.json`);
  mẫu hồ sơ dạng đọc: `~/projects/tsufiles/docs/best-practices.md`.

## 1. Hiện trạng đo 15/11/2026

Chủ lực, ứng viên DUY NHẤT nộp SignPath (kế hoạch 20261113-02 mục 5). Apache-2.0, 4 Release, SHA256SUMS 2 tệp + 1 chữ ký, sức khoẻ 100%. Chưa có Scorecard, chưa có Best Practices.

## 2. Việc của repo này (theo thứ tự)

- [ ] 2.1. Best Practices passing 100% là điều kiện của ngưỡng SignPath (mục 5.5) - ưu tiên số 1 của phiếu này.
- [ ] 2.2. Thêm `scorecard.yml`, mục tiêu >= 7 (ngưỡng 5.5).
- [ ] 2.3. Bản phát hành: SHA256SUMS liệt kê MỌI tệp (cả Android APK nếu có), ký, `attest-build-provenance`, ghi chú "English summary".
- [ ] 2.4. Soạn sẵn bằng chứng cho đơn SignPath: bảng 6 ngưỡng với số đo thật + liên kết (KHÔNG nộp - 👤).
- [ ] 2.5. Hồ sơ Best Practices (nếu áp dụng): soạn `docs/best-practices.json` + `.md` (mỗi `Met` có URL bằng chứng trên
  `main`), gộp PR, rồi `bp.cjs new` -> `fill` chạy thử -> xem ảnh -> `fill --submit` -> `inspect` ra passing 100% -> huy hiệu README.
- [ ] 2.6. Ghi kết quả có số đo dưới đây + đánh dấu dòng `lotus-share` ở mục 4 phiếu mẹ + một dòng mục 7 kế hoạch `20261113-02`.

**Nhắc lại**: không ghi `Met` cho điều repo chưa làm. Chưa đạt thì sửa repo trước, hoặc ghi `Unmet`/`N/A` trung thực.
Tự chứng nhận sai bị phát hiện sẽ làm hỏng hồ sơ SignPath của cả hệ.

## Kết quả xử lý (phiên nhận điền)

- 17/11/2026 - phiên tsudev-27 (CHƯA nộp hồ sơ - chưa thể khai passing trung thực). Chặn ở hai tiêu chí BẮT BUỘC:
  1. `vulnerabilities_fixed_60_days`: 9 cảnh báo Dependabot mở (6 high, 1 medium) - TẤT CẢ ở
     `support/build/appimage/requirements-arm64.txt` (urllib3 1.26.20 → cần ≥ 2.8.0; lief 0.14.1 → ≥ 0.17.2). Hai gói
     đang CỐ Ý ghim (`requirements-arm64.in`: `urllib3<2`, `lief==0.14.1` cho appimage-builder 1.1.0). Việc: thử
     nâng + chạy `release-lotus.yml` (workflow_dispatch) trên runner ARM64 để chứng minh AppImage arm64 vẫn dựng được;
     không được thì ghi lý do và đóng cảnh báo dạng "tolerable risk" (chỉ là công cụ dựng, tải từ nguồn cố định qua
     HTTPS) RỒI mới khai hồ sơ.
  2. `static_analysis_fixed`: CodeQL mở `rust/disabled-certificate-check` x2, `rust/hard-coded-cryptographic-value`,
     `rust/cleartext-logging`, `rust/log-injection`, cộng `actions/missing-workflow-permissions` x4,
     `actions/unpinned-tag` x3. LocalSend dùng chứng chỉ tự ký + đối chiếu vân tay - phải đọc từng chỗ: báo nhầm thì
     dismiss kèm lý do, lỗi thật thì sửa.
  Đã có sẵn: Apache-2.0, CONTRIBUTING.md, SECURITY.md, mẫu issue, Dependabot, báo lỗ hổng riêng tư bật. Mẫu câu trả lời:
  `tsucontact/docs/best-practices.json` (hồ sơ 16836 passing). Công cụ: `~/projects/logs/tools/bestpractices/`.

- 18/11/2026 - phiên lotus-share-5e: gỡ hai chặn ở trên.
  1. Dependabot: PR #55 nâng urllib3 2.8.0 + lief 0.17.6 trong `requirements-arm64.txt`; build thử THẬT run 44165028549
     (job Linux ARM64 xanh, appimage-builder ghi thông tin cập nhật zsync qua lief mới).
  2. CodeQL: #51 (Actions: ghim SHA + permissions, 7 cảnh báo), #54 (`try_new_without_cert` chỉ còn sau `test-util`);
     #68-72 đã được phiên projects-e4 dismiss kèm lý do (báo nhầm / test).
  3. Hồ sơ `docs/best-practices.json` (67 tiêu chí, `Unmet` trung thực cho `dynamic_analysis_unsafe`) + CHANGELOG ghi
     RUSTSEC đã vá (`release_notes_vulns`) + chính sách kiểm thử tiếng Anh (`test_policy`) - PR #57.
  Còn: đo lại 0 cảnh báo trên `main` -> `bp.cjs new/fill --submit` (phía Windows) -> huy hiệu; bảng 6 ngưỡng SignPath.
