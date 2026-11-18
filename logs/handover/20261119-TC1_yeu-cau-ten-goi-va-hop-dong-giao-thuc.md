# PHIẾU YÊU CẦU - TC1 (lotus-share): hợp đồng giao thức Lotus v2 cho TsuFiles + tên gọi cũ còn hiển thị

- **Mã phiếu**: 20261119-TC1 (phiếu con; phiếu tổng `~/projects/logs/handover/20261119-TC1_ten-goi-rieng-toan-he.md`)
- **Từ**: phiên tsufiles-3c, 19/11/2026, theo yêu cầu trực tiếp của chủ dự án
- **Đến**: phiên lotus-share kế tiếp (đang có phiên `lotus-share-9c` - phiên tsufiles KHÔNG sửa hộ repo này)
- **Trạng thái**: ĐÃ TRẢ LỜI 19/11/2026 (phiên lotus-share-9c) - xem mục 6

## 1. Vì sao có phiếu này

Yêu cầu 16/11/2026 của chủ dự án "bản cho iPhone 8 tìm thấy, gửi và nhận với máy tính và thiết bị khác" đã được giao
cho phiên tsufiles. Phiên đó (tsufiles#105, #106 - đã gộp 18/11, CHƯA phát hành) cho TsuFiles nói **giao thức LocalSend
gốc** (TCP/UDP 53317, `224.0.0.167`, `/api/localsend/v2/`) và hướng người dùng cài app LocalSend. Hệ quả: TsuFiles và
Lotus Share 2.0 (53420 / `224.0.0.168` / `/api/lotus/v2/`) **không thấy nhau**, và tsufiles quảng bá sản phẩm bên thứ ba
thay vì Lotus Share. Chủ dự án xác nhận có thể đã giao nhầm. Hướng sửa: TsuFiles nói giao thức **Lotus v2**, bỏ hẳn
LocalSend - cần lotus-share chốt hợp đồng ở mục 2 TRƯỚC khi tsufiles code (phiếu con tsufiles chờ phiếu này).

## 2. Việc A - Hợp đồng giao thức Lotus v2 (cho client ngoài app Lotus Share trong hệ)

1. Viết `docs/GIAO-THUC-LOTUS-V2.md` từ mã thật (`packages/core/src/`, `packages/localsend_isolates/lib/api_route_builder.dart`),
   đủ để một client khác cài đặt mà không đọc mã Rust:
   - Gói multicast/broadcast: các trường JSON (bắt buộc/tùy chọn, kiểu, giá trị `deviceType`, `version`, `protocol`,
     `port`, `fingerprint`, `announce`), chuỗi gửi (100 ms, 500 ms, 2 s), gói broadcast có hướng, IPv6 `ff12::1075:5ea0`.
   - `POST register`, `GET info`, `POST prepare-upload` (cả `?pin=`), `POST upload`, `POST cancel`, `prepare-download`
     nếu có; mã trạng thái (204/401/403/409/429…) và nghĩa.
   - TLS: chứng thư tự ký, **vân tay tính thế nào** (SHA-256 của DER?), client phải ghim ra sao (`tests/v2_tls_pinning.rs`);
     chế độ HTTP còn được nhận không.
   - Mã hóa đầu-cuối mà `scripts/he-sinh-thai/metadata.json` của tsudev quảng bá ("end-to-end encrypted"): có lớp nào
     ngoài TLS không, client ngoài phải làm gì.
2. Cam kết ổn định: số phiên bản giao thức; đổi phá vỡ thì tăng `v3` và báo phiếu cho tsufiles.
3. Bộ mẫu kiểm (JSON mẫu của từng thông điệp + một trao đổi đầy đủ) đặt ở `docs/giao-thuc-mau/` để CI tsufiles đối
   chiếu - nếu lõi Rust có test sinh được mẫu thì sinh từ test, không viết tay.
4. Xác nhận Lotus Share chấp nhận client khác trong hệ (TsuFiles: `deviceModel` "TsuFiles", `deviceType` desktop/
   headless) - có danh sách trắng / bắt tay nào chặn không. Máy nhận Lotus Share vẫn hỏi người dùng như với thiết bị
   Lotus khác.

## 3. Việc B - Cùng máy không tranh cổng (quan trọng: người dùng sẽ cài cả hai)

- TsuFiles sẽ KHÔNG chiếm cổng TCP 53420 (máy chủ của TsuFiles dùng cổng riêng, khai trong trường `port` của gói), chỉ
  nghe UDP 53420 để tìm máy. Điều này chỉ chạy được khi **cả hai** bên mở socket UDP có `SO_REUSEADDR` (Linux/macOS thêm
  `SO_REUSEPORT`); nếu lõi Rust mở độc quyền thì ứng dụng mở sau không nghe được multicast. Việc: kiểm
  `packages/core/src/multicast/` và ghi kết quả vào đặc tả; nếu đang độc quyền, đề xuất sửa trong phiếu trả lời (không
  phải tsufiles sửa hộ).
- Công cụ chẩn đoán `support/scripts/chan-doan-mang.ps1` mục 1 ("tiến trình nào giữ TCP/UDP 53420"): nhận TsuFiles là
  ứng dụng cùng hệ hợp lệ trên UDP, không báo là "ứng dụng khác tranh cổng".
- Bài học cũ của chính repo này (KHAM-PHA-THIET-BI.md nguyên nhân 5 và 9 - dùng chung cổng/cấu hình với LocalSend):
  TsuFiles đang lặp lại đúng lỗi đó ở cổng 53317; phiếu con tsufiles rút khỏi 53317.

## 4. Việc C - Tên gọi cũ người dùng thấy được (đo bằng `ra_ten_cu.py`, 19/11/2026)

`python3 -I ~/projects/logs/tools/ra_ten_cu.py --dong lotus-share` (chạy lại trước và sau khi sửa). Các chỗ hiển thị
cho người dùng:

| Chỗ | Hiện tại | Ai thấy |
| --- | --- | --- |
| `app/windows/runner/Runner.rc:97` `LegalCopyright` | `Copyright (C) 2026 tsudev. LocalSend (C) 2022-2026 Tien Do Nam. Apache-2.0` | Windows > Thuộc tính tệp > Chi tiết |
| `app/macos/Runner/Configs/AppInfo.xcconfig:14` `PRODUCT_COPYRIGHT` | như trên | macOS > Giới thiệu, Finder > Lấy thông tin |
| `app/ios/Runner/Info.plist:16` `CFBundleName` | `localsend_app` | iOS Cài đặt/Spotlight nếu thiếu `CFBundleDisplayName` - kiểm |
| `app/web/index.html:26,32` | `<title>localsend_app</title>`, `apple-mobile-web-app-title` | tab trình duyệt / thêm vào màn hình chính |
| `README.md:13` | "Lotus Share started as a fork of LocalSend 1.18.2" | GitHub |
| `docs/vi/PHAT-HANH.md`, `KHAM-PHA-THIET-BI.md`, `KIEN-TRUC-BAO-MAT.md`, `docs/KIEN-TRUC-KY-THUAT.md` | nhắc LocalSend khi giải thích định danh/lịch sử | người đóng góp |

Đề xuất (phiên lotus-share quyết, ghi lý do từng dòng còn lại):
- `LegalCopyright`/`PRODUCT_COPYRIGHT`: `Copyright (C) 2026 tsudev. Apache-2.0 - xem LICENSE` (thông báo của tác giả gốc
  vẫn nằm trong LICENSE/NOTICE đi kèm bản cài - đủ điều kiện giấy phép).
- `CFBundleName`, title web: `Lotus Share`.
- README: bỏ câu fork; NOTICE giữ nguyên (đúng pháp lý, chính repo đã ghi "original copyright notice is retained in
  LICENSE as the license requires").
- Tài liệu nội bộ: gọi "mã gốc"/"bản 1.x" thay tên sản phẩm; riêng hồ sơ đã NỘP cho SignPath (`HUONG-DAN-KY-MA.md`) là
  bản ghi sự thật đã nộp - giữ, chuyển sang `logs/` nếu muốn.
- Định danh nội bộ `localsend_app`, `localsend_isolates`, crate `localsend`, namespace Kotlin `org.localsend.localsend_app`:
  AGENTS.md đã ghi lý do giữ (người dùng không thấy). Nếu chủ dự án muốn đổi: một PR riêng, build thử đủ 6 nền tảng; KHÔNG
  đổi `applicationId`/bundle id đã phát hành.

## 5. KHÔNG làm

- Không xóa thông báo bản quyền Tien Do Nam trong `LICENSE`/`NOTICE` (Apache-2.0 mục 4 - xóa là vi phạm giấy phép).
- Không đổi định danh cài đặt đã phát hành (`com.tsudev.lotusshare`, AppId Inno, thư mục cấu hình).

## 6. Trả lời

Ghi vào mục này: số PR đặc tả + đường dẫn `docs/GIAO-THUC-LOTUS-V2.md`, kết quả kiểm `SO_REUSEADDR`, bảng `ra_ten_cu.py`
trước/sau. Rồi nhắn phiên tsufiles (ListAgents → SendMessage) hoặc ghi vào `tsufiles/logs/handover/20261119-TC1_*`
mục "Phụ thuộc" để phiên tsufiles bắt đầu nối giao thức.

### 6.1. Trả lời của lotus-share (19/11/2026, phiên lotus-share-9c)

**A - Hợp đồng giao thức**: `docs/GIAO-THUC-LOTUS-V2.md` (viết từ `packages/core/src/` - cả khám phá lẫn máy chủ HTTP của
app đều chạy trong lõi Rust) + mẫu `docs/giao-thuc-mau/` (multicast, register req/res, info, prepare-upload req/res,
lỗi). Mẫu sinh-kiểm bằng test `packages/core/tests/protocol_samples.rs`: mỗi mẫu phải đọc được bằng DTO thật VÀ ghi lại y
hệt => mẫu không lệch mã. Điểm chính cho tsufiles:
- Phiên bản `2.2`, `/api/lotus/v2/`; cam kết mục 1 (chỉ thêm trường tùy chọn; phá vỡ => v3 + phiếu trước phát hành).
- **mTLS bắt buộc**: máy chủ Lotus đòi chứng thư client (tự ký, còn hạn, chữ ký hợp lệ - không cần CA). Vân tay =
  SHA-256 của DER, hex HOA 64 ký tự; `fingerprint` trong `register` phải khớp chứng thư client, lệch => bị bỏ qua (vẫn 200).
  Client phải ghim vân tay máy chủ. Không có lớp mã hóa nào ngoài TLS ("đầu-cuối" = TLS trực tiếp giữa hai máy).
- Trả lời gói chào bằng HTTP `POST register` tới `IP nguồn:port trong gói` (không trả bằng multicast). Quét mạng con của
  Lotus chỉ thử cổng 53420 => TsuFiles (cổng máy chủ riêng) được thấy nhờ GỬI gói chào (mục 3.3 đặc tả).
- Không danh sách trắng: `deviceModel: "TsuFiles"` hiện bình thường, bên nhận Lotus vẫn hỏi người dùng.

**B - Cùng máy**: lõi mở UDP với `SO_REUSEADDR` (+ `SO_REUSEPORT` Linux/macOS), multicast loopback bật. **Đo thật**:
`lotus-share-cli` đang chạy + tiến trình thứ hai bind UDP 53420 (`SO_REUSEADDR`+`SO_REUSEPORT`) => bind được, nhận gói chào
của CLI. Không cần sửa lõi. Yêu cầu phía TsuFiles: đặt hai cờ đó TRƯỚC bind, không dùng `SO_EXCLUSIVEADDRUSE`, không chiếm
TCP 53420. Công cụ chẩn đoán đã nhận TsuFiles: `chan-doan-mang.ps1` (Info "ứng dụng cùng hệ") + `chan-doan-mang.sh` (đo 3
trường hợp: chỉ CLI / CLI + tiến trình lạ => LỖI / CLI + `tsufiles` => ĐẠT); TCP 53420 bị tiến trình khác giữ vẫn báo lỗi.

**C - Tên cũ hiển thị** (`ra_ten_cu.py --dong lotus-share`: trước `website 4, tai-lieu 51, chu-giao-dien-dich 4` => sau
`website 2, tai-lieu 50, chu-giao-dien-dich 4`):

| Chỗ | Xử lý |
| --- | --- |
| `Runner.rc` LegalCopyright, `AppInfo.xcconfig` PRODUCT_COPYRIGHT, `cli/build.rs` | `Copyright (C) 2026 tsudev. Portions (C) 2022-2026 Tien Do Nam. Apache-2.0` - bỏ TÊN SẢN PHẨM, GIỮ tên tác giả (đây là thông báo bản quyền có sẵn trong mã nguồn - Apache-2.0 4(c); bỏ hẳn như đề xuất là rủi ro pháp lý) |
| iOS `CFBundleName` | `Lotus Share` (CFBundleDisplayName vốn đã đúng) |
| `app/web/index.html` title + apple title, `app/web/manifest.json` name/short_name/description | `Lotus Share` |
| `README.md:13` | Bỏ câu "fork of LocalSend"; ghi "built on Apache-2.0 open-source code; original copyright notices in LICENSE and NOTICE" |
| `website/src/lib/ung-ho.ts:45` | GIỮ - regex CHẶN liên kết ủng hộ bên thứ ba (chức năng an toàn) |
| `website/wrangler.jsonc:4` | GIỮ - chú thích khung dùng chung với trafficmonitor, không phải tên cũ |
| `tools/check_i18n_vi.py` | GIỮ - cổng chặn URL localsend.org viết cứng |
| Tài liệu (`KIEN-TRUC-*`, `PHAT-HANH`, `KHAM-PHA-THIET-BI`, vendor README, CMake `rust_lib_localsend_app`) | GIỮ - lịch sử/định danh nội bộ (AGENTS B.4); `HUONG-DAN-KY-MA.md` là hồ sơ SignPath ĐÃ NỘP, giữ nguyên văn |
| Định danh nội bộ `localsend_app`, crate `localsend`, Kotlin `org.localsend.localsend_app` | GIỮ (AGENTS B.4) - đổi cần PR riêng + build thử mọi nền tảng; chưa có yêu cầu |

LICENSE/NOTICE không đổi. Thay đổi vào bản phát hành kế tiếp của Lotus Share (giao thức KHÔNG đổi - bản 26.11.1801 đã
nói đúng hợp đồng này).

