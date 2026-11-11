# Nguồn tệp Vietnamese.isl

- Lấy ngày 10/11/2026 từ `jrsoftware/issrc` (repo chính thức của Inno Setup), đường dẫn
  `Files/Languages/Unofficial/Vietnamese.isl`, git blob `8da80b2969aea761d557030cb5ed942e7fe2d2b0`.
- Lotus Share chỉ thêm BOM UTF-8 ở đầu tệp (Inno Setup 6 cần BOM để đọc tệp .isl là UTF-8, giống `Icelandic.isl`).
  Kiểm lại: `tail -c +4 Vietnamese.isl | git hash-object --stdin` phải ra blob ở trên.
- Giấy phép: theo giấy phép của Inno Setup (bản dịch do cộng đồng đóng góp).
