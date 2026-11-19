# BÀN GIAO - phiên lotus-share kế tiếp: ủy quyền mới (19/11/2026) + việc còn lại

- **Mã phiếu**: 20261119-03
- **Từ**: phiên lotus-share-fc, 19/11/2026
- **Đến**: phiên lotus-share kế tiếp (nên mở từ **20/11/2026**)
- **Trạng thái**: MỞ

## 0. Đọc trước

`AGENTS.md` -> `logs/STATE.md` -> `logs/LOCKS.md` -> phiếu này. Bối cảnh phiên trước (sự cố 26.11.1801, bản 26.11.1901,
Apple #80, TC2 #85): mục "Đã hoàn thành" 19/11 trong STATE. Môi trường máy: `/tmp` là ổ RAM ~6 GB dùng chung - chạy
`flutter`/`cargo` với `export TMPDIR=$HOME/.cache/lotus-tmp`; wrangler dùng `XDG_CONFIG_HOME=$HOME/.config/wrangler-tsudev`
và kiểm `wrangler whoami` trước deploy.

## 1. Ủy quyền chủ dự án cấp 19/11/2026 (nguyên văn ý: "đồng ý ủy quyền cho phép bạn có thêm quyền...")

| Ủy quyền | Phạm vi | Giới hạn KHÔNG đổi |
| --- | --- | --- |
| **A. Tự duyệt + gộp PR**, gồm xử lý GitGuardian | PR của repo này (kể cả Dependabot) khi mọi cổng bắt buộc xanh; đánh dấu sự cố GitGuardian là báo nhầm khi đã đọc nội dung và chứng minh không có giá trị bí mật | Không hạ/tắt cổng bảo mật (CodeQL, gitleaks, OSV, GitGuardian, ruleset) - mọi thay đổi cấu hình quét vẫn hỏi 👤 như 19/11. Bí mật THẬT bị lộ => thu hồi/xoay khóa + báo 👤, không đánh dấu báo nhầm. Không `--admin` vượt ruleset |
| **B. Tự mở trình duyệt nộp báo nhầm antivirus**, gồm tạo phiếu cho mọi dự án/repo đang cần nộp | Form web của hãng (Playwright), soạn email báo nhầm; phiếu vào `logs/handover/` của repo khác + nhắn phiên đang mở (ListAgents -> SendMessage) | Email liên hệ: `dev.nguyentrangtinhsu@gmail.com` (chủ dự án chọn 19/11). Google chặn đăng nhập trên trình duyệt điều khiển tự động => email gửi từ Gmail thì soạn sẵn link/nội dung để 👤 bấm gửi. Không nhập mật khẩu tài khoản nào của 👤. Không tải tệp lên dịch vụ ngoài kênh chính thức của hãng |
| **C. Tự làm các việc của `docs/vi/APPLE-IOS-MACOS.md`** | Mọi bước phía agent: giữ `apple.yml` xanh, tạo/cập nhật `.ipa` không ký, chuẩn bị hướng dẫn thử iPhone, khi có tài khoản: mục 4 bước 2-6 | Mục 2 (cài lên iPhone bằng Sideloadly) cần máy + **mật khẩu Apple ID của 👤 - agent MUST NOT nhận/lưu** (PRODUCT_POLICY 2.1); agent chuẩn bị tệp + hướng dẫn, 👤 cắm cáp và đăng nhập. Mục 4 bước 1 (tài khoản, chứng thư, khóa API) là việc 👤 |

**Không thuộc ủy quyền A (kỹ thuật, không phải quyền):** duyệt Environment `packages` của `tsudev-org/linux-packages`
(run `xuat-ban`) chỉ tài khoản **`nguyentrangtinhsu`** làm được (required reviewer); agent chạy `gh` bằng `tsudev-tsudev`
=> vẫn là việc 👤. Agent nhắc + đo `pkg.tsudev.com/catalog.json` sau khi duyệt.

## 2. Việc cho phiên kế tiếp (thứ tự ưu tiên)

1. **GitGuardian sự cố 40268788** ("Generic Password", `scripts/apple/nhap-khoa.sh` dòng 7, commit `02ad20e`): dòng chỉ là
   `"${APPLE_P12_PASSWORD:?thiếu APPLE_P12_PASSWORD}"` (kiểm biến môi trường có đặt chưa, KHÔNG có giá trị) - mã đã viết
   lại ở #80. Mở dashboard GitGuardian (đăng nhập do 👤 nếu trình duyệt hỏi), đánh dấu **False positive**, ghi lý do này.
   Ghi kết quả vào STATE.
2. **Báo nhầm antivirus 26.11.1901** (ủy quyền B): 4 tệp ở phiếu `20261118-02` mục 6. Đọc tên engine trong từng báo cáo
   VirusTotal (trình duyệt), nộp theo kênh mục 5 phiếu đó (SecureAge form: agent gửi; DeepInstinct / Arctic Wolf email:
   soạn link Gmail cho 👤). Cùng lúc quét lại 26.11.1801 (đã nộp 19/11) và ghi số engine trước/sau vào phiếu.
3. **Phiếu báo nhầm cho các repo khác** (ủy quyền B): liệt kê Release mới nhất của mọi repo `tsudev-org` (+
   `tsudev-tsudev/app-la-ban`) có job/bảng VirusTotal hoặc tệp `.exe/.msi/.zip` Windows; repo có tệp bị gắn cờ => viết
   phiếu `logs/handover/YYYYMMDD-AV_bao-nham-antivirus.md` vào repo đó (tệp, link báo cáo, kênh nộp theo danh bạ
   `docs.virustotal.com/docs/false-positive-contacts`, nội dung mẫu phiếu `20261118-02` mục 4) + nhắn phiên đang mở;
   repo không có phiên => phiếu + báo phiên điều phối (`projects-*`). Tổng hợp vào STATE.
4. **Dependabot #82 (cargo, 5 gói) + #83 (pub, 30 gói)** (ủy quyền A): xem từng gói, không gộp mù. Bắt buộc xanh:
   `frb_version_test`, `apple.yml` (Simulator + macOS chạy thử, không `LOTUS_SHARE_INIT_ERROR`), mọi cổng CI. Nâng phá
   vỡ thì tách PR. Gộp xong: build thử `gh workflow run release-lotus.yml --ref main` + tải artifact Windows/Linux mở thử
   nếu được, trước lần phát hành sau.
5. **Apple** (ủy quyền C):
   - Tải `.ipa` không ký mới nhất từ run `apple.yml` trên `main`, kiểm SHA-256, để ở chỗ 👤 lấy được (đường dẫn Windows
     của máy, KHÔNG lên Release) + gửi 👤 hướng dẫn mục 2 rút gọn; khi 👤 thử xong ghi `logs/thu-thiet-bi/`.
   - Lỗi iOS chưa thử thật: `ITSAppUsesNonExemptEncryption` (hồ sơ App Store mục 4) - nghiên cứu, ghi kết luận.
   - Thêm `en.lproj/InfoPlist.strings` (chuỗi xin quyền tiếng Anh) - app-store.md mục 3 ⚠.
   - Ảnh iPad 13" cho hồ sơ: thêm bước chụp Simulator iPad vào `apple.yml` (app hỗ trợ iPad).
   - Mục 4 (khi 👤 có Mac + Apple Developer, dự kiến đầu 2027): làm theo đúng thứ tự trong tài liệu.
6. 👤 duyệt `xuat-ban` linux-packages (mục 1) -> agent đo APT/RPM có `lotus-share 26.11.1901-1`.
7. Việc định kỳ còn trong STATE: VirusTotal quét lại, winget #478033 (khi gộp: PR cập nhật **26.11.1901**, không dùng
   26.11.1801), SignPath đo hằng tuần.

