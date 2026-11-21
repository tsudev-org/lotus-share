// lotus-share: bản sắc `lotus` của tsudev-standards v5.0.0 (DESIGN_SYSTEM mục 1.2) - app đọc màu nhấn, bo góc, font
// tiêu đề từ .standards qua product_tokens.g.dart, không tự khai bảng màu. Test chặn lệch nguồn và chặn quay lại tím
// cũ dùng chung với TsuFiles (#A970FF / #7C3AED).
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/config/product_tokens.g.dart';
import 'package:localsend_app/config/theme.dart';
import 'package:localsend_app/model/persistence/color_mode.dart';

String _hex(Color c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

void main() {
  final source = jsonDecode(File('../.standards/tokens/products/lotus.json').readAsStringSync()) as Map<String, dynamic>;

  test('màu nhấn khớp .standards/tokens/products/lotus.json', () {
    final colors = source['colors'] as Map<String, dynamic>;
    for (final (mode, accent) in [('light', ProductTokens.light), ('dark', ProductTokens.dark)]) {
      final c = colors[mode] as Map<String, dynamic>;
      expect(_hex(accent.primary), c['primary'], reason: mode);
      expect(_hex(accent.onPrimary), c['on-primary'], reason: mode);
      expect(_hex(accent.textLink), c['text-link'], reason: mode);
      expect(_hex(accent.accent), c['accent'], reason: mode);
    }
    expect(ProductTokens.fontDisplay, source['fontDisplay']);
  });

  test('bo góc bộ tron: 8/14/20, nút viên thuốc', () {
    expect(source['shape'], 'tron');
    expect([ProductTokens.radiusSm, ProductTokens.radiusMd, ProductTokens.radiusLg], [8, 14, 20]);
    expect(ProductTokens.radiusControl, 999);
  });

  for (final brightness in Brightness.values) {
    test('theme Lotus ($brightness): nút chính đúng màu bản sắc, tiêu đề Quicksand, nút viên thuốc', () {
      final theme = getTheme(ColorMode.lotus, Colors.black, brightness, null);
      final accent = brightness == Brightness.dark ? ProductTokens.dark : ProductTokens.light;
      expect(theme.colorScheme.primary, accent.primary);
      expect(theme.colorScheme.onPrimary, accent.onPrimary);
      for (final s in [theme.textTheme.displayLarge, theme.textTheme.headlineSmall, theme.textTheme.titleLarge]) {
        expect(s?.fontFamily, 'Quicksand');
      }
      expect(theme.textTheme.bodyMedium?.fontFamily, isNot('Quicksand'));
      final shape = theme.filledButtonTheme.style?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(shape?.borderRadius, BorderRadius.circular(999));
      for (final c in [theme.colorScheme.primary, theme.colorScheme.secondary, theme.colorScheme.tertiary]) {
        expect(['#A970FF', '#7C3AED'], isNot(contains(_hex(c))));
      }
    });
  }
}
