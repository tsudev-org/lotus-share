// Cấu hình sản phẩm Lotus Share: tên hiển thị, URL, ngôn ngữ mặc định, máy chủ.
// Đổi bất kỳ giá trị nào ở đây cần chủ dự án duyệt (xem AGENTS.md mục B.3).

/// Tên sản phẩm hiển thị cho người dùng.
const forkProductName = 'Lotus Share';

/// Chủ sở hữu sản phẩm, dùng ở dòng bản quyền.
const forkOwner = 'tsudev';

/// Trang sản phẩm (tên miền con 1 cấp của tsudev.com, cùng kiểu trafficmonitor.tsudev.com).
const forkHomepageUrl = 'https://lotus.tsudev.com';

/// Chính sách quyền riêng tư dùng chung của cả hệ sinh thái (ECOSYSTEM_IDENTITY mục 4).
const forkPrivacyUrl = 'https://tsudev.com/privacy';

/// Kho mã nguồn.
const forkRepositoryUrl = 'https://github.com/tsudev-org/lotus-share';

/// Trang phát hành, nơi người dùng tải bản cập nhật.
const forkReleasesUrl = 'https://github.com/tsudev-org/lotus-share/releases/latest';

/// Trang chủ hệ sinh thái.
const forkEcosystemUrl = 'https://tsudev.com';

/// Ngôn ngữ mặc định khi người dùng chưa chọn ngôn ngữ (thay cho "theo ngôn ngữ hệ thống").
/// Người dùng vẫn đổi được trong Cài đặt > Ngôn ngữ.
const forkDefaultLocaleTag = 'vi';

/// Máy chủ tín hiệu WebRTC mặc định - hạ tầng của tsudev.
/// Tính năng WebRTC hiện TẮT ở thời điểm biên dịch (`webRTCEnabled = false`), nên ứng dụng
/// không kết nối tới các địa chỉ này. Trước khi bật: dựng máy chủ từ thư mục `server/` tại
/// `signal.lotus.tsudev.com` (task trong logs/STATE.md).
const forkDefaultSignalingServers = ['wss://signal.lotus.tsudev.com/v1/ws'];

/// Máy chủ STUN mặc định (Cloudflare, cùng nhà cung cấp hạ tầng với tsudev.com; chỉ dùng khi bật WebRTC).
const forkDefaultStunServers = ['stun:stun.cloudflare.com:3478'];

/// Trang Ủng hộ chính thức (kênh duy nhất, nguồn dữ liệu website/src/data/ung-ho.json). App chỉ MỞ trang này,
/// không tự hiển thị số tài khoản/QR (phiếu ~/projects/logs/handover/20261112-01 mục 3).
const forkSupportPageUrl = 'https://lotus.tsudev.com/ung-ho/';

/// Kênh ủng hộ hiển thị ở trang "Ủng hộ" - nguồn DUY NHẤT. Chỉ chứa địa chỉ thuộc hệ tsudev
/// (`tsudev.com`, `*.tsudev.com`, `github.com/tsudev-org`); kiểm thử chặn địa chỉ ngoài hệ.
/// Danh sách trống thì trang Ủng hộ bị ẩn khỏi Cài đặt.
const forkSupportLinks = <({String label, String url})>[
  (label: 'lotus.tsudev.com/ung-ho', url: forkSupportPageUrl),
  (label: 'tsudev.com', url: forkEcosystemUrl),
  (label: 'lotus.tsudev.com', url: forkHomepageUrl),
  (label: 'GitHub', url: forkRepositoryUrl),
];
