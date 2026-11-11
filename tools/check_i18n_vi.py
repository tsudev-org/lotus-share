#!/usr/bin/env python3
"""lotus-share: kiểm tra bản dịch tiếng Việt và các điểm riêng của fork.

Chạy từ gốc repo:  python3 -I tools/check_i18n_vi.py
Mã thoát khác 0 = có lỗi (CI chặn merge).

Kiểm:
  1. vi.json có ĐỦ mọi khóa của en.json (kể cả dạng số nhiều), không thừa khóa lạ.
  2. Tham số {abc} trong bản dịch tiếng Việt khớp bản tiếng Anh (thiếu tham số => app hiển thị sai).
  3. Không còn chuỗi tiếng Việt y hệt tiếng Anh, trừ danh sách cho phép (thuật ngữ như IP, GIF, OLED).
  4. Tên sản phẩm (appName) là Lotus Share ở mọi ngôn ngữ.
  5. Ngôn ngữ mặc định trong fork_config.dart là "vi".
  6. Mã giao diện không viết cứng URL localsend.org (phải đi qua fork_config.dart), trừ chú thích.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
I18N = ROOT / "app" / "assets" / "i18n"
APP_LIB = ROOT / "app" / "lib"
FORK_CONFIG = APP_LIB / "config" / "fork_config.dart"

PRODUCT_NAME = "Lotus Share"
# Chuỗi được phép giống hệt tiếng Anh: thuật ngữ, ký hiệu, định dạng số.
SAME_AS_EN_ALLOWED = {
    "receiveTab.infoBox.ip",
    "settingsTab.general.colorOptions.oled",
    "progressPage.remainingTime.minutes",
    "assetPicker.gifIndicator",
    "assetPicker.sTypeVideoLabel",
    "tsudev.copyright",
}
# Giá trị tham chiếu "@:..." của slang trỏ sang khóa khác, không phải văn bản hiển thị.
LINK_PREFIX = "@:"
PLACEHOLDER = re.compile(r"\{(\w+)\}")
MODIFIER = re.compile(r"\(.*\)$")


def base_key(key: str) -> str:
    """Bỏ phần bổ nghĩa của slang: 'addApps(param=n)' -> 'addApps'."""
    return MODIFIER.sub("", key)


def flatten(node: dict, prefix: str = "") -> dict[str, object]:
    out: dict[str, object] = {}
    for key, value in node.items():
        if key.startswith("@"):
            continue  # siêu dữ liệu cho người dịch
        name = prefix + base_key(key)
        if isinstance(value, dict):
            out.update(flatten(value, name + "."))
        else:
            out[name] = value
    return out


def load(path: Path) -> dict:
    with path.open(encoding="utf-8") as fh:
        return json.load(fh)


def plural_parents(flat: dict[str, object]) -> set[str]:
    forms = {"zero", "one", "two", "few", "many", "other"}
    return {k.rsplit(".", 1)[0] for k in flat if k.rsplit(".", 1)[-1] in forms}


def main() -> int:
    errors: list[str] = []
    en = flatten(load(I18N / "en.json"))
    vi = flatten(load(I18N / "vi.json"))

    # Tiếng Việt không có dạng số nhiều: chỉ cần "other". So khóa theo khóa cha của nhóm số nhiều.
    en_plural, vi_plural = plural_parents(en), plural_parents(vi)

    def norm(keys: set[str], plural: set[str]) -> set[str]:
        return {k.rsplit(".", 1)[0] if k.rsplit(".", 1)[0] in plural else k for k in keys}

    en_keys, vi_keys = norm(set(en), en_plural), norm(set(vi), vi_plural)
    for key in sorted(en_keys - vi_keys):
        errors.append(f"thiếu bản dịch: {key}")
    for key in sorted(vi_keys - en_keys):
        errors.append(f"khóa thừa (không có trong en.json): {key}")

    for key, en_val in en.items():
        if key not in vi:
            continue
        vi_val = vi[key]
        if isinstance(en_val, str) and isinstance(vi_val, str):
            if en_val.startswith(LINK_PREFIX):
                continue
            if set(PLACEHOLDER.findall(en_val)) != set(PLACEHOLDER.findall(vi_val)):
                errors.append(f"tham số lệch ở {key}: en={PLACEHOLDER.findall(en_val)} vi={PLACEHOLDER.findall(vi_val)}")
            if vi_val == en_val and key not in SAME_AS_EN_ALLOWED and key != "appName" and re.search(r"[A-Za-z]{2,}", en_val):
                errors.append(f"chưa dịch (giống hệt tiếng Anh): {key} = {en_val!r}")

    for path in sorted(I18N.glob("*.json")):
        if path.name.startswith("_"):
            continue
        name = load(path).get("appName")
        if name is not None and name != PRODUCT_NAME:
            errors.append(f"{path.name}: appName = {name!r}, phải là {PRODUCT_NAME!r}")

    config = FORK_CONFIG.read_text(encoding="utf-8")
    if not re.search(r"const forkDefaultLocaleTag = 'vi';", config):
        errors.append("fork_config.dart: forkDefaultLocaleTag phải là 'vi'")

    url = re.compile(r"""['"]https?://(?:[\w-]+\.)*localsend\.org""")
    for path in sorted(APP_LIB.rglob("*.dart")):
        rel = path.relative_to(ROOT)
        if "gen" in path.parts or path == FORK_CONFIG:
            continue
        for no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            code = line.split("//", 1)[0] if "'//" not in line and '"//' not in line else line
            if url.search(code) and not line.lstrip().startswith("//"):
                errors.append(f"{rel}:{no}: URL localsend.org viết cứng - đưa vào fork_config.dart")

    if errors:
        print(f"TRƯỢT - {len(errors)} lỗi:")
        for err in errors:
            print(f"  - {err}")
        return 1
    print(f"ĐẠT - {len(vi)} chuỗi tiếng Việt, khóa khớp en.json, appName = {PRODUCT_NAME}, mặc định 'vi'.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
