import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' show Color, ThemeMode;
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/persistence/color_mode.dart';
import 'package:localsend_app/model/persistence/favorite_device.dart';
import 'package:localsend_app/model/send_mode.dart';

// lotus-share: "Sao lưu ra tệp (miễn phí)" - ADR-0001 mục 2 (PRODUCT_POLICY 7.1 N2: quyền mang dữ liệu đi).
// Chỉ gồm thiết bị yêu thích + cài đặt KHÔNG gắn máy. Không bao giờ có: khóa riêng/chứng thư TLS, mã PIN nhận, lịch sử
// nhận, bí danh thiết bị, cổng, thư mục lưu, danh sách mạng, kiểu thiết bị, vị trí cửa sổ; cũng KHÔNG có "lưu nhanh"
// (tự nhận tệp): tệp do người khác soạn có thể thêm vân tay lạ vào yêu thích rồi bật tự nhận từ yêu thích.

/// Giá trị trường `format` của tệp sao lưu.
const settingsBackupFormat = 'lotus-share-backup';

/// Phiên bản định dạng hiện tại. Tệp có phiên bản lớn hơn bị từ chối (bản cũ không hiểu hết).
const settingsBackupVersion = 1;

/// Giới hạn kích thước tệp nhập (chống tệp lạ/quá lớn làm treo giao diện).
const settingsBackupMaxBytes = 1024 * 1024;

/// Giới hạn số thiết bị yêu thích trong một tệp.
const settingsBackupMaxFavorites = 1000;

/// Cài đặt mang theo được giữa các máy. Trường null = tệp không có (giữ nguyên giá trị đang dùng).
class PortableSettings {
  final ThemeMode? theme;
  final ColorMode? colorMode;
  final Color? customColor;

  /// `null` + [hasLocale] = theo hệ thống.
  final AppLocale? locale;
  final bool hasLocale;
  final bool? saveToHistory;
  final bool? autoFinish;
  final bool? minimizeToTray;
  final bool? enableAnimations;
  final SendMode? sendMode;
  final bool? createChecksums;
  final bool? verifyChecksums;

  const PortableSettings({
    this.theme,
    this.colorMode,
    this.customColor,
    this.locale,
    this.hasLocale = false,
    this.saveToHistory,
    this.autoFinish,
    this.minimizeToTray,
    this.enableAnimations,
    this.sendMode,
    this.createChecksums,
    this.verifyChecksums,
  });

  Map<String, Object?> toJson() => {
    if (theme != null) 'theme': theme!.name,
    if (colorMode != null) 'colorMode': colorMode!.name,
    if (customColor != null) 'customColor': _colorToHex(customColor!),
    if (hasLocale) 'locale': locale?.languageTag ?? 'system',
    if (saveToHistory != null) 'saveToHistory': saveToHistory,
    if (autoFinish != null) 'autoFinish': autoFinish,
    if (minimizeToTray != null) 'minimizeToTray': minimizeToTray,
    if (enableAnimations != null) 'enableAnimations': enableAnimations,
    if (sendMode != null) 'sendMode': sendMode!.name,
    if (createChecksums != null) 'createChecksums': createChecksums,
    if (verifyChecksums != null) 'verifyChecksums': verifyChecksums,
  };

  /// Khóa lạ hoặc giá trị sai kiểu bị bỏ qua (tệp từ bản mới hơn cùng phiên bản định dạng vẫn nhập được phần biết).
  factory PortableSettings.fromJson(Map<String, Object?> json) {
    final localeRaw = json['locale'];
    final hasLocale = localeRaw is String && (localeRaw == 'system' || AppLocale.values.any((l) => l.languageTag == localeRaw));
    return PortableSettings(
      theme: _enumByName(ThemeMode.values, json['theme']),
      colorMode: _enumByName(ColorMode.values, json['colorMode']),
      customColor: _colorFromHex(json['customColor']),
      locale: hasLocale ? AppLocale.values.firstWhereOrNull((l) => l.languageTag == localeRaw) : null,
      hasLocale: hasLocale,
      saveToHistory: _bool(json['saveToHistory']),
      autoFinish: _bool(json['autoFinish']),
      minimizeToTray: _bool(json['minimizeToTray']),
      enableAnimations: _bool(json['enableAnimations']),
      sendMode: _enumByName(SendMode.values, json['sendMode']),
      createChecksums: _bool(json['createChecksums']),
      verifyChecksums: _bool(json['verifyChecksums']),
    );
  }
}

