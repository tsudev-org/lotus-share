# PHIẾU BÀN GIAO - Kết phiên "Lotus Share độc lập", phát hành 2.0.0-lotus.7

- **Mã phiếu**: 20261113-01
- **Từ**: phiên lotus-share-9e (12-13/11/2026) - **Đến**: phiên kế tiếp của repo `tsudev-org/lotus-share`
- **Trạng thái**: MỞ (việc ở mục 2)

## 1. Đã làm

- PR #38: máy Linux không hiện trên máy tính (bỏ quét mạng con khi đã có thiết bị trả lời trong 1 giây - nay luôn quét);
  Windows dùng chung `%APPDATA%\LocalSend\settings.json` với LocalSend nên mang tên "Strategic Tomato" (nay tệp riêng
  `%APPDATA%\Lotus Share\`); tên ngẫu nhiên tiếng Anh tự đổi sang tiếng Việt; nút sửa tường lửa trên Linux;
  `support/scripts/chan-doan-mang.sh`.
- PR #39: sản phẩm độc lập - giao thức riêng (cổng 53420, `224.0.0.168` / `ff12::1075:5ea0`, `/api/lotus/v2`), di trú
  cấu hình v5, gỡ workflow/tài liệu/tài nguyên/liên kết LocalSend và remote `upstream`, vendor 2 gói Dart, trang Giới thiệu
  + Giấy phép, bắt buộc cập nhật (`website/public/phien-ban.json`, `docs/vi/CAP-NHAT-BAT-BUOC.md`), 2.0.0+65.
- PR #42: hằng `DEFAULT_MULTICAST_GROUP` của lõi Rust còn `224.0.0.167` -> CLI nghe sai nhóm (ứng dụng dùng hằng Dart
  nên đúng). Test `packages/core/tests/protocol_constants.rs` đối chiếu Dart/Rust. Ghi chú phát hành bỏ "dựa trên LocalSend".
- Phát hành `v2.0.0-lotus.7` (Latest). `v2.0.0-lotus.6`: nhãn bất biến còn lại nhưng KHÔNG có bản phát hành (đã hủy vì
  lỗi CLI). Kiểm tệp thật + website + Scoop/Homebrew/APT: `logs/STATE.md` mục Đã hoàn thành.
- Phiếu cả hệ `~/projects/logs/handover/20261112-04_yeu-cau-bat-buoc-cap-nhat-he-sinh-thai.md`: tsudev không áp dụng,
  tsudev-files nhận (làm ở 2.4.1).

## 2. Bước tiếp theo CỤ THỂ

1. Thử thật lotus.7 trên thiết bị (STATE hàng đợi): Windows + Android + laptop Linux cùng Wi-Fi, tất cả 2.0.
2. PR riêng đổi tên nội bộ (`localsend_app`, `localsend_isolates`, crate `localsend`, Kotlin `org.localsend.localsend_app`,
   kênh nền tảng, icon khay). Cần `flutter_rust_bridge_codegen` đúng bản ghim để sinh lại mã, build thử
   `release-lotus.yml` (workflow_dispatch) đủ nền tảng.
3. CLI kiểm `phien-ban.json` như ứng dụng.
4. Bản phát hành kế tiếp: build 66, nhãn `v2.0.x-lotus.8`; sau Publish sửa `phien-ban.json` `moiNhat` rồi deploy website.

## 3. Cảnh báo

- macOS arm64 trên GitHub hay bị hủy vì thiếu máy chạy ("job was not acquired"). Job phát hành vẫn tạo bản nháp KHÔNG có
  DMG: kiểm đủ 22 tệp trước khi Publish; thiếu thì xóa bản nháp rồi `gh run rerun <id> --failed`.
- `cargo fmt --check` toàn workspace đang lệch ở nhiều tệp có sẵn (CI không kiểm Rust fmt); đừng định dạng hàng loạt
  trong PR tính năng.
- Dòng bản quyền "Tien Do Nam" trong LICENSE/NOTICE/Runner.rc/AppInfo.xcconfig/cli/build.rs phải giữ (Apache-2.0 4c).
