#!/usr/bin/env python3
"""Sinh tài sản thương hiệu cho lotus.tsudev.com từ logo Lotus Share (chạy tay khi logo đổi; kết quả được commit).

Nguồn DUY NHẤT: support/brand/lotus-share/logo-1024.png (nền trong suốt, sinh bởi tools/prepare_brand.py).
Chỉ thu nhỏ (LANCZOS trên ảnh nhân sẵn alpha), không phóng to.

  python3 website/scripts/brand_assets.py --fonts <thư mục chứa BeVietnamPro-{Regular,SemiBold,Bold}.ttf>

Cần Pillow >= 11 (WebP + AVIF).
"""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "website" / "public"
SRC = ROOT / "support" / "brand" / "lotus-share" / "logo-1024.png"
# Bản sắc tsudev-standards v5.0.0 (DESIGN_SYSTEM mục 1.2): màu nhấn chế độ Tối + font tiêu đề, đọc từ bản sao chỉ-đọc
PRODUCT = json.loads((ROOT / ".standards" / "tokens" / "products" / "lotus.json").read_text(encoding="utf-8"))
DISPLAY_FONT = ROOT / "app" / "assets" / "fonts" / "Quicksand-VariableFont_wght.ttf"
WHITE = (255, 255, 255, 255)
# Giao diện tối mặc định của hệ sinh thái (phiếu 20261110-05)
DARK_BG = "#0A0A0A"
DARK_SURFACE = "#111111"
DARK_BORDER = "#242424"
TEXT = "#EDEDED"
TEXT2 = "#B4B4B4"


def fit(im: Image.Image, size: int) -> Image.Image:
    return im.convert("RGBa").resize((size, size), Image.LANCZOS).convert("RGBA")


