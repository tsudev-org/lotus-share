#!/usr/bin/env python3
"""lotus-share: trả app/lib/gen/strings.g.dart về đúng định dạng của upstream sau `dart run slang`.

slang ghi `zhTw(...);` trên một dòng, còn bản upstream (định dạng bằng dart format kiểu "tall")
để dấu `;` ở dòng riêng. Không sửa thì mỗi lần sinh lại đều có diff nhiễu và xung đột khi gộp upstream.

Chạy từ gốc repo:  python3 -I tools/fix_slang_format.py
"""
from pathlib import Path
import re
import sys

PATH = Path(__file__).resolve().parent.parent / "app" / "lib" / "gen" / "strings.g.dart"


def main() -> int:
    text = PATH.read_text(encoding="utf-8")
    # Phần tử cuối của enum AppLocale: "  xx(...);" -> "  xx(...)\n  ;"
    fixed, count = re.subn(r"^(  \w+\([^\n]*\));$(?=\n\n  const AppLocale\()", r"\1\n  ;", text, count=1, flags=re.M)
    if count:
        PATH.write_text(fixed, encoding="utf-8")
        print("Đã trả dấu ';' của enum AppLocale về dòng riêng.")
    else:
        print("Không cần sửa.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