/// Nội dung một tệp sao lưu đã đọc.
class SettingsBackup {
  final List<FavoriteDevice> favorites;
  final PortableSettings settings;

  const SettingsBackup({required this.favorites, required this.settings});
}

/// Lỗi tệp sao lưu (sai định dạng, phiên bản mới hơn, quá lớn).
class SettingsBackupException implements Exception {
  final String message;

  const SettingsBackupException(this.message);

  @override
  String toString() => 'SettingsBackupException: $message';
}

/// Ghi tệp sao lưu (JSON thụt lề, UTF-8).
String encodeSettingsBackup({
  required List<FavoriteDevice> favorites,
  required PortableSettings settings,
  required DateTime now,
}) {
  return const JsonEncoder.withIndent('  ').convert({
    'format': settingsBackupFormat,
    'version': settingsBackupVersion,
    'exportedAt': now.toUtc().toIso8601String(),
    'favorites': [
      for (final f in favorites)
        {
          'fingerprint': f.fingerprint,
          'alias': f.alias,
          'customAlias': f.customAlias,
          'ip': f.ip,
          'port': f.port,
        },
    ],
    'settings': settings.toJson(),
  });
}

/// Đọc tệp sao lưu. Ném [SettingsBackupException] khi tệp không phải sao lưu Lotus Share hợp lệ.
SettingsBackup decodeSettingsBackup(String content) {
  if (utf8.encode(content).length > settingsBackupMaxBytes) {
    throw const SettingsBackupException('too large');
  }
  final Object? root;
  try {
    root = jsonDecode(content);
  } on FormatException {
    throw const SettingsBackupException('not json');
  }
  if (root is! Map<String, Object?> || root['format'] != settingsBackupFormat) {
    throw const SettingsBackupException('wrong format');
  }
  final version = root['version'];
  if (version is! int || version < 1) {
    throw const SettingsBackupException('wrong version');
  }
  if (version > settingsBackupVersion) {
    throw const SettingsBackupException('newer version');
  }
  final favoritesRaw = root['favorites'];
  final favorites = <FavoriteDevice>[];
  if (favoritesRaw is List) {
    if (favoritesRaw.length > settingsBackupMaxFavorites) {
      throw const SettingsBackupException('too many favorites');
    }
    for (final entry in favoritesRaw) {
      if (entry is! Map<String, Object?>) continue;
      final fingerprint = entry['fingerprint'];
      final alias = entry['alias'];
      final ip = entry['ip'];
      final port = entry['port'];
      if (fingerprint is! String || fingerprint.isEmpty || alias is! String || ip is! String || port is! int) continue;
      if (port < 1 || port > 65535) continue;
      favorites.add(
        FavoriteDevice.fromValues(fingerprint: fingerprint, ip: ip, port: port, alias: alias).copyWith(
          customAlias: entry['customAlias'] == true,
        ),
      );
    }
  }
  final settingsRaw = root['settings'];
  return SettingsBackup(
    favorites: favorites,
    settings: settingsRaw is Map<String, Object?> ? PortableSettings.fromJson(settingsRaw) : const PortableSettings(),
  );
}

/// Gộp yêu thích theo vân tay: thiết bị đã có giữ nguyên (máy này là nguồn đúng về IP/bí danh), thiết bị mới được thêm.
/// Trả về danh sách thiết bị cần THÊM.
List<FavoriteDevice> favoritesToAdd(List<FavoriteDevice> existing, List<FavoriteDevice> imported) {
  final known = existing.map((e) => e.fingerprint).toSet();
  final result = <FavoriteDevice>[];
  for (final device in imported) {
    if (known.add(device.fingerprint)) {
      result.add(device);
    }
  }
  return result;
}

T? _enumByName<T extends Enum>(List<T> values, Object? name) => name is String ? values.firstWhereOrNull((v) => v.name == name) : null;

bool? _bool(Object? value) => value is bool ? value : null;

String _colorToHex(Color color) => color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);

Color? _colorFromHex(Object? value) {
  if (value is! String || !RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value)) return null;
  return Color(0xff000000 | int.parse(value, radix: 16));
}
