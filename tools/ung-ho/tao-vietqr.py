#!/usr/bin/env python3
"""Lotus Share (chép nguyên từ tsudev-files, phiếu 20261112-01): sinh mã VietQR (SVG vector) cho trang Ủng hộ từ mã BIN ngân hàng + số tài khoản, có kiểm chéo.

Không đăng ảnh chụp mã QR của ứng dụng ngân hàng: ảnh chụp mờ khi phóng to, nặng, và không ai kiểm được nó có thật sự
chuyển tiền tới đúng tài khoản ghi bên cạnh hay không. Script này dựng chuỗi VietQR (chuẩn EMVCo/NAPAS) từ dữ liệu, sinh
SVG, đọc lại mã vừa sinh để chắc chắn khớp, và (nếu đưa ảnh của ngân hàng) đối chiếu từng byte với mã của ngân hàng.

  python3 -m venv /tmp/qr && /tmp/qr/bin/pip install -r tools/ung-ho/requirements.txt
  /tmp/qr/bin/python -I tools/ung-ho/tao-vietqr.py --bin 970441 --tai-khoan 056485506 \\
      --ra website/public/ung-ho/vietqr-vib.svg [--anh-ngan-hang <ảnh QR tải từ app ngân hàng>]

In ra "payload" và "sha256" để chép vào website/src/data/ung-ho.json (build website kiểm lại cả hai).
"""
from __future__ import annotations

import argparse
import hashlib
import io
import re
import sys
from pathlib import Path

NAPAS_GUID = "A000000727"
SERVICE_ACCOUNT = "QRIBFTTA"  # chuyển nhanh NAPAS 247 tới số tài khoản


def tlv(tag: str, value: str) -> str:
    if len(value) > 99:
        raise ValueError(f"trường {tag} quá dài")
    return f"{tag}{len(value):02d}{value}"


def crc16(data: str) -> str:
    crc = 0xFFFF
    for byte in data.encode("ascii"):
        crc ^= byte << 8
        for _ in range(8):
            crc = ((crc << 1) ^ 0x1021) & 0xFFFF if crc & 0x8000 else (crc << 1) & 0xFFFF
    return f"{crc:04X}"


def payload(bin_code: str, account: str) -> str:
    if not re.fullmatch(r"\d{6}", bin_code):
        raise ValueError("mã BIN ngân hàng gồm đúng 6 chữ số")
    if not re.fullmatch(r"[0-9A-Za-z]{1,19}", account):
        raise ValueError("số tài khoản chỉ gồm chữ/số, tối đa 19 ký tự")
    beneficiary = tlv("00", bin_code) + tlv("01", account)
    merchant = tlv("00", NAPAS_GUID) + tlv("01", beneficiary) + tlv("02", SERVICE_ACCOUNT)
    body = tlv("00", "01") + tlv("01", "11") + tlv("38", merchant) + tlv("53", "704") + tlv("58", "VN") + "6304"
    return body + crc16(body)


def decode(png_or_jpg: bytes) -> str:
    import cv2
    import numpy as np

    img = cv2.imdecode(np.frombuffer(png_or_jpg, np.uint8), cv2.IMREAD_COLOR)
    text, _, _ = cv2.QRCodeDetector().detectAndDecode(img)
    if not text:
        raise ValueError("không đọc được mã QR trong ảnh")
    return text


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--bin", required=True, help="mã BIN NAPAS của ngân hàng (VIB: 970441)")
    ap.add_argument("--tai-khoan", required=True)
    ap.add_argument("--ra", required=True, type=Path, help="tệp SVG đầu ra")
    ap.add_argument("--anh-ngan-hang", type=Path, help="ảnh QR từ ứng dụng ngân hàng để đối chiếu")
    a = ap.parse_args()

    import segno

    data = payload(a.bin, a.tai_khoan)
    if a.anh_ngan_hang:
        bank = decode(a.anh_ngan_hang.read_bytes())
        if bank != data:
            print(f"KHÔNG KHỚP mã của ngân hàng:\n  ngân hàng: {bank}\n  dựng ra:   {data}", file=sys.stderr)
            return 1
        print("Khớp từng byte với mã QR của ngân hàng.")

    qr = segno.make(data, error="m", micro=False)
    # Đọc lại chính mã vừa sinh (qua PNG) - chống lỗi thư viện/tham số làm mã sai mà mắt không thấy.
    png = io.BytesIO()
    qr.save(png, kind="png", scale=8, border=4)
    if decode(png.getvalue()) != data:
        print("Mã sinh ra đọc lại không khớp dữ liệu.", file=sys.stderr)
        return 1

    a.ra.parent.mkdir(parents=True, exist_ok=True)
    svg = io.BytesIO()
    qr.save(svg, kind="svg", scale=1, border=4, dark="#000", light="#fff", xmldecl=False, svgns=True,
            title=f"VietQR {a.bin} {a.tai_khoan}", svgclass=None, lineclass=None, omitsize=True)
    a.ra.write_bytes(svg.getvalue())
    print(f"payload: {data}")
    print(f"sha256:  {hashlib.sha256(a.ra.read_bytes()).hexdigest()}")
    print(f"tệp:     {a.ra} ({a.ra.stat().st_size} byte, phiên bản QR {qr.version}, mức sửa lỗi {qr.error})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
