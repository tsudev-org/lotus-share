# PHIẾU YÊU CẦU TOÀN HỆ - Thống nhất tên gọi và số hiệu phiên bản

- **Mã phiếu**: 20261117-V1 (phiếu toàn hệ; bản sao đặt ở `logs/handover/` của từng repo)
- **Từ**: phiên tsudev-27 (repo tsudev), 17/11/2026, theo yêu cầu trực tiếp của chủ dự án
- **Đến**: phiên kế tiếp của MỌI repo trên máy (thứ tự ở mục 4)
- **Trạng thái**: MỞ (lotus-share: đã đọc + khảo sát 18/11, đổi khuôn ở bản phát hành kế tiếp) - mỗi repo ghi "Đã đọc" + PR + thẻ đầu tiên theo khuôn mới vào mục 6 của BẢN SAO trong repo mình

## 1. Vấn đề (đo 17/11/2026)

Tám kiểu đặt thẻ cùng tồn tại, khó so sánh/đối chiếu phiên bản giữa các sản phẩm:

| Repo | Thẻ git hiện tại | Lệch |
| --- | --- | --- |
| tsucontact, tsudisk, sound-db, tsudev-luyen-go-phim-releases | `v26.11.1601` | ĐÚNG khuôn |
| tsuswico | `v26.8.18.2` | khuôn cũ 4 phần |
| tsucwico | `tsudev-cwico-v26.11.10.2` | tiền tố tên cũ + dấu chấm thừa |
| tsudev-trafficmonitor | `V26.11.1202-vn` | `V` hoa + hậu tố `-vn` |
| tsufiles | `v2.4.1-vn.1` | SemVer của dự án gốc (Filee) |
| lotus-share | `v2.0.0-lotus.7` | SemVer của dự án gốc (LocalSend) |
| app-la-ban (tsudev-tsudev) | `v0.1.0-beta.17` | SemVer beta |
| tsudev (website) | `v2026.11.17.6` | thẻ deploy - dễ nhầm với thẻ app |

`tsudev-standards/docs/VERSIONING.md` (v2.0.0, đồng bộ ở `.standards/`) chỉ chuẩn hoá CHUỖI phiên bản app
`{YY}.{M}.{DD}{NN}`; chưa chuẩn hoá thẻ git, tiêu đề Release, tên tệp đa nền tảng, bản fork, thẻ deploy website.

## 2. Khuôn thống nhất (phương án chốt - đưa vào bộ quy ước TRƯỚC, mục 4 bước 1)

| Đối tượng | Khuôn | Ví dụ |
| --- | --- | --- |
| Phiên bản sản phẩm (app, tool, game, bản fork) | `YY.M.DDNN` - năm 2 số, tháng KHÔNG số 0 đầu, ngày 2 số, thứ tự trong ngày 2 số | `26.11.1704` |
| Thẻ git phát hành | `v` THƯỜNG + đúng phiên bản; không tiền tố tên, không hậu tố | `v26.11.1704` |
| Bản thử | thêm `-beta.N` / `-rc.N`, Release đánh dấu Pre-release | `v26.11.1801-beta.1` |
| Tiêu đề GitHub Release | `{Tên sản phẩm} {phiên bản}` | `Tsu Contact 26.11.1601` |
| Tệp phát hành | `{tên-gói}_{phiên bản}_{os}-{arch}[-{loại}].{ext}`; `os` ∈ windows, macos, linux, android | `tsucwico_26.11.1801_windows-x64-setup.exe` |
| Tệp kiểm | `SHA256SUMS.txt` (+ `SHA256SUMS.txt.sigstore.json`) - đúng tên này | |
| Phiên bản trong mã/manifest | = phiên bản sản phẩm (không `v`) | `26.11.1704` |
| Mã nội bộ tăng dần (Android `versionCode`, Windows FileVersion 4 phần) | Android: `YYMDDNN` dạng số (`2611 1704` → `26111704`); Windows: `YY.M.DDNN.0` | |
| Gói Linux (deb/rpm) | `{phiên bản}-{revision}` do kho đặt | `26.11.1704-1` |
| Bản fork của dự án khác | phiên bản sản phẩm theo khuôn trên; phiên bản gốc ghi ở Release notes + màn hình Giới thiệu ("Dựa trên LocalSend 1.18.2"), KHÔNG nhét vào chuỗi phiên bản | `v26.11.2001` |
| Bộ quy ước `tsudev-standards`, thư viện/package npm | SemVer `MAJOR.MINOR.PATCH` | `v3.7.0` |
| Website | không có phiên bản sản phẩm; thẻ deploy `deploy-YYYY.MM.DD.N` (đổi từ `vYYYY.MM.DD.N` để không lẫn với thẻ app) | `deploy-2026.11.17.6` |

