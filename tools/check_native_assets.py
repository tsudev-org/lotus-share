#!/usr/bin/env python3
"""Cổng: mọi thư viện build hook ghi trong NativeAssetsManifest.json phải có trong bundle desktop.

Thiếu thì Dart FFI không nạp được thư viện lúc chạy (ví dụ cnativeapi của tray_manager => khay hệ thống hỏng im lặng,
chỉ có một dòng cảnh báo trong log). `flutter test` không bắt được vì test không nạp thư viện đó.

Dùng: python3 -I tools/check_native_assets.py <thư mục bundle> <thư mục thư viện tương đối>
  Linux:   python3 -I tools/check_native_assets.py app/build/linux/x64/release/bundle lib
  Windows: python3 -I tools/check_native_assets.py app/build/windows/x64/runner/Release .
"""

import json
import sys
from pathlib import Path


def main() -> int:
    # Máy chạy Windows dùng cp1252 cho console: ép UTF-8 để in được tiếng Việt.
    for stream in (sys.stdout, sys.stderr):
        stream.reconfigure(encoding="utf-8")
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    bundle = Path(sys.argv[1])
    lib_dir = bundle / sys.argv[2]
    manifest = bundle / "data" / "flutter_assets" / "NativeAssetsManifest.json"
    if not manifest.is_file():
        print(f"LỖI: không thấy {manifest}", file=sys.stderr)
        return 1
    data = json.loads(manifest.read_text(encoding="utf-8"))
    missing = []
    count = 0
    for target, assets in data.get("native-assets", {}).items():
        for asset_id, spec in assets.items():
            kind = spec[0]
            if kind in ("process", "executable", "system"):
                continue  # thư viện của hệ điều hành / tiến trình, không đóng gói
            name = spec[1]
            count += 1
            if not (lib_dir / name).is_file():
                missing.append(f"{target} {asset_id}: thiếu {lib_dir / name}")
    if missing:
        print("LỖI: bundle thiếu thư viện build hook (xem khối NATIVE_ASSETS_DIR trong CMakeLists.txt):", file=sys.stderr)
        for line in missing:
            print(f"  {line}", file=sys.stderr)
        return 1
    print(f"Đạt: {count} thư viện build hook có trong {lib_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
