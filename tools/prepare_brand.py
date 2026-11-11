#!/usr/bin/env python3
"""Lotus Share: dựng bộ logo chuẩn từ ảnh gốc (một nguồn duy nhất cho icon, favicon, website).

    python3 -I tools/prepare_brand.py   # cần Pillow >= 11 (WebP + AVIF)

Đầu vào : support/brand/lotus-share/logo-source.png (ảnh gốc, có thể nền trắng).
Đầu ra  : support/brand/lotus-share/
            logo-1024.png   bản chính, nền TRONG SUỐT, vuông 1024 - đầu vào của tools/gen_icons.py
            logo-512.webp, logo-512.avif, logo-256.webp, logo-256.avif - dùng cho web (kèm PNG dự phòng)
            accent.json     bảng màu nhấn rút từ logo (để app và website dùng chung)

Thay logo: chép ảnh mới (khuyến nghị >= 1024 px) đè lên logo-source.png, chạy công cụ này rồi tools/gen_icons.py.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

try:
    from PIL import Image, ImageFilter
except ImportError:  # pragma: no cover
    sys.exit("Cần Pillow: pip install Pillow")

ROOT = Path(__file__).resolve().parent.parent
DIR = ROOT / "support" / "brand" / "lotus-share"
SRC = DIR / "logo-source.png"
MASTER = 1024
MARGIN = 0.02  # lề trong suốt mỗi cạnh (tỉ lệ khung)


def color_to_alpha_white(im: Image.Image) -> Image.Image:
    """Tách nền trắng. Điểm có độ đậm màu (chroma = max-min) cao là nét logo: giữ ĐẶC, đúng màu gốc.
    Điểm gần trắng/xám nhạt (nền, quầng sáng) dùng "color to alpha": càng gần trắng càng trong suốt, màu được
    khôi phục để đặt lại trên nền trắng vẫn y ảnh gốc. Vùng giữa hai ngưỡng chuyển tiếp mượt."""
    lo, hi = 40, 110  # ngưỡng chroma
    im = im.convert("RGBA")
    out = []
    for r, g, b, a0 in im.getdata():
        c2a = max(255 - r, 255 - g, 255 - b) / 255.0
        chroma = max(r, g, b) - min(r, g, b)
        t = min(1.0, max(0.0, (chroma - lo) / (hi - lo)))
        a = c2a + (1.0 - c2a) * t  # t=1: đặc hoàn toàn
        if a < 0.03:
            out.append((0, 0, 0, 0))
            continue

        def ch(c: int, a: float = a) -> int:
            return max(0, min(255, round((c - 255 * (1 - a)) / a)))

        out.append((ch(r), ch(g), ch(b), round(a * a0)))
    res = Image.new("RGBA", im.size)
    res.putdata(out)
    return res


def square(im: Image.Image) -> Image.Image:
    bbox = im.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
    im = im.crop(bbox)
    side = round(max(im.size) / (1 - 2 * MARGIN))
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(im, ((side - im.width) // 2, (side - im.height) // 2), im)
    return canvas


def resize(im: Image.Image, size: int) -> Image.Image:
    """Đổi kích thước trên ảnh nhân sẵn alpha (premultiplied) để biên không loang màu."""
    pm = im.convert("RGBa").resize((size, size), Image.LANCZOS)
    out = pm.convert("RGBA")
    if size > im.width:  # phóng to: làm nét nhẹ phần màu, giữ nguyên alpha
        a = out.getchannel("A")
        out = out.filter(ImageFilter.UnsharpMask(radius=1.2, percent=60, threshold=2))
        out.putalpha(a)
    return out


def accent(im: Image.Image) -> dict:
    """Ba màu chủ đạo của logo (tím, cam, xanh) - lấy theo trung bình các điểm đậm đặc theo vùng sắc độ."""
    import colorsys
    buckets = {"purple": [], "orange": [], "blue": []}
    for r, g, b, a in im.resize((256, 256)).getdata():
        if a < 240:
            continue
        h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        if s < 0.45 or v < 0.45:
            continue
        deg = h * 360
        key = "orange" if 10 <= deg < 50 else "blue" if 190 <= deg < 235 else "purple" if 255 <= deg < 300 else None
        if key:
            buckets[key].append((r, g, b))
    res = {}
    for k, px in buckets.items():
        if px:
            n = len(px)
            res[k] = "#%02X%02X%02X" % tuple(round(sum(p[i] for p in px) / n) for i in range(3))
    return res


def main() -> int:
    src = Image.open(SRC)
    print(f"Nguồn {SRC.relative_to(ROOT)}: {src.width}x{src.height}")
    if max(src.size) < MASTER:
        print(f"  CẢNH BÁO: nguồn < {MASTER}px - bản {MASTER} được phóng to (LANCZOS + làm nét nhẹ). "
              "Có ảnh gốc lớn hơn/vector thì thay logo-source.png và chạy lại.")
    master = resize(square(color_to_alpha_white(src)), MASTER)
    master.save(DIR / "logo-1024.png", optimize=True)
    for s in (512, 256):
        im = resize(master, s)
        im.save(DIR / f"logo-{s}.webp", quality=92, method=6)
        im.save(DIR / f"logo-{s}.avif", quality=80)
    acc = accent(master)
    (DIR / "accent.json").write_text(json.dumps(acc, indent=2) + "\n", encoding="utf-8")
    for f in sorted(DIR.iterdir()):
        print(f"  {f.relative_to(ROOT)}  {f.stat().st_size // 1024} KiB")
    print("  màu nhấn:", acc)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
