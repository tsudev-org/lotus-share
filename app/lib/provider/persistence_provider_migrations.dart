part of 'persistence_provider.dart';

const _latestVersion = 5;

Future<void> _runMigrations(int from) async {
  if (from < 2) {
    await _migrate2();
    await SharedPreferencesStorePlatform.instance.setValue('Int', 'flutter.$_version', 2);
  }
  if (from < 3) {
    await _migrate3();
    await SharedPreferencesStorePlatform.instance.setValue('Int', 'flutter.$_version', 3);
  }
  if (from < 4) {
    await _migrate4();
    await SharedPreferencesStorePlatform.instance.setValue('Int', 'flutter.$_version', 4);
  }
  if (from < 5) {
    await _migrate5();
    await SharedPreferencesStorePlatform.instance.setValue('Int', 'flutter.$_version', 5);
  }
}

Future<void> _migrate2() async {
  _logger.info('Migrating to version 2');
  if (SharedPreferencesStorePlatform.instance is! SharedPreferencesPortable) {
    await enableContextMenu();
  }
}

Future<void> _migrate3() async {
  _logger.info('Migrating to version 3');
  final prefs = await SharedPreferencesStorePlatform.instance.getAll();

  // ls_quick_save becomes a QuickSaveMode: keep "on" if it was enabled, otherwise apply the new default "paired"
  // (which is what ls_quick_save_from_favorites used to do)
  final quickSave = prefs['flutter.$_quickSave'] == true ? QuickSaveMode.on : QuickSaveMode.paired;
  await SharedPreferencesStorePlatform.instance.setValue('String', 'flutter.$_quickSave', quickSave.name);
  await SharedPreferencesStorePlatform.instance.remove('flutter.ls_quick_save_from_favorites');

  // some users disabled HTTPS for performance reasons which no longer apply since the Rust migration
  await SharedPreferencesStorePlatform.instance.setValue('Bool', 'flutter.$_https', true);
}

Future<void> _migrate4() async {
  _logger.info('Migrating to version 4');
  final prefs = await SharedPreferencesStorePlatform.instance.getAll();
  final value = prefs['flutter.$_quickSave'];
  if (value is bool) {
    // Match migration 3 and the favorites-only default announced in What's new in 1.18.0.
    final quickSave = value ? QuickSaveMode.on : QuickSaveMode.paired;
    await SharedPreferencesStorePlatform.instance.setValue('String', 'flutter.$_quickSave', quickSave.name);
  }
}

/// lotus-share: Lotus Share 2.0 có giao thức riêng (cổng 53420, nhóm 224.0.0.168). Cổng/nhóm đã lưu đúng bằng giá
/// trị mặc định cũ (bản 1.x) thì bỏ để dùng mặc định mới; giá trị người dùng tự đặt khác thì giữ.
Future<void> _migrate5() async {
  _logger.info('Migrating to version 5');
  final prefs = await SharedPreferencesStorePlatform.instance.getAll();
  if (prefs['flutter.$_portKey'] == 53317) {
    await SharedPreferencesStorePlatform.instance.remove('flutter.$_portKey');
  }
  if (prefs['flutter.$_multicastGroupKey'] == '224.0.0.167') {
    await SharedPreferencesStorePlatform.instance.remove('flutter.$_multicastGroupKey');
  }
  if (prefs['flutter.$_colorKey'] == 'localsend') {
    await SharedPreferencesStorePlatform.instance.setValue('String', 'flutter.$_colorKey', ColorMode.lotus.name);
  }
  // Thiết bị yêu thích lưu cổng cũ: các máy đó cũng chuyển sang cổng mới khi cập nhật.
  final favorites = prefs['flutter.$_favorites'];
  if (favorites is List) {
    final migrated = [
      for (final raw in favorites.cast<String>())
        () {
          final json = jsonDecode(raw);
          if (json is Map<String, dynamic> && json['port'] == 53317) {
            json['port'] = defaultPort;
            return jsonEncode(json);
          }
          return raw;
        }(),
    ];
    await SharedPreferencesStorePlatform.instance.setValue('StringList', 'flutter.$_favorites', migrated);
  }
}
