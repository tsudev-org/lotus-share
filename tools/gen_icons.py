#!/usr/bin/env python3
"""Lotus Share: sinh TOÀN BỘ icon ứng dụng mọi nền tảng từ một nguồn (BRAND_ASSETS.md mục 7).

Nguồn: support/brand/lotus-share/logo-1024.png - logo Lotus Share nền trong suốt, sinh bởi tools/prepare_brand.py từ
logo-source.png. Đổi logo: thay logo-source.png -> chạy prepare_brand.py -> chạy công cụ này.

    python3 -I tools/prepare_brand.py && python3 -I tools/gen_icons.py     # cần Pillow

Ghi đè đúng các tệp icon đang có của upstream (giữ tên tệp, kích thước, chế độ màu) để gộp upstream dễ.
"""
from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:  # pragma: no cover
    sys.exit("Cần Pillow: pip install Pillow")

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / "app"
SRC = ROOT / "support" / "brand" / "lotus-share" / "logo-1024.png"

# Nền icon: trắng - logo Lotus Share được thiết kế trên nền trắng (quầng tím mờ cần nền sáng).
BG = (0xFF, 0xFF, 0xFF, 255)
WHITE = (255, 255, 255, 255)
BLACK = (0, 0, 0, 255)
RED = (0xD9, 0x2D, 0x20, 255)
GREEN = (0x16, 0x80, 0x3C, 255)

MARK = Image.open(SRC).convert("RGBA")
MW, MH = MARK.size


def mark_fit(box: int) -> Image.Image:
    """Dấu hiệu thu nhỏ để chiều lớn nhất = box (không bao giờ phóng to)."""
    scale = box / max(MW, MH)
    if scale > 1:
        raise SystemExit(f"Nguồn {MW}x{MH} quá nhỏ cho {box}px - không phóng to (BRAND_ASSETS mục 7)")
    return MARK.resize((max(1, round(MW * scale)), max(1, round(MH * scale))), Image.LANCZOS)


