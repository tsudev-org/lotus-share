import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:localsend_app/gen/assets.gen.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/animation_provider.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:logging/logging.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:tray_manager/tray_manager.dart' as tm;
import 'package:window_manager/window_manager.dart';

final _logger = Logger('TrayHelper');

enum TrayEntry {
  open,
  close,
}

// lotus-share: tray_manager 0.8 (API gốc nativeapi). Giữ tham chiếu tới icon, menu, mục menu suốt đời ứng dụng: đối
// tượng bị thu gom là icon biến mất.
({tm.TrayIcon icon, tm.Menu menu, List<tm.MenuItem> items})? _tray;

Future<void> initTray() async {
  if (!checkPlatformHasTray()) {
    return;
  }
  if (checkPlatform([TargetPlatform.macOS])) {
    // The menu bar icon will created in AppDelegate.swift
    return;
  }
  if (_tray != null) {
    return;
  }
  try {
    final String asset;
    if (checkPlatform([TargetPlatform.windows])) {
      asset = Assets.img.logo;
    } else if (checkPlatform([TargetPlatform.linux])) {
      asset = Assets.img.logo32White.path;
    } else {
      asset = Assets.img.logo32.path;
    }
    // Đường dẫn tuyệt đối cạnh tệp chạy (data/flutter_assets/...), đúng cả AppImage, tar.gz, deb, rpm.
    final icon = tm.ImageAsset.fromAsset(asset);
    if (icon == null) {
      _logger.warning('Tray icon "$asset" not found next to ${Platform.resolvedExecutable}');
      return;
    }
    _logger.info('Using "$asset" as system tray icon');

    final trayIcon = tm.TrayIcon.create();
    if (trayIcon == null) {
      _logger.warning('Failed to create tray icon');
      return;
    }

    final menu = tm.Menu.create()!;
    final items = <tm.MenuItem>[];
    for (final (entry, label) in [
      (TrayEntry.open, t.tray.open),
      (TrayEntry.close, defaultTargetPlatform == TargetPlatform.windows ? t.tray.closeWindows : t.tray.close),
    ]) {
      final item = tm.MenuItem.createWithLabelAndType(label, tm.MenuItemType.normal)!;
      item.addListener((event) async {
        if (event is tm.MenuItemClickedEvent) {
          await _onTrayEntry(entry);
        }
      });
      menu.addItem(item);
      items.add(item);
    }

    trayIcon
      ..icon = icon
      ..setTooltip(t.appName)
      ..setContextMenu(menu)
      // Windows: chuột phải mở menu. Linux: bảng điều khiển tự mở menu, nhưng menu chỉ được xuất khi có trigger.
      ..setContextMenuTrigger(tm.ContextMenuTrigger.rightClicked)
      ..addListener((event) async {
        // Chuột trái (Windows) mở cửa sổ. Linux không báo sự kiện bấm icon.
        if (event is tm.TrayIconClickedEvent) {
          await showFromTray();
        }
      })
      ..setVisible(true);

    _tray = (icon: trayIcon, menu: menu, items: items);
  } catch (e) {
    _logger.warning('Failed to init tray', e);
  }
}

Future<void> _onTrayEntry(TrayEntry entry) async {
  switch (entry) {
    case TrayEntry.open:
      await showFromTray();
    case TrayEntry.close:
      exit(0);
  }
}

Future<void> hideToTray() async {
  await windowManager.hide();
  if (checkPlatform([TargetPlatform.macOS])) {
    // This will crash on Windows
    await windowManager.setSkipTaskbar(true);
  }

  // Disable animations
  try {
    RefenaScope.defaultRef.notifier(sleepProvider).setState((_) => true);
  } catch (e) {
    _logger.warning('Failed to update sleep state (Refena not yet initialized)', e);
  }
}

Future<void> showFromTray() async {
  await windowManager.show();
  await windowManager.focus();
  if (checkPlatform([TargetPlatform.macOS])) {
    // This will crash on Windows
    await windowManager.setSkipTaskbar(false);
  }

  // Enable animations
  try {
    RefenaScope.defaultRef.notifier(sleepProvider).setState((_) => false);
  } catch (e) {
    _logger.warning('Failed to update sleep state (Refena not yet initialized)', e);
  }
}

Future<void> destroyTray() async {
  _tray?.icon.dispose();
  _tray = null;
}
