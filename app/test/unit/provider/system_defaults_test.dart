// lotus-share: PRODUCT_POLICY mục 1.4 - người dùng mới nhận ngôn ngữ + giao diện theo hệ thống; ngôn ngữ chưa có bản
// dịch => tiếng Anh; máy đã cài trước 26.11 giữ nguyên mặc định cũ (tiếng Việt, Tối).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/config/theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/persistence/color_mode.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('người dùng mới', () {
    test('chưa lưu lựa chọn => ngôn ngữ và giao diện theo hệ thống', () async {
      SharedPreferences.setMockInitialValues({});
      final service = PersistenceService.forTest(await SharedPreferences.getInstance(), isFirstAppStart: true);
      expect(service.getLocale(), isNull, reason: 'null = theo hệ thống');
      expect(service.getTheme(), ThemeMode.system);
    });

    test('lựa chọn đã lưu thắng mặc định hệ thống', () async {
      SharedPreferences.setMockInitialValues({'ls_locale': 'en', 'ls_theme': 'light'});
      final service = PersistenceService.forTest(await SharedPreferences.getInstance());
      expect(service.getLocale(), AppLocale.en);
      expect(service.getTheme(), ThemeMode.light);
    });

    test('chọn "Theo hệ thống" được lưu và đọc lại là theo hệ thống', () async {
      SharedPreferences.setMockInitialValues({'ls_locale': 'vi'});
      final service = PersistenceService.forTest(await SharedPreferences.getInstance());
      await service.setLocale(null);
      expect(service.getLocale(), isNull);
    });
  });

  group('ngôn ngữ hệ thống', () {
    for (final (system, expected) in [
      (const Locale('vi', 'VN'), AppLocale.vi),
      (const Locale('en', 'US'), AppLocale.en),
      (const Locale('ja', 'JP'), AppLocale.ja),
      // Zulu chưa có bản dịch => tiếng Anh.
      (const Locale('zu', 'ZA'), AppLocale.en),
    ]) {
      testWidgets('hệ thống $system => ${expected.languageTag}', (tester) async {
        tester.platformDispatcher.localeTestValue = system;
        tester.platformDispatcher.localesTestValue = [system];
        addTearDown(tester.platformDispatcher.clearLocaleTestValue);
        addTearDown(tester.platformDispatcher.clearLocalesTestValue);
        // useDeviceLocale lúc khởi động chọn ngôn ngữ bằng đúng hàm này (rồi mới nạp bản dịch hoãn).
        expect(AppLocaleUtils.findDeviceLocale(), expected);
      });
    }
  });

  group('giao diện hệ thống', () {
    for (final brightness in Brightness.values) {
      testWidgets('hệ thống ${brightness.name} => bảng màu ${brightness.name}', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        SharedPreferences.setMockInitialValues({});
        final service = PersistenceService.forTest(await SharedPreferences.getInstance(), isFirstAppStart: true);
        late Brightness seen;
        await tester.pumpWidget(
          MaterialApp(
            theme: getTheme(ColorMode.lotus, Colors.purple, Brightness.light, null),
            darkTheme: getTheme(ColorMode.lotus, Colors.purple, Brightness.dark, null),
            themeMode: service.getTheme(),
            home: Builder(
              builder: (context) {
                seen = Theme.of(context).brightness;
                return const SizedBox();
              },
            ),
          ),
        );
        expect(seen, brightness);
      });
    }
  });

  group('nâng cấp từ bản đã cài (cấu hình phiên bản 5)', () {
    test('chưa từng chọn => giữ tiếng Việt + Tối như trước', () async {
      SharedPreferences.setMockInitialValues({'ls_version': 5});
      await PersistenceService.runMigrationsForTest(5);
      final service = PersistenceService.forTest(await SharedPreferences.getInstance());
      expect(service.getLocale(), AppLocale.vi);
      expect(service.getTheme(), ThemeMode.dark);
    });

    test('đã chọn => không đụng tới', () async {
      SharedPreferences.setMockInitialValues({'ls_version': 5, 'ls_locale': 'system', 'ls_theme': 'light'});
      await PersistenceService.runMigrationsForTest(5);
      final service = PersistenceService.forTest(await SharedPreferences.getInstance());
      expect(service.getLocale(), isNull);
      expect(service.getTheme(), ThemeMode.light);
    });
  });
}