def silhouette(im: Image.Image, color) -> Image.Image:
    """Bản một màu (khay hệ thống, monochrome Android, biểu tượng thanh menu macOS)."""
    solid = Image.new("RGBA", im.size, color)
    # Bỏ quầng sáng bán trong suốt (alpha thấp), chỉ giữ nét đặc - nếu không bản một màu thành một khối xám.
    solid.putalpha(im.getchannel("A").point(lambda v: 0 if v < 110 else min(255, (v - 110) * 255 // 90)))
    return solid


def compose(size: int, ratio: float, *, bg=None, shape: str = "none", radius: float = 0.0, mono=None) -> Image.Image:
    """Dấu hiệu ở giữa canvas vuông `size`; `ratio` = tỉ lệ chiều lớn nhất của dấu hiệu so với canvas."""
    work = max(size, 64) * 4 if size < 256 else size  # vẽ lớn rồi thu nhỏ để biên hình nền mịn
    canvas = Image.new("RGBA", (work, work), (0, 0, 0, 0))
    if bg is not None:
        layer = Image.new("RGBA", (work, work), (0, 0, 0, 0))
        d = ImageDraw.Draw(layer)
        if shape == "circle":
            d.ellipse((0, 0, work - 1, work - 1), fill=bg)
        elif shape == "rounded":
            inset = round(work * (1 - radius) / 2) if radius else 0
            d.rounded_rectangle((inset, inset, work - 1 - inset, work - 1 - inset), radius=round(work * 0.185 * (radius or 1)), fill=bg)
        else:
            d.rectangle((0, 0, work, work), fill=bg)
        canvas.alpha_composite(layer)
    m = mark_fit(round(work * ratio))
    if mono is not None:
        m = silhouette(m, mono)
    canvas.alpha_composite(m, ((work - m.width) // 2, (work - m.height) // 2))
    return canvas if work == size else canvas.resize((size, size), Image.LANCZOS)


def save(img: Image.Image, rel: str, mode: str | None = None) -> None:
    path = APP / rel if not rel.startswith("/") else Path(rel)
    path.parent.mkdir(parents=True, exist_ok=True)
    out = img
    if mode == "RGB":
        flat = Image.new("RGBA", img.size, BG)
        flat.alpha_composite(img)
        out = flat.convert("RGB")
    elif mode == "LA":
        out = img.convert("LA")
    out.save(path, optimize=True)
    print(f"  {path.relative_to(ROOT)}  {out.size[0]}x{out.size[1]} {out.mode}")


def save_ico(rel: str) -> None:
    base = compose(256, 0.94)
    path = (APP / rel) if not rel.startswith("/") else Path(rel)
    base.save(path, sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)])
    print(f"  {path.relative_to(ROOT)}  ico 16/24/32/48/64/128/256")


def badge(img: Image.Image, color, kind: str) -> Image.Image:
    """Huy hiệu tròn góc trên phải (Dock macOS: lỗi/thành công)."""
    out = img.copy()
    s = img.width
    r = round(s * 0.2)
    cx, cy = s - r - round(s * 0.02), r + round(s * 0.02)
    d = ImageDraw.Draw(out)
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=color)
    w = max(2, round(r * 0.22))
    k = round(r * 0.45)
    if kind == "x":
        d.line((cx - k, cy - k, cx + k, cy + k), fill=WHITE, width=w)
        d.line((cx - k, cy + k, cx + k, cy - k), fill=WHITE, width=w)
    else:
        d.line((cx - k, cy, cx - k // 3, cy + k * 2 // 3, cx + k, cy - k * 2 // 3), fill=WHITE, width=w, joint="curve")
    return out


def main() -> int:
    print(f"Nguồn: {SRC.relative_to(ROOT)} ({MW}x{MH})")

    # ---- Logo trong ứng dụng + khay hệ thống (app/assets/img)
    for s in (32, 128, 256, 512):
        save(compose(s, 0.94), f"assets/img/logo-{s}.png")
    save(compose(512, 0.94, mono=WHITE), "assets/img/logo-512-white.png")
    save(compose(32, 0.94, mono=WHITE), "assets/img/logo-32-white.png")
    save(compose(32, 0.94, mono=BLACK), "assets/img/logo-32-black.png")
    save_ico("assets/img/logo.ico")
    save_ico("assets/packaging/logo.ico")

    # ---- Windows
    save_ico("windows/runner/resources/app_icon.ico")

    # ---- Android: icon cũ (API < 26), icon thích ứng (nền + tiền cảnh + đơn sắc), ô cài đặt nhanh
    dens = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    for name, k in dens.items():
        res = f"android/app/src/main/res/mipmap-{name}"
        save(compose(round(48 * k), 0.72, bg=BG, shape="rounded", radius=0.92), f"{res}/ic_launcher.png")
        fg = round(108 * k)  # vùng an toàn 66/108: dấu hiệu chiếm 56% canvas
        save(compose(fg, 0.56), f"{res}/ic_launcher_foreground.png")
        save(compose(fg, 0.56, mono=WHITE), f"{res}/ic_launcher_monochrome.png", mode="LA")
        save(compose(fg, 0.5, mono=WHITE), f"{res}/ic_launcher_quicktile_foreground.png")
    save(compose(192, 0.68, bg=BG, shape="circle"), "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png")
    save(compose(512, 0.76, bg=BG), "android/app/src/main/ic_launcher-playstore.png", mode="RGB")
    bgxml = APP / "android/app/src/main/res/values/ic_launcher_background.xml"
    bgxml.write_text('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
                     '    <!-- lotus-share: nền icon trắng, đồng bộ BG trong tools/gen_icons.py -->\n'
                     '    <color name="ic_launcher_background">#%02X%02X%02X</color>\n</resources>\n' % BG[:3], encoding="utf-8")

    # ---- iOS: icon vuông đặc, không kênh alpha (App Store từ chối icon có alpha)
    ios = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for f, s in {"Icon-App-1024.png": 1024, "Icon-App-20.png": 20, "Icon-App-20@2x.png": 40, "Icon-App-20@3x.png": 60,
                 "Icon-App-29.png": 29, "Icon-App-29@2x.png": 58, "Icon-App-29@3x.png": 87, "Icon-App-40.png": 40,
                 "Icon-App-40@2x.png": 80, "Icon-App-40@3x.png": 120, "Icon-App-60@2x.png": 120, "Icon-App-60@3x.png": 180,
                 "Icon-App-76.png": 76, "Icon-App-76@2x.png": 152, "Icon-App-83.5@2x.png": 167}.items():
        save(compose(s, 0.76, bg=BG), f"{ios}/{f}", mode="RGB")

    # ---- macOS: lưới icon của Apple (khối bo góc 824/1024, chừa lề), Dock có huy hiệu, thanh menu (ảnh mẫu đen)
    mac = "macos/Runner/Assets.xcassets"
    for s in (16, 32, 64, 128, 256, 512, 1024):
        save(compose(s, 0.62, bg=BG, shape="rounded", radius=0.805), f"{mac}/AppIcon.appiconset/logo-1024-mac-{s}.png")
    dock = compose(256, 0.62, bg=BG, shape="rounded", radius=0.805)
    save(badge(dock, RED, "x"), f"{mac}/AppIconWithErrorMark.imageset/logo-1024-mac-256.png")
    save(badge(dock, GREEN, "v"), f"{mac}/AppIconWithSuccessMark.imageset/logo-1024-mac-256.png")
    save(compose(32, 0.94, mono=BLACK), f"{mac}/StatusBarItemIcon.imageset/logo-32-black.png")
    compose(1024, 0.62, bg=BG, shape="rounded", radius=0.805).save(APP / "macos/ShareExtension/icon.icns")
    print("  app/macos/ShareExtension/icon.icns")

    # ---- Web (Flutter web build)
    save(compose(16, 0.94), "web/favicon.png")
    save(compose(192, 0.9), "web/icons/Icon-192.png")
    save(compose(512, 0.9), "web/icons/Icon-512.png")
    save(compose(192, 0.6, bg=BG), "web/icons/Icon-maskable-192.png", mode="RGB")
    save(compose(512, 0.6, bg=BG), "web/icons/Icon-maskable-512.png", mode="RGB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
