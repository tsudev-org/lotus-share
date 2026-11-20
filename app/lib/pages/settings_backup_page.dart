// lotus-share: "Sao lưu ra tệp (miễn phí)" - ADR-0001 mục 2. Mọi thứ ở cục bộ, không gửi gì lên mạng.
import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/favorites_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/native/directories.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/util/settings_backup.dart';
import 'package:localsend_app/util/ui/snackbar.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:logging/logging.dart';
import 'package:refena_flutter/refena_flutter.dart';

final _logger = Logger('SettingsBackupPage');

const _jsonType = file_selector.XTypeGroup(
  label: 'JSON',
  extensions: ['json'],
  mimeTypes: ['application/json'],
  uniformTypeIdentifiers: ['public.json'],
);

class SettingsBackupPage extends StatelessWidget {
  const SettingsBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.tsudev.backup.title)),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 30),
          Text(t.tsudev.backup.description),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () async => _export(context),
                icon: const Icon(Icons.file_download_outlined),
                label: Text(t.tsudev.backup.export),
              ),
              OutlinedButton.icon(
                onPressed: () async => _import(context),
                icon: const Icon(Icons.file_upload_outlined),
                label: Text(t.tsudev.backup.import),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _export(BuildContext context) async {
  final ref = context.ref;
  final s = ref.read(settingsProvider);
  final content = encodeSettingsBackup(
    favorites: ref.read(favoritesProvider),
    settings: PortableSettings(
      theme: s.theme,
      colorMode: s.colorMode,
      customColor: s.customColor,
      locale: s.locale,
      hasLocale: true,
      saveToHistory: s.saveToHistory,
      autoFinish: s.autoFinish,
      minimizeToTray: s.minimizeToTray,
      enableAnimations: s.enableAnimations,
      sendMode: s.sendMode,
      createChecksums: s.createChecksums,
      verifyChecksums: s.verifyChecksums,
    ),
    now: DateTime.now(),
  );
  final now = DateTime.now();
  final fileName = 'lotus-share-sao-luu-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
  try {
    final String path;
    if (checkPlatform([TargetPlatform.android, TargetPlatform.iOS])) {
      // Android/iOS không có hộp thoại "Lưu thành": ghi vào thư mục Tải về (Android) / Tệp > Lotus Share (iOS).
      path = '${await getDefaultDestinationDirectory()}/$fileName';
    } else {
      final location = await file_selector.getSaveLocation(suggestedName: fileName, acceptedTypeGroups: [_jsonType]);
      if (location == null) return;
      path = location.path;
    }
    await File(path).writeAsString(content, flush: true);
    if (context.mounted) context.showSnackBar(t.tsudev.backup.exported(path: path));
  } catch (e) {
    _logger.warning('Export failed', e);
    if (context.mounted) context.showSnackBar(t.tsudev.backup.errorWrite);
  }
}

Future<void> _import(BuildContext context) async {
  final ref = context.ref;
  final file = await file_selector.openFile(acceptedTypeGroups: [_jsonType]);
  if (file == null) return;
  final SettingsBackup backup;
  try {
    if (await file.length() > settingsBackupMaxBytes) throw const SettingsBackupException('too large');
    backup = decodeSettingsBackup(utf8.decode(await file.readAsBytes()));
  } on SettingsBackupException catch (e) {
    if (context.mounted) {
      context.showSnackBar(e.message == 'newer version' ? t.tsudev.backup.errorNewer : t.tsudev.backup.errorInvalid);
    }
    return;
  } on FormatException {
    if (context.mounted) context.showSnackBar(t.tsudev.backup.errorInvalid);
    return;
  }

  final toAdd = favoritesToAdd(ref.read(favoritesProvider), backup.favorites);
  for (final device in toAdd) {
    await ref.redux(favoritesProvider).dispatchAsync(AddFavoriteAction(device));
  }

  final s = backup.settings;
  final settings = ref.notifier(settingsProvider);
  if (s.theme != null) await settings.setTheme(s.theme!);
  if (s.colorMode != null) await settings.setColorMode(s.colorMode!);
  if (s.customColor != null) await settings.setCustomColor(s.customColor!);
  if (s.hasLocale) {
    await settings.setLocale(s.locale);
    if (s.locale == null) {
      await LocaleSettings.useDeviceLocale();
    } else {
      await LocaleSettings.setLocale(s.locale!);
    }
  }
  if (s.saveToHistory != null) await settings.setSaveToHistory(s.saveToHistory!);
  if (s.autoFinish != null) await settings.setAutoFinish(s.autoFinish!);
  if (s.minimizeToTray != null) await settings.setMinimizeToTray(s.minimizeToTray!);
  if (s.enableAnimations != null) await settings.setEnableAnimations(s.enableAnimations!);
  if (s.sendMode != null) await settings.setSendMode(s.sendMode!);
  if (s.createChecksums != null) await settings.setCreateChecksums(s.createChecksums!);
  if (s.verifyChecksums != null) await settings.setVerifyChecksums(s.verifyChecksums!);

  if (context.mounted) context.showSnackBar(t.tsudev.backup.imported(n: toAdd.length));
}
