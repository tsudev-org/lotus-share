// tsudev-lotus: kiểm thử chỉ tin thiết bị yêu thích qua dấu vân tay mTLS.
import 'package:localsend_app/model/persistence/favorite_device.dart';
import 'package:localsend_app/util/favorites.dart';
import 'package:test/test.dart';

void main() {
  const fp = 'A1B2C3';
  const favorites = [
    FavoriteDevice(id: '1', fingerprint: fp, ip: '192.168.1.5', port: 53317, alias: 'Máy của Mẹ'),
  ];

  group('findByVerifiedFingerprint', () {
    test('khớp khi dấu vân tay đã xác thực bằng mTLS', () {
      expect(favorites.findByVerifiedFingerprint(fp)?.alias, 'Máy của Mẹ');
    });

    test('không tin khi không có dấu vân tay mTLS (chế độ HTTP, máy gửi tự khai)', () {
      expect(favorites.findByVerifiedFingerprint(null), isNull);
      expect(favorites.findByVerifiedFingerprint(''), isNull);
    });

    test('dấu vân tay khác thì không khớp', () {
      expect(favorites.findByVerifiedFingerprint('FFFFFF'), isNull);
    });
  });
}