## 3. Ràng buộc BẤT KHẢ XÂM PHẠM

1. **Thẻ đã phát hành KHÔNG đổi tên, KHÔNG xoá** (ruleset "Tag phát hành bất biến"; updater + winget + Scoop + kho gói
   trỏ vào chúng). Khuôn mới chỉ áp cho bản phát hành KẾ TIẾP.
2. **Trước khi đổi khuôn ở một app có trình cập nhật**: đọc mã so sánh phiên bản của updater ĐÃ CÀI ngoài máy người
   dùng và chứng minh bằng test rằng bản mới được coi là MỚI HƠN bản cũ (vd SemVer `26.11.2001` > `2.4.1` đúng; regex
   nhãn của updater có nhận `v26.11.2001` không). Không chứng minh được ⇒ phát hành bản cầu nối hoặc giữ khuôn cũ, ghi lý do.
3. Đồng bộ CÙNG lúc các nơi đọc nhãn/tên tệp: `packaging/package.json` (`release.tagRegex`, `assets.*.file`), manifest
   Scoop (`checkver`, `autoupdate`), cask Homebrew (`livecheck`, `url`), `linux-packages/products.json`, winget, khối
   "Cài bằng lệnh", trang tải về, `tools/doi-chieu-kenh.mjs`. Thiếu một nơi ⇒ kênh đó đứng ở bản cũ im lặng.
4. Không tạo repo/thẻ dưới tên cũ (`~/.claude/CLAUDE.md`).

## 4. Thứ tự thực hiện (mỗi bước một phiên/PR)

1. **tsudev-standards**: VERSIONING.md v3 (mục 2 phiếu này) + cổng kiểm thẻ (script đọc `git tag` mới nhất khớp khuôn)
   → phát hành v3.7.0 → các repo `sync-standards.sh`.
2. **tsucwico**: bản kế tiếp `v26.11.DDNN` (updater đọc `latest.json` theo URL `releases/latest` - không phụ thuộc thẻ;
   `tagRegex` đã nhận cả hai). Tên tệp bỏ tiền tố `tsudev-cwico_` → `tsucwico_` (Scoop/winget đổi cùng PR).
3. **tsuswico**: bản kế tiếp `v26.11.DDNN` - kiểm `src/Tsudev.Audit.Core/Updates/ReleaseParsing.cs` nhận và so đúng với
   `v26.8.18.2` của bản đã cài (việc TEN-2 trong STATE). Bộ cài Inno `VersionInfoVersion` = `YY.M.DDNN.0`.
4. **tsudev-trafficmonitor**: bỏ `V` hoa và `-vn` → `v26.11.DDNN`; kiểm updater (`version_utf8.info`, `ForkConfig.h`).
5. **tsufiles** (fork Filee): chuyển `2.4.x-vn.N` → `26.M.DDNN` CHỈ sau khi chứng minh updater 2.4.0/2.4.1 so SemVer
   đúng; giữ tên gói `tsudev-files` (ADR-0003); ghi "Dựa trên Filee x.y.z".
6. **lotus-share** (fork LocalSend): như tsufiles; kiểm updater + Android `versionCode` tăng; Homebrew `livecheck` regex.
7. **app-la-ban**: `0.1.0-beta.N` → `26.M.DDNN` (Android `versionCode` = `YYMDDNN`, phải lớn hơn mã hiện tại).
8. **tsudev** (website): `scripts/release-tag.js` đổi thẻ deploy sang `deploy-YYYY.MM.DD.N`; CHANGELOG mục "Bản triển
   khai" đổi tiêu đề theo; thẻ cũ giữ nguyên. Danh bạ /apps hiện phiên bản theo khuôn chung (lấy từ catalog).
