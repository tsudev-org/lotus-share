import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/config/product_tokens.g.dart';
import 'package:localsend_app/widget/canh_sen_motif.dart';

void main() {
  test('hình học canh-sen: 7 cánh đối xứng, chung gốc, ngọn cánh giữa ở (0, -1)', () {
    final petals = CanhSenGeometry.build();
    expect(petals, hasLength(7));
    for (final (left, right) in petals) {
      expect(left, hasLength(CanhSenGeometry.steps + 1));
      expect(left.first.distance, closeTo(0, 1e-9));
      expect((left.last - right.last).distance, closeTo(0, 1e-9));
    }
    final tip = petals[3].$1.last;
    expect(tip.dx, closeTo(0, 1e-9));
    expect(tip.dy, closeTo(-1, 1e-9));
    // Đối xứng qua trục dọc: cánh k và cánh 6-k soi gương nhau
    for (var k = 0; k < 7; k++) {
      final a = petals[k].$1.last;
      final b = petals[6 - k].$1.last;
      expect(a.dx, closeTo(-b.dx, 1e-9));
      expect(a.dy, closeTo(b.dy, 1e-9));
    }
  });

  testWidgets('hoạ tiết tĩnh, không chặn chạm, độ phủ <= 15%, màu accent theo chế độ', (tester) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const Scaffold(body: CanhSenMotif()),
        ),
      );
      await tester.pumpAndSettle(); // MaterialApp nội suy theme khi đổi chế độ
      final paint = tester.widget<CustomPaint>(find.descendant(of: find.byType(CanhSenMotif), matching: find.byType(CustomPaint)));
      final color = (paint.painter! as CanhSenPainter).color;
      final accent = (brightness == Brightness.dark ? ProductTokens.dark : ProductTokens.light).accent;
      expect(color.a, lessThanOrEqualTo(0.15));
      expect(color.withValues(alpha: 1), accent.withValues(alpha: 1));
      expect(find.descendant(of: find.byType(CanhSenMotif), matching: find.byType(IgnorePointer)), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    }
  });
}
