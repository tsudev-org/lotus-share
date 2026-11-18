// lotus-share: flutter_rust_bridge kiểm lúc khởi động mã sinh (codegen) phải TRÙNG bản thư viện Dart đang chạy; lệch
// là ứng dụng dừng ngay ở màn hình lỗi trên MỌI nền tảng (sự cố bản 26.11.1801: Dart 2.13.0, mã sinh 2.12.0). Test này
// chặn ở CI: mã sinh = gói Dart trong pubspec.lock = crate Rust trong Cargo.lock.
import 'dart:io';

import 'package:test/test.dart';

String _lockVersion(String path, RegExp pattern) {
  final match = pattern.firstMatch(File(path).readAsStringSync());
  expect(match, isNotNull, reason: 'không thấy flutter_rust_bridge trong $path');
  return match!.group(1)!;
}

void main() {
  test('mã sinh flutter_rust_bridge trùng bản Dart và bản Rust', () {
    // Đọc từ tệp mã sinh (RustLib.instance là thành viên nội bộ của gói, không gọi từ ngoài).
    final codegen = _lockVersion('../packages/localsend_isolates/lib/rust/frb_generated.dart', RegExp(r"String get codegenVersion => '([^']+)';"));
    final dart = _lockVersion('../pubspec.lock', RegExp(r'\n  flutter_rust_bridge:\n(?:    .*\n)*?    version: "([^"]+)"'));
    final rust = _lockVersion('../Cargo.lock', RegExp(r'name = "flutter_rust_bridge"\nversion = "([^"]+)"'));
    expect(dart, codegen, reason: 'pubspec.lock có flutter_rust_bridge $dart nhưng mã sinh là $codegen');
    expect(rust, codegen, reason: 'Cargo.lock có flutter_rust_bridge $rust nhưng mã sinh là $codegen');
  });
}
