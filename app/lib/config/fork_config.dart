// tsudev-lotus: cấu hình tập trung của bản fork.
//
// Mọi giá trị khác với LocalSend gốc (tên hiển thị, URL, ngôn ngữ mặc định, máy chủ)
// gom về MỘT tệp này để khi gộp upstream chỉ cần đối chiếu một chỗ.
// Đổi bất kỳ giá trị nào ở đây cần chủ dự án duyệt (xem AGENTS.md mục B.3).

/// Tên sản phẩm hiển thị cho người dùng.
const forkProductName = 'tsudev-lotus';

/// Tên chủ sở hữu bản fork, dùng ở dòng bản quyền.
const forkOwner = 'tsudev';

/// Trang sản phẩm (tên miền con 1 cấp của tsudev.com, cùng kiểu trafficmonitor.tsudev.com).
const forkHomepageUrl = 'https://lotus.tsudev.com';

/// Chính sách quyền riêng tư dùng chung của cả hệ sinh thái (ECOSYSTEM_IDENTITY mục 4).
const forkPrivacyUrl = 'https://tsudev.com/privacy';

/// Kho mã nguồn của bản fork.
const forkRepositoryUrl = 'https://github.com/tsudev-org/tsudev-lotus';

/// Trang phát hành, nơi người dùng tải bản cập nhật.
const forkReleasesUrl = 'https://github.com/tsudev-org/tsudev-lotus/releases/latest';

/// Trang chủ hệ sinh thái.
const forkEcosystemUrl = 'https://tsudev.com';

/// Dự án gốc (giữ để ghi công theo giấy phép Apache-2.0).
const upstreamName = 'LocalSend';
const upstreamAuthor = 'Tien Do Nam';
const upstreamHomepageUrl = 'https://localsend.org';
const upstreamRepositoryUrl = 'https://github.com/localsend/localsend';

/// Ngôn ngữ mặc định khi người dùng chưa chọn ngôn ngữ (thay cho "theo ngôn ngữ hệ thống").
/// Người dùng vẫn đổi được trong Cài đặt > Ngôn ngữ.
const forkDefaultLocaleTag = 'vi';

/// Máy chủ tín hiệu WebRTC mặc định. Tính năng WebRTC hiện TẮT (`webRTCEnabled = false`),
/// nên ứng dụng không kết nối tới các địa chỉ này. Khi bật, cần dựng máy chủ riêng
/// (thư mục `server/`) rồi đổi sang tên miền của tsudev.
const forkDefaultSignalingServers = ['wss://public.localsend.org/v1/ws'];
const forkDefaultStunServers = ['stun:stun.localsend.org:3478'];
