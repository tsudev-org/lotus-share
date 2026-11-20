import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/persistence/color_mode.dart';
import 'package:localsend_app/model/persistence/favorite_device.dart';
import 'package:localsend_app/model/send_mode.dart';
import 'package:localsend_app/util/settings_backup.dart';
import 'package:test/test.dart';

FavoriteDevice _fav(String fp, {String alias = 'Máy A', bool custom = false}) =>
    FavoriteDevice(id: 'id-$fp', fingerprint: fp, ip: '192.168.1.2', port: 53420, alias: alias, customAlias: custom);

void main() {
  final now = DateTime.utc(2026, 11, 20, 8);

  test('Xuất rồi nhập lại giữ nguyên yêu thích và cài đặt', () {
    final content = encodeSettingsBackup(
      favorites: [
        _fav('fp1', custom: true),
        _fav('fp2', alias: 'Điện thoại'),
      ],
      settings: const PortableSettings(
        theme: ThemeMode.dark,
        colorMode: ColorMode.custom,
        customColor: Color(0xFF123456),
        locale: AppLocale.vi,
        hasLocale: true,
        saveToHistory: false,
        sendMode: SendMode.multiple,
        verifyChecksums: true,
      ),
      now: now,
    );
    final backup = decodeSettingsBackup(content);
    expect(backup.favorites.map((f) => (f.fingerprint, f.alias, f.customAlias, f.port)), [
      ('fp1', 'Máy A', true, 53420),
      ('fp2', 'Điện thoại', false, 53420),
    ]);
    final s = backup.settings;
    expect(s.theme, ThemeMode.dark);
    expect(s.colorMode, ColorMode.custom);
    expect(s.customColor, const Color(0xFF123456));
    expect(s.hasLocale, isTrue);
    expect(s.locale, AppLocale.vi);
    expect(s.saveToHistory, isFalse);
    expect(s.sendMode, SendMode.multiple);
    expect(s.verifyChecksums, isTrue);
    expect(s.autoFinish, isNull);
  });

  test('Ngôn ngữ "theo hệ thống" được giữ', () {
    final content = encodeSettingsBackup(favorites: [], settings: const PortableSettings(hasLocale: true), now: now);
    final s = decodeSettingsBackup(content).settings;
    expect(s.hasLocale, isTrue);
    expect(s.locale, isNull);
  });

  test('Tệp không chứa khóa, PIN, bí danh máy, cổng, thư mục, lưu nhanh', () {
    final content = encodeSettingsBackup(favorites: [_fav('fp1')], settings: const PortableSettings(), now: now);
    final keys = (jsonDecode(content) as Map<String, Object?>).keys.toSet();
    expect(keys, {'format', 'version', 'exportedAt', 'favorites', 'settings'});
    // Bí danh/cổng trong mục yêu thích là của THIẾT BỊ YÊU THÍCH (được phép); dưới đây là dữ liệu của máy này.
    for (final forbidden in ['securityContext', 'privateKey', 'certificate', 'receivePin', 'destination', 'quickSave', 'multicast']) {
      expect(content.contains(forbidden), isFalse, reason: forbidden);
    }
  });

  test('Bỏ qua lưu nhanh dù tệp có (tệp lạ không bật được tự nhận)', () {
    final content = jsonEncode({
      'format': settingsBackupFormat,
      'version': 1,
      'favorites': <Object>[],
      'settings': {'quickSave': true, 'quickSaveFromFavorites': true, 'receivePin': '1234', 'theme': 'light'},
    });
    final s = decodeSettingsBackup(content).settings;
    expect(s.toJson(), {'theme': 'light'});
  });

  test('Từ chối tệp không phải sao lưu Lotus Share', () {
    for (final bad in ['không phải json', '[]', '{"format":"khac","version":1}', '{"format":"$settingsBackupFormat"}']) {
      expect(() => decodeSettingsBackup(bad), throwsA(isA<SettingsBackupException>()), reason: bad);
    }
  });

  test('Từ chối tệp của phiên bản định dạng mới hơn', () {
    expect(
      () => decodeSettingsBackup('{"format":"$settingsBackupFormat","version":${settingsBackupVersion + 1}}'),
      throwsA(isA<SettingsBackupException>().having((e) => e.message, 'message', 'newer version')),
    );
  });

  test('Từ chối tệp quá lớn, bỏ qua mục yêu thích hỏng và giá trị sai kiểu', () {
    expect(() => decodeSettingsBackup('x' * (settingsBackupMaxBytes + 1)), throwsA(isA<SettingsBackupException>()));
    final content = jsonEncode({
      'format': settingsBackupFormat,
      'version': 1,
      'favorites': [
        {'fingerprint': 'ok', 'alias': 'A', 'ip': '10.0.0.2', 'port': 53420},
        {'fingerprint': '', 'alias': 'A', 'ip': '10.0.0.2', 'port': 53420},
        {'fingerprint': 'cong-sai', 'alias': 'A', 'ip': '10.0.0.2', 'port': 70000},
        {'fingerprint': 'thieu-ip', 'alias': 'A', 'port': 53420},
        'rác',
      ],
      'settings': {'theme': 'tim', 'customColor': 'zzzzzz', 'verifyChecksums': 'yes', 'locale': 'xx'},
    });
    final backup = decodeSettingsBackup(content);
    expect(backup.favorites.map((f) => f.fingerprint), ['ok']);
    expect(backup.settings.toJson(), isEmpty);
  });

  test('Gộp yêu thích theo vân tay: giữ thiết bị đã có, chỉ thêm thiết bị mới, không trùng trong tệp', () {
    final existing = [_fav('fp1', alias: 'Trên máy này')];
    final imported = [_fav('fp1', alias: 'Trong tệp'), _fav('fp2'), _fav('fp2', alias: 'Trùng')];
    expect(favoritesToAdd(existing, imported).map((f) => (f.fingerprint, f.alias)), [('fp2', 'Máy A')]);
  });
}
