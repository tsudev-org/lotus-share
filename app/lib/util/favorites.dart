import 'package:collection/collection.dart';
import 'package:localsend_app/model/persistence/favorite_device.dart';
import 'package:localsend_isolates/model/device.dart';

extension FavoriteDevicesExt on Iterable<FavoriteDevice> {
  /// Returns the favorite device with the given [device] or null if not found.
  FavoriteDevice? findDevice(Device device) {
    return firstWhereOrNull((e) => e.fingerprint == device.fingerprint);
  }

  /// Returns true if the list contains the given [device].
  bool containsDevice(Device device) {
    return any((e) => e.fingerprint == device.fingerprint);
  }
}

// tsudev-lotus: chỉ tin dấu vân tay đã được xác thực bằng chứng thư mTLS.
// Ở chế độ HTTP (tắt mã hóa), dấu vân tay trong JSON do máy gửi tự khai nên giả được;
// một máy lạ trong LAN có thể mạo danh thiết bị yêu thích để được "Lưu nhanh" (bỏ qua
// bước bấm Chấp nhận) hoặc hiện tên quen thuộc. Vì vậy chỉ so khớp khi có dấu vân tay
// lấy từ chứng thư TLS của kết nối.
extension TrustedFavoriteDevicesExt on Iterable<FavoriteDevice> {
  /// Thiết bị yêu thích khớp [verifiedFingerprint], hoặc null khi dấu vân tay chưa xác thực.
  FavoriteDevice? findByVerifiedFingerprint(String? verifiedFingerprint) {
    if (verifiedFingerprint == null || verifiedFingerprint.isEmpty) {
      return null;
    }
    return firstWhereOrNull((e) => e.fingerprint == verifiedFingerprint);
  }
}
