# AGENTS.md - tsudev-lotus

> **ĐỌC FILE NÀY ĐẦU TIÊN trong mọi phiên làm việc mới.**

## Phần A - Quy ước chung của hệ sinh thái (KHÔNG SỬA Ở ĐÂY)

Toàn bộ quy ước chung nằm trong bản sao chỉ-đọc tại
[`.standards/AGENTS.md`](.standards/AGENTS.md). `MUST` đọc file đó trước.

Bản quy ước repo này đang dùng: xem [`.standards-version`](.standards-version).

| Cần gì | Đọc file nào |
| --- | --- |
| Điểm vào, nguyên tắc chung | `.standards/AGENTS.md` |
| Quy trình phiên, khóa file, bàn giao | `.standards/docs/AGENT_PROTOCOL.md` |
| Bảo mật bắt buộc | `.standards/docs/SECURITY_BASELINE.md` |
| Quy tắc `.gitignore` | `.standards/docs/GITIGNORE_POLICY.md` |
| Nhánh, commit, PR, phát hành | `.standards/docs/GIT_WORKFLOW.md` |
| Đăng nhập, đăng ký, xác minh tài khoản | `.standards/docs/AUTH_AND_ACCOUNT.md` |
| Giao diện và token | `.standards/docs/DESIGN_SYSTEM.md` |
| Bảng bản ghi, bộ chọn số bản ghi | `.standards/docs/DATA_TABLE.md` |
| Logo, favicon, icon ứng dụng | `.standards/docs/BRAND_ASSETS.md` |
| tsudev.com, ảnh đại diện, trang hồ sơ | `.standards/docs/ECOSYSTEM_IDENTITY.md` |
| Cấu trúc thư mục | `.standards/docs/PROJECT_STRUCTURE.md` |
| Chọn ngôn ngữ, framework | `.standards/docs/LANGUAGE_SELECTION.md` |
| Hạ tầng 0 đồng | `.standards/docs/FREE_TIER_STACK.md` |
| Trình soạn thảo nội dung | `.standards/docs/RICH_TEXT_EDITOR.md` |
| Tìm kiếm và lọc tiếng Việt | `.standards/docs/SEARCH_AND_FILTER.md` |
| Kiểm thử và chất lượng mã | `.standards/docs/TESTING_QUALITY.md` |
| Khả năng truy cập | `.standards/docs/ACCESSIBILITY.md` |

`MUST NOT` sửa bất kỳ file nào trong `.standards/`. Cần đổi quy ước thì mở đề
xuất tại repo `tsudev-standards` theo `.standards/docs/SYNC.md` mục 1.

## Phần B - Riêng của repo này

### B.1. Repo này là gì

- **Loại**: ứng dụng đa nền tảng (Windows, macOS, Linux, Android, iOS) + công cụ dòng lệnh + website sản phẩm
- **Stack**: Flutter/Dart (giao diện) trên lõi Rust (giao thức, HTTPS, mã hóa); fork của `localsend/localsend`
  (Apache-2.0). Kiến trúc gốc: [`docs/AGENTS.upstream.md`](docs/AGENTS.upstream.md); bảo mật:
  [`docs/vi/KIEN-TRUC-BAO-MAT.md`](docs/vi/KIEN-TRUC-BAO-MAT.md)
- **Mức phân loại dữ liệu cao nhất**: D3 (tệp người dùng truyền giữa các thiết bị; khóa TLS riêng của thiết bị)
- **Người liên hệ khi có sự cố**: tsudev-tsudev
- **Trang sản phẩm**: `https://lotus.tsudev.com` (mã nguồn ở `website/`)

### B.2. Chạy trong 5 phút

Flutter ghim ở `.fvmrc` (3.47.9). Máy này cài sẵn tại `~/.local/share/flutter-sdk/3.47.9` (không dùng fvm):

```bash
export PATH=$HOME/.local/share/flutter-sdk/3.47.9/bin:$PATH
cd app && flutter pub get
dart run slang                         # sinh lại mã dịch sau khi sửa assets/i18n/*.json
flutter analyze && flutter test        # cổng kiểm Dart
cd .. && python3 -I tools/check_i18n_vi.py   # bản dịch tiếng Việt đủ khóa, đúng tham số
(cd packages/core && cargo test --features full)
```

Sau `dart run slang`, slang 4.x định dạng `app/lib/gen/strings.g.dart` khác bản upstream một dòng (dấu `;` cuối
enum). Chạy `python3 -I tools/fix_slang_format.py` để trả về đúng định dạng upstream, tránh diff nhiễu.

### B.3. Ranh giới sở hữu file

| Vùng | Chủ sở hữu |
| --- | --- |
| `app/lib/config/fork_config.dart` (tên, URL, ngôn ngữ mặc định, máy chủ) | Chủ dự án - mọi thay đổi cần duyệt |
| `app/assets/i18n/vi.json`, nhóm khóa `tsudev` trong `en.json` | Agent/người dịch; giữ đồng bộ khóa với `en.json` |
| `website/` | Agent website |
| `tools/`, `docs/vi/`, `.github/workflows/security.yml`, `.github/workflows/fork-ci.yml` | Riêng của fork |
| Phần còn lại của `app/`, `packages/`, `cli/`, `server/` | Mã upstream - sửa tối thiểu, ghi chú `tsudev-lotus:` tại chỗ sửa |

### B.4. Điểm lệch chuẩn đã biết

| Lệch ở đâu | Vì sao | Kế hoạch |
| --- | --- | --- |
| Em-dash và chuỗi tiếng Anh trong mã kế thừa upstream | Sửa sẽ gây xung đột mỗi lần gộp upstream | Mã MỚI của fork tuân thủ; theo dõi đề xuất miễn trừ em-dash ở `tsudev-standards` (phiếu của tsudev-files) |
| Định danh gói `org.localsend.localsend_app`, tên tệp phát hành `LocalSend-*` | Đổi định danh là việc lớn, chạm mọi nền tảng | Task "Đổi định danh nền tảng" trong `logs/STATE.md` |
| Workflow phát hành của upstream (`build_*.yml`, `release.yml`, `winget.yml`) | Cần secret ký mã của upstream, fork chưa có | Đã tắt trigger; viết lại khi có chứng thư ký mã |

### B.5. Việc riêng của repo cần biết trước khi sửa

- Remote `upstream` = `localsend/localsend` (chiều đẩy bị khóa `DISABLED`). Gộp: `git fetch upstream && git merge upstream/main`.
- Mỗi chỗ sửa trong mã upstream đánh dấu bằng chú thích bắt đầu `tsudev-lotus:` để dễ tìm khi gộp.
- **Giữ tương thích giao thức LocalSend v2** (cổng 53317, nhóm multicast 224.0.0.167): đó là lý do người dùng
  chọn sản phẩm - trao đổi tệp được với mọi thiết bị đang chạy LocalSend. Không đổi định dạng gói tin.
- Mã sinh tự động `app/lib/gen/` ĐƯỢC commit (upstream làm vậy). Sửa JSON dịch xong phải `dart run slang`; CI
  `fork-ci.yml` chặn nếu mã sinh lệch nguồn.
- Không bao giờ chép khóa riêng, keystore Android, chứng thư ký mã vào repo (`/secrets` đã ignore).
- LICENSE (Apache-2.0) giữ nguyên văn; mọi màn hình Giới thiệu phải ghi công LocalSend / Tien Do Nam.
- Ghi chú upstream: `docs/AGENTS.upstream.md` có toàn bộ hướng dẫn kỹ thuật (isolate, lõi Rust, FOSS build).
