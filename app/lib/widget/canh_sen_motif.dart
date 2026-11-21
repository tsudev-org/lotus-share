import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:localsend_app/config/product_tokens.g.dart';

/// Hoạ tiết chữ ký `canh-sen` (tsudev-standards v5.0.0, DESIGN_SYSTEM mục 1.2.4): bảy cánh sen tạo bởi các điểm nối
/// nhau, TĨNH, vẽ bằng `accent` của bản sắc, độ phủ <= 15%.
///
/// Hình học giống hệt `website/src/lib/canh-sen.ts` và `website/scripts/brand_assets.py` (og-image): gốc ở đáy giữa,
/// đơn vị = chiều dài cánh giữa.
class CanhSenGeometry {
  CanhSenGeometry._();

  static const petals = 7;
  static const steps = 5;

  /// Danh sách cánh; mỗi cánh là (viền trái, viền phải), cùng số điểm, điểm đầu = gốc, điểm cuối = ngọn.
  static List<(List<Offset>, List<Offset>)> build() {
    final result = <(List<Offset>, List<Offset>)>[];
    for (var k = 0; k < petals; k++) {
      final offset = k - (petals - 1) / 2;
      final angle = -math.pi / 2 + offset * 22 * math.pi / 180;
      final length = 1 - 0.12 * offset.abs();
      final dir = Offset(math.cos(angle), math.sin(angle));
      final normal = Offset(-dir.dy, dir.dx);
      final left = <Offset>[];
      final right = <Offset>[];
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        final axis = dir * (t * length);
        final w = 0.26 * length * math.sin(math.pi * t);
        left.add(axis - normal * w);
        right.add(axis + normal * w);
      }
      result.add((left, right));
    }
    return result;
  }
}

class CanhSenMotif extends StatelessWidget {
  /// Độ phủ (<= 0.15 theo chuẩn).
  final double opacity;

  const CanhSenMotif({this.opacity = 0.1}) : assert(opacity <= 0.15);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = (dark ? ProductTokens.dark : ProductTokens.light).accent;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: CanhSenPainter(color.withValues(alpha: opacity)),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class CanhSenPainter extends CustomPainter {
  final Color color;

  CanhSenPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Hoa mọc từ đáy màn hình: cánh giữa dài 55% cạnh ngắn, gốc sát đáy - nằm sau tên thiết bị, không đè vùng nút.
    final unit = math.min(size.width, size.height) * 0.55;
    final origin = Offset(size.width / 2, size.height - 24);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final dot = Paint()..color = color;
    Offset p(Offset o) => origin + o * unit;
    for (final (left, right) in CanhSenGeometry.build()) {
      final outline = Path()..moveTo(p(left.first).dx, p(left.first).dy);
      for (final o in [...left.skip(1), ...right.reversed.skip(1)]) {
        outline.lineTo(p(o).dx, p(o).dy);
      }
      canvas.drawPath(outline, line);
      for (var i = 1; i < left.length - 1; i++) {
        canvas.drawLine(p(left[i]), p(right[i]), line);
        canvas.drawCircle(p(left[i]), 3, dot);
        canvas.drawCircle(p(right[i]), 3, dot);
      }
      canvas.drawCircle(p(left.last), 4, dot);
    }
    canvas.drawCircle(origin, 5, dot);
  }

  @override
  bool shouldRepaint(CanhSenPainter oldDelegate) => oldDelegate.color != color;
}
