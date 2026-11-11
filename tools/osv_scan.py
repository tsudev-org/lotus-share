#!/usr/bin/env python3
"""lotus-share: soát lỗ hổng đã công bố của MỌI phụ thuộc (Rust + Dart) qua cơ sở dữ liệu OSV.dev.

Đọc Cargo.lock và pubspec.lock ở gốc repo, gửi danh sách <tên gói, phiên bản> (dữ liệu công khai, không gửi mã
nguồn hay thông tin máy) tới https://api.osv.dev, rồi so với danh sách chấp nhận rủi ro có ghi chép bên dưới.
Chỉ dùng thư viện chuẩn Python, không cần cài binary bên thứ ba.

Chạy từ gốc repo:  python3 -I tools/osv_scan.py
Mã thoát khác 0 = có lỗ hổng CHƯA được chấp nhận (CI chặn merge).
"""
from __future__ import annotations

import datetime as dt
import json
import re
import sys
import tomllib
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
API = "https://api.osv.dev/v1"
UA = {"Content-Type": "application/json", "User-Agent": "lotus-share-osv-scan"}

# Rủi ro đã chấp nhận: MỖI dòng phải có lý do và hạn xem lại (DD/MM/YYYY). Hết hạn => quét trượt lại.
ACCEPTED: dict[str, tuple[str, str]] = {
    "RUSTSEC-2023-0071": (
        "rsa 0.9 (Marvin) chưa có bản vá trong nhánh 0.9. Lõi chỉ dùng rsa để SINH khóa và XÁC MINH chữ ký PSS "
        "bằng khóa công khai; không giải mã/ký bằng khóa riêng qua crate này (TLS dùng ring) nên không lộ kênh "
        "thời gian mà tấn công Marvin cần.",
        "31/03/2027",
    ),
    "RUSTSEC-2026-0387": (
        "crypto-bigint 0.5 chỉ nằm trong nhánh webrtc -> dtls -> p256; WebRTC đang TẮT (webRTCEnabled = false).",
        "31/03/2027",
    ),
    "RUSTSEC-2025-0141": ("bincode 1.x ngừng bảo trì (cảnh báo thông tin, không phải lỗ hổng); đến qua webrtc.", "31/03/2027"),
    "RUSTSEC-2026-0441": ("pin-utils ngừng bảo trì (cảnh báo thông tin, không phải lỗ hổng).", "31/03/2027"),
}


def packages() -> list[tuple[str, str, str]]:
    found: list[tuple[str, str, str]] = []
    lock = tomllib.loads((ROOT / "Cargo.lock").read_text(encoding="utf-8"))
    for pkg in lock.get("package", []):
        if "registry" in pkg.get("source", ""):
            found.append(("crates.io", pkg["name"], pkg["version"]))
    current = None
    for line in (ROOT / "pubspec.lock").read_text(encoding="utf-8").splitlines():
        if m := re.match(r"^  (\S+):$", line):
            current = m.group(1)
        elif (m := re.match(r'^    version: "(.+)"$', line)) and current:
            found.append(("Pub", current, m.group(1)))
    return found


def post(path: str, body: dict) -> dict:
    req = urllib.request.Request(f"{API}/{path}", json.dumps(body).encode(), UA)
    with urllib.request.urlopen(req, timeout=60) as res:
        return json.load(res)


def main() -> int:
    pkgs = packages()
    hits: list[tuple[tuple[str, str, str], str]] = []
    for i in range(0, len(pkgs), 500):
        chunk = pkgs[i : i + 500]
        res = post("querybatch", {"queries": [{"package": {"ecosystem": e, "name": n}, "version": v} for e, n, v in chunk]})
        for pkg, result in zip(chunk, res["results"]):
            hits.extend((pkg, vuln["id"]) for vuln in result.get("vulns", []))

    today = dt.date.today()
    failed = 0
    print(f"Đã soát {len(pkgs)} gói (Cargo.lock + pubspec.lock).")
    for (eco, name, ver), vid in hits:
        accepted = ACCEPTED.get(vid)
        if accepted:
            until = dt.datetime.strptime(accepted[1], "%d/%m/%Y").date()
            if until >= today:
                print(f"  CHẤP NHẬN {vid} {eco}/{name}@{ver} (xem lại trước {accepted[1]}): {accepted[0]}")
                continue
            print(f"  HẾT HẠN chấp nhận {vid} {eco}/{name}@{ver} - đánh giá lại")
        else:
            print(f"  LỖ HỔNG {vid} {eco}/{name}@{ver} - https://osv.dev/vulnerability/{vid}")
        failed += 1
    if failed:
        print(f"TRƯỢT - {failed} lỗ hổng chưa xử lý. Nâng gói (cargo update -p <tên> / pub upgrade) hoặc ghi chấp nhận rủi ro.")
        return 1
    print("ĐẠT - không có lỗ hổng chưa xử lý.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
