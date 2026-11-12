import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/network/server/server_provider.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:localsend_app/provider/version_provider.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/util/update_check.dart';
import 'package:logging/logging.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final _logger = Logger('UpdateDialog');

/// lotus-share: kiểm tra phiên bản khi mở ứng dụng.
///
/// 1. Bản đang dùng thấp hơn mức tối thiểu đã lưu từ lần trước: chặn ngay, kể cả khi không có Internet.
/// 2. Tải `phien-ban.json` ở nền: thấp hơn mức tối thiểu thì dừng máy chủ nhận tệp và hiện hộp thoại không đóng được;
///    chỉ có bản mới hơn thì hiện hộp thoại bỏ qua được (mỗi bản mới một lần).
/// Không tải được tệp: ứng dụng chạy bình thường.
Future<void> runUpdateCheck(BuildContext context, Ref ref) async {
  final persistence = ref.read(persistenceProvider);
  final VersionData version;
  try {
    version = await ref.future(versionProvider);
  } catch (e) {
    _logger.warning('Could not read app version', e);
    return;
  }
  final currentBuild = int.tryParse(version.buildNumber);

  if (decideUpdate(currentBuild: currentBuild, minimumBuild: persistence.getUpdateMinimumBuild(), latestBuild: null) == UpdateDecision.required) {
    if (context.mounted) {
      await _block(context, ref, version.version, null);
    }
    return;
  }

  final manifest = await fetchUpdateManifest();
  if (manifest == null || !context.mounted) {
    return;
  }
  await persistence.raiseUpdateMinimumBuild(manifest.minimumBuild);
  if (!context.mounted) {
    return;
  }

  switch (decideUpdate(currentBuild: currentBuild, minimumBuild: manifest.minimumBuild, latestBuild: manifest.latestBuild)) {
    case UpdateDecision.required:
      await _block(context, ref, version.version, manifest.latestVersion);
    case UpdateDecision.optional:
      if (persistence.getUpdateDismissedBuild() == manifest.latestBuild) {
        return;
      }
      final later = await showDialog<bool>(
        context: context,
        builder: (_) => _UpdateAvailableDialog(current: version.version, latest: manifest.latestVersion),
      );
      if (later == true) {
        await persistence.setUpdateDismissedBuild(manifest.latestBuild);
      }
    case UpdateDecision.upToDate:
      break;
  }
}

Future<void> _block(BuildContext context, Ref ref, String current, String? latest) async {
  _logger.warning('App version $current is below the minimum supported version, blocking.');
  try {
    // Bản quá cũ không còn nói cùng giao thức: không nhận tệp nữa.
    await ref.notifier(serverProvider).stopServer();
  } catch (e) {
    _logger.warning('Could not stop server', e);
  }
  if (!context.mounted) {
    return;
  }
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => UpdateRequiredDialog(current: current, latest: latest),
  );
}

/// Hộp thoại không đóng được: chỉ có "Tải bản mới" và (trừ iOS) "Thoát".
class UpdateRequiredDialog extends StatelessWidget {
  final String current;
  final String? latest;

  const UpdateRequiredDialog({required this.current, required this.latest, super.key});

  @override
  Widget build(BuildContext context) {
    final strings = t.tsudev.updateRequired;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        icon: const Icon(Icons.system_update),
        title: Text(strings.title),
        content: Text(latest == null ? strings.bodyLatest(current: current) : strings.body(current: current, latest: latest!)),
        actions: [
          if (!checkPlatform([TargetPlatform.iOS]))
            TextButton(
              onPressed: () async {
                if (checkPlatformIsDesktop()) {
                  exit(0);
                }
                await SystemNavigator.pop();
              },
              child: Text(strings.exit),
            ),
          FilledButton(
            onPressed: () async {
              await launchUrl(Uri.parse(updateDownloadUrl), mode: LaunchMode.externalApplication);
            },
            child: Text(strings.download),
          ),
        ],
      ),
    );
  }
}

class _UpdateAvailableDialog extends StatelessWidget {
  final String current;
  final String latest;

  const _UpdateAvailableDialog({required this.current, required this.latest});

  @override
  Widget build(BuildContext context) {
    final strings = t.tsudev.updateAvailable;
    return AlertDialog(
      icon: const Icon(Icons.system_update),
      title: Text(strings.title(latest: latest)),
      content: Text(strings.body(current: current)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(strings.later),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop(false);
            await launchUrl(Uri.parse(updateDownloadUrl), mode: LaunchMode.externalApplication);
          },
          child: Text(strings.download),
        ),
      ],
    );
  }
}
