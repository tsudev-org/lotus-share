import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Giấy phép hiển thị trong ứng dụng phải trùng tệp gốc của repo (nghĩa vụ Apache-2.0 mục 4a).
void main() {
  for (final name in ['LICENSE', 'NOTICE']) {
    test('assets/legal/$name khớp ../$name', () {
      expect(File('assets/legal/$name').readAsStringSync(), File('../$name').readAsStringSync());
    });
  }
}
