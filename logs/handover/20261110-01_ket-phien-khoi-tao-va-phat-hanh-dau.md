# PHIẾU BÀN GIAO - Kết phiên khởi tạo tsudev-lotus và bản phát hành đầu

- **Mã phiếu**: 20261110-01
- **Từ**: phiên projects-55 (Claude, 10/11/2026) - **Đến**: phiên kế tiếp của repo `tsudev-lotus`
- **Thời điểm**: 20:30 10/11/2026
- **Trạng thái**: MỞ
- **Nhánh git**: `fix/trang-tai-ve` (PR #11, chờ chủ dự án merge). `main` = `56b7eaba` + bản phát hành `v1.18.2-lotus.2`.

## 0. Đọc trước khi làm gì

1. `AGENTS.md` (phần A + B), `logs/STATE.md` (hàng đợi), phiếu này.
2. Kế hoạch tháng 12/2026: `docs/vi/KE-HOACH-KY-MA-12-2026.md`. Quy trình phát hành: `docs/vi/PHAT-HANH.md`.
3. Flutter: `export PATH=$HOME/.local/share/flutter-sdk/3.47.9/bin:$PATH` (không dùng fvm trên máy này).

## 1. Việc đã làm xong (phiên này)

- Rà quét an toàn upstream `localsend/localsend@8476c091`, khởi tạo fork, repo công khai `tsudev-org/tsudev-lotus`
  (secret scanning + push protection + báo lỗi riêng tư + Dependabot bật trước lần push đầu). PR #6, #10 đã merge.
- Tiếng Việt mặc định + hoàn thiện (66 chuỗi sửa, trang web nhận tệp, bộ cài Inno, CLI, lời xin quyền Apple, menu macOS).
- Định danh riêng `com.tsudev.lotus` / `tsudev_lotus.exe` / AppId Inno `{E6A866CD-B32E-4718-9EF0-CE04D53F9263}` / CLI
  `tsudev-lotus-cli`; icon tsudev sinh bằng `tools/gen_icons.py`.
- Gia cố: vá 7 crate Rust, PIN thời gian hằng + chống xoay IPv6; CI CodeQL/gitleaks/OSV/i18n/website.
- Quy ước tsudev **v3.3.0** (tsudev-standards PR #48, nhãn + Release v3.3.0): ngoại lệ em-dash theo dòng cho fork;
  repo này có `.standards-upstream`, cổng chặn thật.
- Ruleset: `main` (PR + 11 kiểm tra bắt buộc), nhãn `v*-lotus.*` bất biến + chỉ quản trị tạo. Repo bật tự merge.
- **Phát hành công khai `v1.18.2-lotus.2`** (15 tệp, đã kiểm SHA256SUMS + `gh attestation verify`); website
  `lotus.tsudev.com` hiện gói + SHA-256. Khóa APK ở `~/.config/tsudev-lotus/keys/` (secret đã lên GitHub).

## 2. Việc dang dở + bước tiếp theo CỤ THỂ

- [ ] **PR #11** (`fix/trang-tai-ve`): bỏ gói CLI Windows hiện trùng ở mục Windows trên trang Tải về + cập nhật
      STATE + kế hoạch tháng 12 + phiếu này. Bước tiếp: hỏi chủ dự án đã chạy chưa
      `gh pr merge 11 -R tsudev-org/tsudev-lotus --merge --auto --delete-branch`; nếu PR đã merge, nhắc chạy
      `cd ~/projects/tsudev-lotus && git switch main && git pull --ff-only && cd website && npm run deploy`, rồi kiểm:
      `curl -s https://lotus.tsudev.com/tai-ve/ | grep -o 'releases/download/[^"]*' | sort | uniq -d` phải RỖNG.
- [ ] **Tháng 11 (làm được ngay, không cần Apple)**: theo `docs/vi/KE-HOACH-KY-MA-12-2026.md` mục 1.1 -> 1.4:
      1. Đọc điều kiện chính thức của SignPath Foundation (signpath.org, docs.signpath.io) bằng agent `web-fetch`;
         sửa kế hoạch nếu khác. 2. Làm trang `website/src/pages/chinh-sach-ky-ma.astro` (PR riêng). 3. Soạn nội dung
         đơn vào một phiếu mới trong `logs/handover/` để chủ dự án nộp; ghi ngày nộp vào STATE.
- [ ] **Đầu tháng 12/2026**: khi chủ dự án báo đã có Apple Developer -> làm mục 2 của kế hoạch (macOS Developer ID +
      công chứng, iOS TestFlight) và mục 1.5 (tích hợp SignPath) nếu đơn đã được duyệt; phát hành `-lotus.3`.
- [ ] Phiếu `tsudev-standards/logs/handover/20261110-01_v3.3.0-mien-tru-upstream.md` mục "Kết quả xử lý" còn trống:
      điền qua PR ở repo `tsudev-standards` (v3.3.0 đã merge, gắn nhãn, có Release ngày 10/11/2026).
- [ ] Theo dõi phiếu gửi tsudev-files: `~/projects/tsudev-files/logs/handover/20261110-01_yeu-cau-ap-dung-mien-tru-upstream-v3.3.0.md`
      (KHÔNG tự sửa repo đó nếu có phiên khác đang làm - `ListAgents`).

## 3. File liên quan / đang khóa

| Đường dẫn | Lý do | Còn khóa? |
| --- | --- | --- |
| (không) | Phiên này không khóa file nào; `logs/LOCKS.md` trống | Không |

## 4. Yêu cầu gửi agent đang giữ khóa (nếu có)

- Không có.

## 5. Cảnh báo và quyết định quan trọng

- **Quyền của agent bị chặn** (bộ phân loại auto mode, không phải do chủ dự án): merge PR, tạo Release/repo công khai,
  ghi GitHub secret, `wrangler deploy`. Luôn soạn sẵn lệnh `! ...` cho chủ dự án chạy; KHÔNG lách (không nhờ phiên
  khác làm hộ).
- Nhãn `v1.18.2-lotus.1` hỏng và bất biến - không dùng lại. Bản kế tiếp: `v1.18.2-lotus.3` (hoặc theo pubspec mới).
- Mọi thay đổi workflow phát hành: thử trước bằng `gh workflow run release-lotus.yml -R tsudev-org/tsudev-lotus
  --ref <nhánh>` (build thử, không gắn nhãn). Bài học: CMake `set(BINARY_NAME ...)` không được có chú thích cuối dòng;
  Flutter 3.47.9 đòi Gradle >= 8.14, Kotlin (KGP) >= 2.2.20, AGP >= 8.11.1; macOS cần Xcode 26.
- Sau `dart run slang` luôn chạy `python3 -I tools/fix_slang_format.py`. Đổi chuỗi trong tệp có em-dash kế thừa thì
  dòng đó mất miễn trừ - thay em-dash bằng `-` ở đúng dòng đã sửa.
- `.gitignore` chuẩn chặn tên tệp chứa `secret` (đã đổi script thành `tools/day-khoa-ky-android.sh`).
- Khóa APK mất = người dùng không cập nhật được: nhắc chủ dự án sao lưu `~/.config/tsudev-lotus/keys/` nếu chưa.

## 6. Trạng thái cổng kiểm

- [x] `./scripts/check-standards.sh` đạt (quy ước v3.3.0, `STANDARDS_VERIFY_UPSTREAM=1`)
- [x] Lint và test đạt (flutter analyze 0 lỗi, flutter test 92/92, cargo test core + CLI 41/41; CI 11/11 ở PR #10)
- [x] `git status` sạch ngoài phạm vi bàn giao (thay đổi của phiếu này nằm trong PR #11)

## 7. Kết quả xử lý (agent nhận điền sau khi thực hiện)

-
