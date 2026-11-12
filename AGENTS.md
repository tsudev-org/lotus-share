# AGENTS.md - Lotus Share

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
- **Stack**: Flutter/Dart (giao diện) trên lõi Rust (giao thức, HTTPS, mã hóa); Apache-2.0, sản phẩm độc lập từ 2.0
  (giao thức, cấu hình, định danh riêng). Kiến trúc: [`docs/KIEN-TRUC-KY-THUAT.md`](docs/KIEN-TRUC-KY-THUAT.md); bảo mật:
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

Sau `dart run slang`, chạy `python3 -I tools/fix_slang_format.py` (dấu `;` cuối enum về dòng riêng), tránh diff nhiễu.

### B.3. Ranh giới sở hữu file

| Vùng | Chủ sở hữu |
| --- | --- |
| `app/lib/config/fork_config.dart` (tên, URL, ngôn ngữ mặc định, máy chủ) | Chủ dự án - mọi thay đổi cần duyệt |
| `app/assets/i18n/vi.json`, nhóm khóa `tsudev` trong `en.json` | Agent/người dịch; giữ đồng bộ khóa với `en.json` |
| `website/` | Agent website |
| Giao thức mạng (cổng, nhóm multicast, `/api/lotus/`, định dạng gói tin) | Chủ dự án - đổi là thay đổi phá vỡ, phải nâng `toiThieu` ở `website/public/phien-ban.json` |
| `website/public/phien-ban.json` (bắt buộc cập nhật) | Chủ dự án duyệt khi nâng `toiThieu` |
| `packages/vendor/` | Phụ thuộc chép nguyên văn; sửa thì ghi chú `lotus-share:` |
| Phần còn lại | Agent |

### B.4. Điểm lệch chuẩn đã biết

| Lệch ở đâu | Vì sao | Kế hoạch |
| --- | --- | --- |
| Tên nội bộ `localsend_app`, `localsend_isolates`, crate `localsend`, package Kotlin `org.localsend.localsend_app`, tên kênh nền tảng | Người dùng không thấy; đổi cần build thử mọi nền tảng (cầu nối Rust-Flutter sinh mã) | Đổi trong task riêng (logs/STATE.md); định danh cài đặt đã riêng: `docs/vi/PHAT-HANH.md` mục 1 |
| Tên gói `lotus-share` (Scoop, Homebrew, APT, RPM; winget `tsudev.LotusShare`) thay khuôn `tsudev-<ten>` (PACKAGING.md mục 2) | Đổi tên sản phẩm 12/11/2026 (chủ dự án). Tên cũ `tsudev-lotus` vẫn nhận bản mới: APT gói chuyển tiếp, RPM Provides+Obsoletes, cask/manifest tên cũ deprecate (CI kiểm nâng cấp thật) | Đề xuất ở `tsudev-standards` phiếu `logs/handover/20261112-02_de-xuat-ten-goi-thuong-hieu-rieng.md`; ngoại lệ ghi đích danh `tenRieng` ở `linux-packages/products.json` |
| Logo riêng Lotus Share làm icon/favicon thay dấu hiệu chung tsudev (BRAND_ASSETS mục 12.3) | Quyết định chủ dự án 11/11/2026: mỗi sản phẩm có điểm nhấn riêng | Đề xuất ở `tsudev-standards` phiếu `logs/handover/20261112-01_de-xuat-logo-rieng-tung-san-pham.md` (đã bổ sung Lotus Share); chân trang website vẫn ghi `© tsudev` |

### B.5. Việc riêng của repo cần biết trước khi sửa

- **Không còn gộp mã LocalSend** (từ 12/11/2026, quyết định chủ dự án): không có remote `upstream`, không tham chiếu
  giao thức/cấu hình/thương hiệu LocalSend. Lỗ hổng trong mã bắt nguồn từ đó: tự vá.
- **Giao thức riêng** từ 2.0: cổng 53420, nhóm multicast `224.0.0.168` / `ff12::1075:5ea0`, API `/api/lotus/v2/`
  (`docs/vi/KHAM-PHA-THIET-BI.md`). Bản 1.x không nói chuyện được với 2.x.
- **Bắt buộc cập nhật**: ứng dụng đọc `https://lotus.tsudev.com/phien-ban.json` (nguồn `website/public/phien-ban.json`),
  so số build; xem `docs/vi/CAP-NHAT-BAT-BUOC.md`.
- Mã sinh tự động `app/lib/gen/` ĐƯỢC commit. Sửa JSON dịch xong phải `dart run slang`; CI
  `fork-ci.yml` chặn nếu mã sinh lệch nguồn.
- Không bao giờ chép khóa riêng, keystore Android, chứng thư ký mã vào repo (`/secrets` đã ignore).
- LICENSE giữ nguyên văn (kể cả dòng bản quyền gốc - Apache-2.0 mục 4c bắt buộc giữ thông báo bản quyền trong mã
  nguồn); NOTICE + LICENSE hiện trong ứng dụng ở Giới thiệu > Giấy phép và bản quyền (`app/assets/legal/`, test
  `legal_assets_test.dart` chặn lệch). Không thêm ghi công ở chỗ khác.
- Hướng dẫn kỹ thuật (isolate, lõi Rust, FOSS build): `docs/KIEN-TRUC-KY-THUAT.md`.
- Định danh cài đặt (`com.tsudev.lotusshare`, `lotus_share`, AppId Inno) và quy trình phát hành, khóa ký: `docs/vi/PHAT-HANH.md`.
  Khóa ký APK nằm ngoài repo (`~/.config/lotus-share/keys/`); KHÔNG BAO GIỜ commit.
- Logo/icon: thay `support/brand/lotus-share/logo-source.png` -> `tools/prepare_brand.py` (tách nền, bản 1024, WebP/AVIF,
  màu nhấn) -> `tools/gen_icons.py` (icon mọi nền tảng) -> `website/scripts/brand_assets.py` (favicon, OG). Không sửa tay tệp icon.
- CLI giao diện tiếng Việt viết thẳng trong chuỗi Rust (`cli/src/`); tên lệnh `lotus-share-cli`.
