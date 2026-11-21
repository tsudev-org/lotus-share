#!/usr/bin/env python3
"""Sinh app/lib/config/product_tokens.g.dart từ lớp bản sắc tsudev-standards v5.0.0 (DESIGN_SYSTEM mục 1.2.1, mục 7).

Nguồn (bản sao chỉ-đọc, KHÔNG sửa):
  .standards/tokens/products/lotus.json   - 10 vai trò nhấn Sáng/Tối, font tiêu đề
  .standards/tokens/products.css          - bộ bo góc đã sinh cho data-product="lotus" (sm/md/lg/control)

Ứng dụng KHÔNG tự khai màu nhấn: đổi màu là PR vào tsudev-standards rồi sync xuống và chạy lại script này.

  python3 -I tools/gen_product_tokens.py           # ghi tệp
  python3 -I tools/gen_product_tokens.py --check   # CI: lệch nguồn thì thoát 1
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PRODUCT = "lotus"
SRC_JSON = ROOT / ".standards/tokens/products" / f"{PRODUCT}.json"
SRC_CSS = ROOT / ".standards/tokens/products.css"
OUT = ROOT / "app/lib/config/product_tokens.g.dart"
ROLES = ["text-link", "primary", "primary-hover", "primary-active", "on-primary", "focus-ring", "accent", "glow",
         "icon-info", "icon-nav"]


def camel(name: str) -> str:
    head, *rest = name.split("-")
    return head + "".join(p.capitalize() for p in rest)


def argb(value: str) -> str:
    v = value.strip()
    m = re.fullmatch(r"#([0-9A-Fa-f]{6})", v)
    if m:
        return f"0xFF{m.group(1).upper()}"
    m = re.fullmatch(r"rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([0-9.]+)\s*\)", v)
    if m:
        r, g, b = (int(m.group(i)) for i in range(1, 4))
        a = round(float(m.group(4)) * 255)
        return f"0x{a:02X}{r:02X}{g:02X}{b:02X}"
    raise SystemExit(f"Không đọc được màu: {value}")


def radii() -> dict:
    css = SRC_CSS.read_text(encoding="utf-8")
    m = re.search(r':root\[data-product="%s"\]\s*\{([^}]*)\}' % PRODUCT, css)
    if not m:
        raise SystemExit(f'{SRC_CSS}: thiếu khối :root[data-product="{PRODUCT}"]')
    out = {}
    for k in ("sm", "md", "lg", "control"):
        v = re.search(r"--radius-%s:\s*(\d+)px;" % k, m.group(1))
        if not v:
            raise SystemExit(f"{SRC_CSS}: thiếu --radius-{k} của {PRODUCT}")
        out[k] = int(v.group(1))
    return out


def render() -> str:
    data = json.loads(SRC_JSON.read_text(encoding="utf-8"))
    version = (ROOT / ".standards/VERSION").read_text(encoding="utf-8").strip()
    lines = [
        "// SINH TỰ ĐỘNG bởi tools/gen_product_tokens.py - KHÔNG SỬA TAY.",
        f"// Nguồn: .standards/tokens/products/{PRODUCT}.json + products.css (tsudev-standards {version}).",
        f"// Bản sắc: bố cục {data['layout']} | bo góc {data['shape']} | hoạ tiết {data['motif']} | tiêu đề {data['fontDisplay']}.",
        "// ignore_for_file: constant_identifier_names",
        "",
        "import 'dart:ui';",
        "",
        "/// Vai trò nhấn của một chế độ màu (DESIGN_SYSTEM mục 1.1, lớp bản sắc ghi đè).",
        "class ProductAccent {",
        *[f"  final Color {camel(r)};" for r in ROLES],
        "",
        "  const ProductAccent({",
        *[f"    required this.{camel(r)}," for r in ROLES],
        "  });",
        "}",
        "",
        "abstract final class ProductTokens {",
        f"  static const id = '{data['id']}';",
        f"  static const fontDisplay = '{data['fontDisplay']}';",
    ]
    for mode in ("light", "dark"):
        colors = data["colors"][mode]
        lines.append(f"  static const {mode} = ProductAccent(")
        lines += [f"    {camel(r)}: Color({argb(colors[r])})," for r in ROLES]
        lines.append("  );")
    for k, v in radii().items():
        lines.append(f"  static const double radius{k.capitalize()} = {v};")
    lines.append("}")
    return "\n".join(lines) + "\n"


def main() -> int:
    content = render()
    if "--check" in sys.argv:
        if not OUT.exists() or OUT.read_text(encoding="utf-8") != content:
            print(f"::error::{OUT.relative_to(ROOT)} lệch .standards/tokens - chạy python3 -I tools/gen_product_tokens.py")
            return 1
        print(f"{OUT.relative_to(ROOT)} khớp nguồn")
        return 0
    OUT.write_text(content, encoding="utf-8")
    print(f"Đã ghi {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
