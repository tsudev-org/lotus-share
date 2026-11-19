import 'package:flutter/material.dart';
import 'package:localsend_app/config/fork_config.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/util/native/tray_helper.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:window_manager/window_manager.dart';

final _logger = Logger('Init');

/// Shows an alternative app if the initialization failed.
void showInitErrorApp({
  required Object error,
  required StackTrace stackTrace,
}) async {
  _logger.severe('Error during init', error, stackTrace);
  // lotus-share: dấu hiệu cố định trong nhật ký hệ thống (cả bản release) để CI chạy thử biết ứng dụng rơi vào màn
  // hình lỗi khởi động dù tiến trình vẫn sống (sự cố 26.11.1801) - .github/workflows/apple.yml tìm chuỗi này.
  // ignore: avoid_print
  print('LOTUS_SHARE_INIT_ERROR: $error');

  if (checkPlatformIsDesktop()) {
    await WindowManager.instance.ensureInitialized();
    await WindowManager.instance.show();
  }

  runApp(
    RefenaScope(
      child: _ErrorApp(
        error: error,
        stackTrace: stackTrace,
      ),
    ),
  );

  await showFromTray();
}

class _ErrorApp extends StatefulWidget {
  final Object error;
  final StackTrace stackTrace;

  const _ErrorApp({
    required this.error,
    required this.stackTrace,
  });

  @override
  State<_ErrorApp> createState() => _ErrorAppState();
}

class _ErrorAppState extends State<_ErrorApp> {
  final _controller = TextEditingController();
  String? version;

  @override
  void initState() {
    super.initState();

    _controller.text = 'Error: ${widget.error}\n\n${widget.stackTrace}';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final info = await PackageInfo.fromPlatform();
      _controller.text = '$forkProductName ${info.version} (${info.buildNumber})\n\nError: ${widget.error}\n\n${widget.stackTrace}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$forkProductName: Error', // lotus-share
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: TextFormField(
          controller: _controller,
          maxLines: null,
          readOnly: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
          ),
        ),
      ),
    );
  }
}
