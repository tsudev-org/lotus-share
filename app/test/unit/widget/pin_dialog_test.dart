// lotus-share: PIN sinh bằng CSPRNG, đủ dài, chỉ dùng bảng chữ không gây nhầm lẫn.
import 'package:localsend_app/widget/dialogs/pin_dialog.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:test/test.dart';

void main() {
  test('PIN mặc định 8 ký tự, không ngắn hơn mức tối thiểu', () {
    final pin = generateSecurePin();
    expect(pin.length, 8);
    expect(pin.length, greaterThanOrEqualTo(pinMinLength));
  });

  test('chỉ dùng ký tự trong bảng noDoppelganger', () {
    for (var i = 0; i < 200; i++) {
      for (final c in generateSecurePin().split('')) {
        expect(Alphabet.noDoppelganger, contains(c));
      }
    }
  });

  test('không lặp lại sau 10.000 lần sinh (nguồn ngẫu nhiên mật mã)', () {
    final pins = {for (var i = 0; i < 10000; i++) generateSecurePin()};
    expect(pins.length, 10000);
  });
}