def on_bg(im: Image.Image, size: int, ratio: float, bg=WHITE) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), bg)
    m = fit(im, round(size * ratio))
    canvas.alpha_composite(m, ((size - m.width) // 2, (size - m.height) // 2))
    return canvas


def hex_rgb(h: str) -> tuple[int, int, int]:
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


def canh_sen_geometry() -> list[tuple[list[tuple[float, float]], list[tuple[float, float]]]]:
    """Hoạ tiết canh-sen: GIỐNG HỆT website/src/lib/canh-sen.ts và app/lib/widget/canh_sen_motif.dart."""
    petals = []
    for k in range(7):
        off = k - 3
        ang = -math.pi / 2 + math.radians(off * 22)
        length = 1 - 0.12 * abs(off)
        dx, dy = math.cos(ang), math.sin(ang)
        nx, ny = -dy, dx
        left, right = [], []
        for i in range(6):
            t = i / 5
            w = 0.26 * length * math.sin(math.pi * t)
            ax, ay = dx * t * length, dy * t * length
            left.append((ax - nx * w, ay - ny * w))
            right.append((ax + nx * w, ay + ny * w))
        petals.append((left, right))
    return petals


def canh_sen(size, origin, unit, color, opacity) -> Image.Image:
    """Vẽ hoạ tiết lên lớp trong suốt rồi giảm alpha cả lớp (chỗ nét chồng nhau không đậm hơn opacity)."""
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    rgb = hex_rgb(color)
    p = lambda o: (origin[0] + o[0] * unit, origin[1] + o[1] * unit)  # noqa: E731
    for left, right in canh_sen_geometry():
        d.line([p(o) for o in left + right[::-1][1:]], fill=(*rgb, 255), width=2, joint="curve")
        for i in range(1, len(left) - 1):
            d.line([p(left[i]), p(right[i])], fill=(*rgb, 255), width=2)
            for q in (p(left[i]), p(right[i])):
                d.ellipse((q[0] - 3.5, q[1] - 3.5, q[0] + 3.5, q[1] + 3.5), fill=(*rgb, 255))
        q = p(left[-1])
        d.ellipse((q[0] - 5, q[1] - 5, q[0] + 5, q[1] + 5), fill=(*rgb, 255))
    d.ellipse((origin[0] - 6, origin[1] - 6, origin[0] + 6, origin[1] + 6), fill=(*rgb, 255))
    alpha = layer.getchannel("A").point(lambda v: round(v * opacity))
    layer.putalpha(alpha)
    return layer


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--fonts", required=True, type=Path)
    a = ap.parse_args()
    logo = Image.open(SRC).convert("RGBA")
    (OUT / "brand").mkdir(parents=True, exist_ok=True)

    # Favicon: nền trong suốt (tab trình duyệt sáng/tối đều rõ vì logo có viền màu đậm)
    for s in (16, 32, 96):
        fit(logo, s).save(OUT / f"favicon-{s}x{s}.png", optimize=True)
    fit(logo, 256).save(OUT / "favicon.ico", sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)])
    # Apple: không kênh alpha, nền trắng như thiết kế gốc
    on_bg(logo, 180, 0.84).convert("RGB").save(OUT / "apple-touch-icon.png", optimize=True)
    # PWA: bản thường (trong suốt) + maskable (vùng an toàn 80% -> logo 62%)
    for s in (192, 512):
        fit(logo, s).save(OUT / f"android-chrome-{s}x{s}.png", optimize=True)
        on_bg(logo, s, 0.62).convert("RGB").save(OUT / f"android-chrome-maskable-{s}x{s}.png", optimize=True)
    # Logo đầu/chân trang: AVIF + WebP + PNG dự phòng, 2x cho màn hình mật độ cao
    for s in (96, 192):
        m = fit(logo, s)
        m.save(OUT / f"brand/lotus-share-{s}.png", optimize=True)
        m.save(OUT / f"brand/lotus-share-{s}.webp", quality=90, method=6)
        m.save(OUT / f"brand/lotus-share-{s}.avif", quality=75)
    stale = OUT / "brand" / "logo-mark.png"
    if stale.exists():
        stale.unlink()

    # og-image.png 1200x630, giao diện tối + quầng --glow + hoạ tiết chữ ký canh-sen (accent, độ phủ 12%)
    W, H = 1200, 630
    dark = PRODUCT["colors"]["dark"]
    og = Image.new("RGBA", (W, H), DARK_BG)
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((40, 40, 560, 560), fill=(*hex_rgb(dark["primary"]), 60))
    og.alpha_composite(glow.filter(ImageFilter.GaussianBlur(90)))
    og.alpha_composite(canh_sen((W, H), origin=(W - 250, H - 40), unit=400, color=dark["accent"], opacity=0.12))
    d = ImageDraw.Draw(og)
    d.rounded_rectangle((48, 48, W - 48, H - 48), radius=32, outline=DARK_BORDER, width=2)
    mh = 340
    og.alpha_composite(fit(logo, mh), (110, (H - mh) // 2))
    bold = ImageFont.truetype(str(DISPLAY_FONT), 72)
    bold.set_variation_by_axes([700])
    reg = ImageFont.truetype(str(a.fonts / "BeVietnamPro-Regular.ttf"), 26)
    semi = ImageFont.truetype(str(a.fonts / "BeVietnamPro-SemiBold.ttf"), 30)
    x = 110 + mh + 56
    d.text((x, 172), "Lotus Share", font=bold, fill=TEXT)
    d.text((x, 276), "Gửi tệp giữa các thiết bị, không cần Internet", font=reg, fill=TEXT2)
    d.text((x, 320), "Cùng mạng Wi-Fi - mã hóa - tiếng Việt", font=reg, fill=TEXT2)
    d.rounded_rectangle((x, 400, x + 250, 456), radius=28, fill=dark["primary"])
    d.text((x + 125, 428), "lotus.tsudev.com", font=ImageFont.truetype(str(a.fonts / "BeVietnamPro-SemiBold.ttf"), 20),
           fill=dark["on-primary"], anchor="mm")
    d.text((W - 110, H - 100), "tsudev", font=semi, fill=TEXT, anchor="rs")
    og.convert("RGB").save(OUT / "og-image.png", optimize=True)
    for f in sorted(OUT.glob("*.png")) + sorted(OUT.glob("favicon.ico")) + sorted((OUT / "brand").iterdir()):
        print(f"  {f.relative_to(ROOT)}  {f.stat().st_size // 1024} KiB")


if __name__ == "__main__":
    main()
