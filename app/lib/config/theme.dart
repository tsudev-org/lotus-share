import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localsend_app/config/product_tokens.g.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/persistence/color_mode.dart';
import 'package:localsend_app/provider/device_info_provider.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/util/ui/dynamic_colors.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:yaru/yaru.dart' as yaru;

// lotus-share: bo góc theo bộ `tron` của bản sắc (tsudev-standards v5.0.0, DESIGN_SYSTEM mục 1.2.3) - ô nhập dùng md,
// nút dùng radius-control (999 = viên thuốc). Giá trị sinh từ .standards (tools/gen_product_tokens.py), không ghi số tay.
final _borderRadius = BorderRadius.circular(ProductTokens.radiusMd);
final _buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(ProductTokens.radiusControl));

/// Kiểu chữ tiêu đề/số liệu lớn của bản sắc (Quicksand, chỉ 600 hoặc 700) cho chữ lớn tự đặt cỡ ngoài textTheme.
TextStyle displayTextStyle({required double fontSize, int weight = 700}) => TextStyle(
  fontFamily: ProductTokens.fontDisplay,
  fontSize: fontSize,
  fontWeight: weight == 600 ? FontWeight.w600 : FontWeight.w700,
  fontVariations: [FontVariation.weight(weight == 600 ? 600 : 700)],
);

/// Font tiêu đề của bản sắc (h1-h3, số liệu lớn) cho nhóm display/headline/titleLarge; thân bài giữ font hệ thống.
/// Quicksand là font biến thiên (trục wght) nên đặt trục rõ ràng thay vì chỉ fontWeight.
TextTheme _withDisplayFont(TextTheme t) {
  TextStyle? display(TextStyle? s, double weight) => s?.copyWith(
    fontFamily: ProductTokens.fontDisplay,
    fontWeight: FontWeight.values.firstWhere((w) => w.value == weight.round()),
    fontVariations: [FontVariation.weight(weight)],
  );
  return t.copyWith(
    displayLarge: display(t.displayLarge, 700),
    displayMedium: display(t.displayMedium, 700),
    displaySmall: display(t.displaySmall, 700),
    headlineLarge: display(t.headlineLarge, 600),
    headlineMedium: display(t.headlineMedium, 600),
    headlineSmall: display(t.headlineSmall, 600),
    titleLarge: display(t.titleLarge, 600),
  );
}

ThemeData getTheme(ColorMode colorMode, Color customColor, Brightness brightness, DynamicColors? dynamicColors) {
  if (colorMode == ColorMode.yaru) {
    return _getYaruTheme(brightness);
  }

  final colorScheme = _determineColorScheme(colorMode, customColor, brightness, dynamicColors);

  final lightInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: colorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  final darkInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: colorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  final String? fontFamily;
  if (checkPlatform([TargetPlatform.windows])) {
    fontFamily = switch (LocaleSettings.currentLocale) {
      AppLocale.ja => 'Yu Gothic UI',
      AppLocale.ko => 'Malgun Gothic',
      AppLocale.zhCn => 'Microsoft YaHei UI',
      AppLocale.zhHk || AppLocale.zhTw => 'Microsoft JhengHei UI',
      _ => 'Segoe UI Variable Display',
    };
  } else if (checkPlatform([TargetPlatform.linux])) {
    fontFamily = switch (LocaleSettings.currentLocale) {
      AppLocale.ja => 'Noto Sans CJK JP',
      AppLocale.ko => 'Noto Sans CJK KR',
      AppLocale.zhCn => 'Noto Sans CJK SC',
      AppLocale.zhHk || AppLocale.zhTw => 'Noto Sans CJK TC',
      _ => 'Noto Sans',
    };
  } else {
    fontFamily = null;
  }

  final theme = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    // same density on all platforms so desktop matches mobile (defaults to compact on desktop)
    visualDensity: VisualDensity.standard,
    navigationBarTheme: colorScheme.brightness == Brightness.dark
        ? NavigationBarThemeData(
            iconTheme: WidgetStateProperty.all(const IconThemeData(color: Colors.white)),
          )
        : null,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.secondaryContainer,
      border: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      focusedBorder: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      enabledBorder: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.brightness == Brightness.dark ? Colors.white : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: _buttonShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: _buttonShape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: _buttonShape)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: _buttonShape)),
    fontFamily: fontFamily,
  );
  return theme.copyWith(textTheme: _withDisplayFont(theme.textTheme));
}