9. **Kho gói** (linux-packages, scoop-bucket, homebrew-tap): cập nhật regex/khuôn tệp theo từng app ở bước 2-7;
   `tools/doi-chieu-kenh.mjs` thêm kiểm "thẻ mới nhất khớp khuôn".
10. **tsudisk, sound-db, game TsuGameLabs**: đã đúng chuỗi phiên bản - chỉ đối chiếu tiêu đề Release + tên tệp
    `{tên-gói}_{ver}_{os}-{arch}` và ghi "Đã đọc".
11. **Repo ngoài hệ tsudev** (ubnd*, quansu-xanuicam, mieubathuong, b4djl1h-cmdb, wedding-sumy): website/hệ thống nội bộ
    ⇒ không phiên bản sản phẩm; nếu có thẻ phát hành thì theo khuôn mục 2. Phiên của repo đó tự quyết, ghi lý do.

## 5. Nghiệm thu

- `git tag --sort=-creatordate | head -1` của mỗi repo app khớp `^v\d{2}\.\d{1,2}\.\d{4}(-(beta|rc)\.\d+)?$`.
- Tiêu đề Release, tên tệp, phiên bản trong app (màn hình Giới thiệu / `--version`) và trên tsudev.com/apps TRÙNG nhau.
- Bản đã cài ngoài máy người dùng nhận được bản mới (thử updater thật hoặc test so sánh phiên bản).

## 6. Kết quả xử lý (mỗi repo điền vào bản sao của mình)

- 18/11/2026 - lotus-share (phiên lotus-share-5e): **Đã đọc**. Khảo sát updater + kênh (chưa đổi khuôn - thứ tự mục 4
  đặt lotus-share sau tsufiles; đổi cùng bản phát hành kế tiếp, build thử + phát hành thật mới chứng minh được):
  1. Hộp thoại bắt buộc cập nhật trong app (bản 2.0.0+65 đã cài) so **số build nguyên** đọc từ `phien-ban.json`
     (`app/lib/util/update_check.dart`, `update_dialog.dart`) - không đọc chuỗi phiên bản ⇒ `26.11.DDNN+YYMDDNN`
     (vd `26111901`) > 65: ĐÚNG là mới hơn. Android `versionCode` = cùng số build ⇒ tăng (65 → 2611xxxx), dưới trần
     2 100 000 000. Windows FileVersion `26.11.DDNN.0` (mỗi phần ≤ 65535). macOS CFBundleVersion = số build.
  2. **Bẫy AppImage**: AppImage đã cài nhúng `gh-releases-zsync|tsudev-org|lotus-share|latest|lotus-share-*-linux-x86-64.AppImage.zsync`
     (và `-linux-arm-64`). Đổi tên tệp sang khuôn `lotus-share_{ver}_linux-x64.AppImage` ⇒ AppImageUpdate của máy đã
     cài IM LẶNG không thấy bản mới. Phương án: AppImage + `.zsync` GIỮ tên cũ `lotus-share-{ver}-linux-x86-64.AppImage`
     (ngoại lệ ghi trong `.standards-version`/AGENTS B.4), hoặc phát hành kèm bản sao tên cũ ít nhất 1 năm.
  3. Kênh phải đổi CÙNG PR: `packaging/package.json` (`tagRegex` thêm nhánh `^v(?<version>\d{2}\.\d{1,2}\.\d{4})$`,
     `assets.*.file`; `dung_kho.py` mặc định revision `1` - đúng), Scoop `checkver.regex` + `autoupdate.url`
     (đang `v((?<short>[\d.]+)-lotus\.\d+)`), Homebrew `livecheck regex(/v?(\d+(?:\.\d+)+-lotus\.\d+)/)`, winget,
     `release-lotus.yml` (bước `prepare` kiểm nhãn `v$version-lotus.N`), `website/public/phien-ban.json` (`moiNhat`).
     So sánh phiên bản ở kênh: dpkg/rpm/Scoop/winget đều coi `26.11.DDNN` > `2.0.0` (số đầu 26 > 2).
  4. Ghi "Dựa trên LocalSend 1.18.2" ở Release notes + Giới thiệu (đã có ở Giấy phép).
  Việc đưa vào `logs/STATE.md` hàng đợi: "Phát hành kế tiếp theo khuôn V1".

