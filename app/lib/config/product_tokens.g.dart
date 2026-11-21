// SINH TỰ ĐỘNG bởi tools/gen_product_tokens.py - KHÔNG SỬA TAY.
// Nguồn: .standards/tokens/products/lotus.json + products.css (tsudev-standards 5.0.0).
// Bản sắc: bố cục trinh-dien | bo góc tron | hoạ tiết canh-sen | tiêu đề Quicksand.
// ignore_for_file: constant_identifier_names

import 'dart:ui';

/// Vai trò nhấn của một chế độ màu (DESIGN_SYSTEM mục 1.1, lớp bản sắc ghi đè).
class ProductAccent {
  final Color textLink;
  final Color primary;
  final Color primaryHover;
  final Color primaryActive;
  final Color onPrimary;
  final Color focusRing;
  final Color accent;
  final Color glow;
  final Color iconInfo;
  final Color iconNav;

  const ProductAccent({
    required this.textLink,
    required this.primary,
    required this.primaryHover,
    required this.primaryActive,
    required this.onPrimary,
    required this.focusRing,
    required this.accent,
    required this.glow,
    required this.iconInfo,
    required this.iconNav,
  });
}

abstract final class ProductTokens {
  static const id = 'lotus';
  static const fontDisplay = 'Quicksand';
  static const light = ProductAccent(
    textLink: Color(0xFF8F27A4),
    primary: Color(0xFFA23DB8),
    primaryHover: Color(0xFF8F27A4),
    primaryActive: Color(0xFF7C0A91),
    onPrimary: Color(0xFFFFFFFF),
    focusRing: Color(0xFFA23DB8),
    accent: Color(0xFF821698),
    glow: Color(0x1AA23DB8),
    iconInfo: Color(0xFFA23DB8),
    iconNav: Color(0xFF8F27A4),
  );
  static const dark = ProductAccent(
    textLink: Color(0xFFEC98FF),
    primary: Color(0xFFE47DFB),
    primaryHover: Color(0xFFEC9EFE),
    primaryActive: Color(0xFFCC67E3),
    onPrimary: Color(0xFF0A0A0A),
    focusRing: Color(0xFFE47DFB),
    accent: Color(0xFFF1B7FF),
    glow: Color(0x24E47DFB),
    iconInfo: Color(0xFFE47DFB),
    iconNav: Color(0xFFEC98FF),
  );
  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusControl = 999;
}