Future<void> updateSystemOverlayStyle(BuildContext context) async {
  final brightness = Theme.of(context).brightness;
  await updateSystemOverlayStyleWithBrightness(brightness);
}

Future<void> updateSystemOverlayStyleWithBrightness(Brightness brightness) async {
  if (checkPlatform([TargetPlatform.android])) {
    // See https://github.com/flutter/flutter/issues/90098
    final darkMode = brightness == Brightness.dark;
    final androidSdkInt = RefenaScope.defaultRef.read(deviceInfoProvider).androidSdkInt ?? 0;
    final bool edgeToEdge = androidSdkInt >= 29;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // ignore: unawaited_futures

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: edgeToEdge ? Colors.transparent : (darkMode ? Colors.black : Colors.white),
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      ),
    );
  } else {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: brightness, // iOS
        statusBarColor: Colors.transparent, // Not relevant to this issue
      ),
    );
  }
}

extension ThemeDataExt on ThemeData {
  /// This is the actual [cardColor] being used.
  Color get cardColorWithElevation {
    return ElevationOverlay.applySurfaceTint(cardColor, colorScheme.surfaceTint, 1);
  }
}

extension ColorSchemeExt on ColorScheme {
  Color get warning {
    return Colors.orange;
  }

  Color? get secondaryContainerIfDark {
    return brightness == Brightness.dark ? secondaryContainer : null;
  }

  Color? get onSecondaryContainerIfDark {
    return brightness == Brightness.dark ? onSecondaryContainer : null;
  }
}

extension InputDecorationThemeExt on InputDecorationThemeData {
  BorderRadius get borderRadius => _borderRadius;
}

ColorScheme _determineColorScheme(ColorMode mode, Color customColor, Brightness brightness, DynamicColors? dynamicColors) {
  // lotus-share: màu nhấn của bản sắc `lotus` (tsudev-standards v5.0.0, tím cánh sen hue 320) - Tối #E47DFB, Sáng #A23DB8;
  // đọc từ .standards/tokens/products/lotus.json qua product_tokens.g.dart, không tự khai bảng màu.
  // fidelity giữ sắc độ của màu gốc thay vì làm nhạt như tonalSpot mặc định.
  final accent = brightness == Brightness.dark ? ProductTokens.dark : ProductTokens.light;
  final defaultColorScheme = ColorScheme.fromSeed(
    seedColor: accent.primary,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    primary: accent.primary,
    onPrimary: accent.onPrimary,
  );

  final colorScheme = switch (mode) {
    ColorMode.system => brightness == Brightness.light ? dynamicColors?.light : dynamicColors?.dark,
    ColorMode.lotus => null,
    ColorMode.oled => (dynamicColors?.dark ?? defaultColorScheme).copyWith(
      surface: Colors.black,
    ),
    ColorMode.yaru => throw 'Should reach here',
    ColorMode.custom => ColorScheme.fromSeed(
      seedColor: customColor,
      brightness: brightness,
    ),
  };

  return colorScheme ?? defaultColorScheme;
}

ThemeData _getYaruTheme(Brightness brightness) {
  final baseTheme = brightness == Brightness.light ? yaru.yaruLight : yaru.yaruDark;
  final colorScheme = baseTheme.colorScheme;

  final lightInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: colorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  final darkInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: colorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  InputDecorationThemeData;

  return baseTheme.copyWith(
    // same density on all platforms so desktop matches mobile (defaults to compact on desktop)
    visualDensity: VisualDensity.standard,
    navigationBarTheme: colorScheme.brightness == Brightness.dark
        ? NavigationBarThemeData(
            iconTheme: WidgetStateProperty.all(const IconThemeData(color: Colors.white)),
          )
        : null,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.secondaryContainer,
      border: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      focusedBorder: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      enabledBorder: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.brightness == Brightness.dark ? Colors.white : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
  );
}
