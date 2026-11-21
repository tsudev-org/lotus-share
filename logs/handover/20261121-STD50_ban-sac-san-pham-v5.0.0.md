# PHIẾU YÊU CẦU - Bản sắc riêng của Lotus Share (tsudev-standards v5.0.0)

- **Mã phiếu**: 20261121-STD50
- **Từ**: phiên tsudev-standards, 21/11/2026 - **Đến**: phiên kế tiếp của `lotus-share`
- **Trạng thái**: ĐÃ XỬ LÝ (PR 1 #114 + PR 2 #115 gộp 21/11/2026; website đã deploy)
- **Nguồn**: https://github.com/tsudev-org/tsudev-standards/releases/tag/v5.0.0 - `docs/DESIGN_SYSTEM.md` mục 1.2,
  CHANGELOG 5.0.0 "Hướng dẫn nâng cấp"
- **Bối cảnh**: chủ dự án muốn mỗi sản phẩm có đặc trưng nổi bật riêng (màu, giao diện, bố cục). Trước v5.0.0, 9/11
  sản phẩm dùng cùng một màu xanh. Từ v5.0.0: nền/chữ/trạng thái/tiếp cận là chung; màu nhấn, bố cục, bo góc, hoạ
  tiết, font tiêu đề là riêng, khai ở `.standards/tokens/products/lotus.json` - KHÔNG tự khai lại tại repo này.

## Bản sắc đã chốt cho `lotus-share`

| Trường | Giá trị |
| --- | --- |
| `data-product` | `lotus` |
| Màu chính Tối / Sáng | `#E47DFB` / `#A23DB8` (hue OKLCH 320; lý do: tím hoa sen ngả hồng của cánh sen - tách khỏi tím TsuFiles (trước 21/11/2026 hai sản phẩm dùng chung #A970FF)) |
| Bố cục `layout` | `trinh-dien` - hero hai cột (chữ trái, ảnh chụp app lớn tràn phải) + khối tính năng dạng bento |
| Bo góc `shape` | `tron` - 8/14/20px, nút viên thuốc 999px |
| Hoạ tiết `motif` | `canh-sen` (tĩnh, ở hero + `og-image`, phủ ≤ 15%) |
| Font tiêu đề | Quicksand (tự host woff2 bộ `vietnamese`, tối đa 2 độ đậm) |

Muốn đổi bất kỳ giá trị nào: PR vào tsudev-standards (sửa `hue`/`layout`... + chạy `gen-product-palette.mjs`), cổng
kiểm chống trùng phải xanh. KHÔNG ghi đè tại repo này.

## Việc cần làm - chia hai PR, mỗi PR một phiên

**PR 1 - màu + hình** (`feat(ui): bản sắc lotus theo tsudev-standards v5.0.0`):
1. Sync `.standards/` lên v5.0.0 (bước `curl` sync-standards.sh trước, theo `docs/SYNC.md`).
2. Web: nạp `.standards/tokens/tokens.css` rồi `.standards/tokens/products.css`; `<html data-product="lotus">` (cạnh
   `data-theme`). Desktop/di động: gộp đè `products/lotus.json` lên `color.light`/`color.dark` lúc build.
3. Xoá bảng màu tự khai (`palette.css`, `extensions.*.json`, dải `--color-*` riêng) và mã màu cứng còn sót.
4. Giá trị đã lưu `warm` đọc thành `light` (khối `warm` đã gỡ khỏi token).
5. Nút dùng `var(--radius-control)`; h1-h3 và số liệu lớn dùng `var(--font-display)`.
6. Ảnh chụp trước/sau, Sáng + Tối, đính vào PR. Cổng kiểm + test xanh.

**PR 2 - bố cục** (`feat(ui): bố cục trinh-dien + hoạ tiết canh-sen`):
1. Dựng phần THÂN trang chủ website / màn hình đầu app theo `trinh-dien`; header, khu tài khoản, chân trang, bộ chọn
   giao diện giữ theo `ECOSYSTEM_IDENTITY.md` mục 4.
2. Hoạ tiết `canh-sen` tĩnh ở hero, vẽ bằng `accent`/`glow`; sinh lại `og-image.png` cùng hoạ tiết.
3. Ảnh chụp trước/sau, Sáng + Tối.

## Việc riêng của repo này

- **Màu đổi:** trước 21/11/2026 lotus.tsudev.com dùng chung `#A970FF` với TsuFiles. Nay là tím ngả hồng cánh sen (hue 320). Xoá `website/src/styles/palette.css` phần màu, dùng `products.css`.

## Kết quả xử lý

- **21/11/2026 - PR 1 (màu + hình) #114** `feat(ui): bản sắc lotus theo tsudev-standards v5.0.0`:
  - Sync `.standards/` v3.9.1 -> v5.0.0 (bước `curl` sync-standards.sh từ tag v5.0.0 trước).
  - Web: `Trang.astro` nạp `.standards/tokens/tokens.css` + `products.css`, `<html data-theme="dark" data-product="lotus">`.
    Xoá `website/src/styles/palette.css` (cả quầng cam/xanh `--glow-cam/--glow-xanh`) và bản sao cũ `src/styles/tokens.css`
    (v2.0.0). Nút `var(--radius-control)`, mọi bo góc `--radius-sm/md/lg`; h1-h3 `var(--font-display)`: Quicksand tự host
    (`public/fonts/quicksand-{600,700}-{latin,latin-ext,vietnamese}.woff2`, OFL). Màu cứng còn lại có chủ đích: nền trắng
    sau mã QR. `check-dist.mjs` chặn thiếu `data-product`, tự khai token, mã tím cũ.
  - App: `tools/gen_product_tokens.py` sinh `app/lib/config/product_tokens.g.dart` từ `products/lotus.json` +
    `products.css` (CI `fork-ci.yml` chạy `--check`); `theme.dart` dùng màu nhấn bản sắc, bỏ tím tsudev + xanh/cam tự khai;
    nút viên thuốc, ô nhập `radiusMd`; textTheme tiêu đề + chữ lớn (tên thiết bị, tên sản phẩm) dùng Quicksand bản biến
    thiên nguyên văn google/fonts (trục wght 600/700), giấy phép OFL đăng ký ở Giới thiệu > Giấy phép.
  - `warm` -> `light`: `website/public/theme.js` đã có (check:theme kiểm); app không có giá trị `warm`.
  - Ảnh trước/sau Sáng + Tối (app Linux, web trang chủ + Tải về): `logs/anh/20261121-STD50/`, đính trong PR.
  - Kiểm: flutter analyze sạch, flutter test 147 đạt, website build/check-dist/check:theme/check:a11y 0 lỗi,
    check-standards đạt, i18n đạt.
  - Để PR 2: bố cục `trinh-dien`, hoạ tiết `canh-sen`, sinh lại `og-image.png` (`website/scripts/brand_assets.py` còn
    `#A970FF` cho og-image - sửa cùng lúc sinh lại ảnh).

- **21/11/2026 - PR 2 (bố cục + hoạ tiết)** `feat(ui): bố cục trinh-dien + hoạ tiết canh-sen` (PR 1 #114 đã gộp đầu phiên,
  mọi cổng xanh, ủy quyền A):
  - Hoạ tiết `canh-sen` MỘT hình học cho ba nơi (bảy cánh sen, điểm nối nhau, gốc đáy giữa): `website/src/lib/canh-sen.ts`,
    `app/lib/widget/canh_sen_motif.dart`, `website/scripts/brand_assets.py` (`canh_sen_geometry`) - đổi một nơi thì đổi cả ba.
    Tĩnh, màu `accent` của bản sắc, độ phủ 12% (web, og) / 10% (app), không nhận chuột, ẩn khỏi trình đọc màn hình.
  - Website trang chủ `trinh-dien`: hero hai cột (chữ trái; ảnh chụp THẬT màn hình Nhận bản Linux, Sáng/Tối theo
    `data-theme`, tràn mép phải và cắt ở mép màn hình - không cuộn ngang 1440/390px) + Tính năng dạng bento 4 cột (ô
    lớn 2x2 kèm dải nền tảng, ô rộng, ô ngang; 2 cột <= 960px, 1 cột <= 560px). Xoá `public/anh/minh-hoa.svg` (màu xanh
    cứng cũ, chỉ dùng ở hero). Header/chân trang/bộ chọn giao diện giữ nguyên.
  - App: màn hình đầu (tab Nhận) có hoạ tiết sau nội dung; test `test/unit/widget/canh_sen_motif_test.dart`.
  - `og-image.png` sinh lại: màu từ `.standards/tokens/products/lotus.json` (bỏ `#A970FF` + quầng cam/xanh), tiêu đề
    Quicksand 700 (font biến thiên trong `app/assets/fonts`), hoạ tiết canh-sen. Favicon/icon tái sinh trùng byte.
  - Ảnh trước/sau: trước = `web-trang-chu-*.webp`, `app-*.webp`; sau = `pr2-web-trang-chu-*.webp`, `pr2-app-*.webp`
    (`logs/anh/20261121-STD50/`).
  - #115 gộp; deploy lotus.tsudev.com 21/11/2026 (Version c00dff2e), kiểm production đạt.
