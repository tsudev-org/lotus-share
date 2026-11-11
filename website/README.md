# Website lotus.tsudev.com

Trang sản phẩm của Lotus Share: [Astro](https://astro.build) dựng trang tĩnh; JavaScript phía trình duyệt chỉ có
`public/theme.js` (bộ chọn giao diện Sáng/Tối/Hệ thống ở chân trang, mặc định Tối, khóa `tsudev-theme` như tsudev.com;
nạp chặn trong `<head>`, CSP `script-src 'self'`, không script nội tuyến),
host trên Cloudflare Workers Static Assets (Worker `lotus-share`, không có mã chạy; tên miền con `lotus.tsudev.com`
của hệ tsudev.com, cấu hình ở `wrangler.jsonc`). Cùng khung với `files.tsudev.com` (repo tsudev-files).

* Tài liệu lấy trực tiếp từ tệp của repo (`SECURITY.md`, `docs/vi/KIEN-TRUC-BAO-MAT.md`, `CHANGELOG.md`, `LICENSE`,
  `NOTICE`) - sửa ở đó, không sửa trong `website/`. Trang Trang chủ, Tải về, Hướng dẫn viết tay trong `src/pages/`.
* Bản phát hành (phiên bản, liên kết, SHA-256) lấy từ GitHub Releases lúc build; repo chưa có bản phát hành thì trang
  Tải về hiện thông báo "đang chuẩn bị" thay vì danh sách gói. Quy tắc nhận diện tên tệp: `NEN_TANG` trong
  `src/lib/noi-dung.ts`.
* Tài sản thương hiệu (`public/favicon*`, `android-chrome-*`, `og-image.png`, `brand/`) sinh bằng
  `scripts/brand_assets.py` từ dây chuyền thương hiệu của repo `tsudev-org/tsudev`; không sửa tay. Minh họa trang chủ:
  `public/anh/minh-hoa.svg`.
* Font Be Vietnam Pro tự host (SIL OFL 1.1), token màu sao nguyên văn từ `.standards/tokens/tokens.css`.
* Header bảo mật (HSTS, CSP chặt `default-src 'none'`, `X-Frame-Options: DENY`...) ở `public/_headers`;
  `security.txt` ở `public/.well-known/`. `scripts/check-dist.mjs` chạy sau mỗi lần build: title, `og:site_name`,
  canonical, độ dài mô tả, chặn CSS/JS nội tuyến, `rel` của liên kết ngoài, em-dash, liên kết nội bộ gãy.

```bash
cd website
npm ci
npm run dev          # xem thử ở http://localhost:4321
npm run build        # dựng vào dist/ và kiểm tra
npm run check:a11y   # axe-core WCAG 2.2 AA mọi trang, Sáng + Tối (lần đầu: npx playwright install chromium)
npm run check:theme  # bộ chọn giao diện trong Chromium, với CSP của production
npm run deploy       # build rồi `wrangler deploy` (cần `npx wrangler login` với tài khoản tsudev)
```

## Thiết lập một lần

`npm run deploy`: khối `routes` trong `wrangler.jsonc` tự gắn `lotus.tsudev.com` (Cloudflare tạo bản ghi DNS và
chứng chỉ). Rồi đổi trang chủ của repo:

```bash
gh repo edit tsudev-org/lotus-share --homepage https://lotus.tsudev.com
```