## 3. Ghi kết quả

Mỗi việc xong: cập nhật `logs/STATE.md` (Đã hoàn thành) + mục Kết quả dưới đây; phiếu repo khác ghi đường dẫn vào đây.

## 4. Kết quả

- 19/11/2026 tối - Việc 4: XONG (#88 gộp, #82/#83 đóng); build thử run 44464294694 xanh 12 job, AppImage mở thật OK.
- Việc 5: #89 (en/vi chuỗi xin quyền, kết luận `ITSAppUsesNonExemptEncryption` -> 👤 quyết). `.ipa` đã để ở `C:\Users\devng\Downloads\lotus-share-ios\` (SHA-256 khớp). Chưa: ảnh iPad.
- Việc 1 (GitGuardian): CHƯA - cần đăng nhập dashboard của 👤.
- Việc 2: CHƯA - đọc báo cáo VirusTotal bằng trình duyệt tự động bị chặn; dùng workflow `VT_API_KEY` (từ 20/11).
- Việc 3: chỉ lotus-share có bảng VirusTotal trong Release notes; repo khác không có dữ liệu => chưa có phiếu nào.
- 19/11/2026 khuya - Việc 2: engine đã đọc + quét lại (phiếu `20261118-02` mục 7; Cylance gỡ cờ). Nộp 1901 soạn sẵn,
  chờ 👤 gửi (Gmail DeepInstinct + form SecureAge - sandbox chặn `uav.secureage.com`). Quét lại tiếp từ 22/11.
- Dependabot #90/#91: XONG qua #93 (phần an toàn); major tách ra STATE.
- Việc 5 ảnh iPad 13": XONG (#94, 2064x2752).
- Còn 👤: GitGuardian 40268788, duyệt `xuat-ban`, quyết `ITSAppUsesNonExemptEncryption`, thử iPhone, gửi báo nhầm 1901.
