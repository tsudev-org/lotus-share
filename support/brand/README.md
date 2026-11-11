# Thương hiệu Lotus Share

Mọi logo, icon, favicon của dự án sinh từ **một nguồn**: `lotus-share/logo-source.png`.

| Tệp | Vai trò |
| --- | --- |
| `lotus-share/logo-source.png` | Ảnh gốc do chủ dự án cung cấp 11/11/2026 (466x476, nền trắng). SHA-256 `472c894c13c834dc507a2f31a5d52f827d389dce081b5ff926a3e4f18234ea9d` |
| `lotus-share/logo-1024.png` | Bản chính nền TRONG SUỐT, vuông 1024 - đầu vào của mọi công cụ bên dưới |
| `lotus-share/logo-{256,512}.{webp,avif}` | Bản nén hiện đại cho web (kèm PNG dự phòng) |
| `lotus-share/accent.json` | Màu nhấn rút từ logo (tím, cam, xanh) - app và website dùng chung |

## Đổi logo

1. Chép ảnh mới đè lên `lotus-share/logo-source.png` (khuyến nghị >= 1024 px; ảnh hiện tại chỉ 466 px nên bản
   1024 được phóng to có làm nét - có bản lớn hơn hoặc vector thì thay để icon sắc hơn).
2. `python3 -I tools/prepare_brand.py` - tách nền trắng (nét màu đậm giữ đặc, nền và quầng sáng chuyển trong suốt),
   cắt sát, đưa về khung vuông, xuất WebP/AVIF, rút màu nhấn.
3. `python3 -I tools/gen_icons.py` - icon Android (thường, thích ứng, đơn sắc), iOS, macOS (Dock, thanh menu, huy
   hiệu), Windows `.ico`, Linux/khay, web của app.
4. `python3 website/scripts/brand_assets.py --fonts <thư mục BeVietnamPro-*.ttf>` - favicon, apple-touch, PWA, logo
   đầu trang (AVIF/WebP/PNG), ảnh chia sẻ OG.

Cần Pillow >= 11 (có WebP + AVIF). Bản một màu (khay, đơn sắc) bỏ quầng sáng bán trong suốt, chỉ giữ nét đặc.

## Quy ước

Logo riêng thay dấu hiệu chung tsudev là ngoại lệ có chủ đích (quyết định chủ dự án 11/11/2026), ghi ở `AGENTS.md`
mục B.4 và đề xuất sửa `BRAND_ASSETS.md` ở `tsudev-standards` (phiếu `20261112-01_de-xuat-logo-rieng-tung-san-pham.md`). Logo LocalSend không dùng ở bất kỳ đâu.
