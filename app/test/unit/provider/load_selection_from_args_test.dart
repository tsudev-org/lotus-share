// lotus-share: KHÓA hợp đồng "mở kèm tệp" mà ứng dụng khác trong hệ dựa vào (TsuFiles: nút "Gửi bằng Lotus Share",
// phiếu logs/handover/20261119-TC2_*, tài liệu docs/MO-KEM-TEP.md). Đổi hành vi dưới đây => sửa tài liệu + báo phiên
// tsufiles TRƯỚC khi phát hành.
import 'dart:io';

import 'package:localsend_app/model/cross_file.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_isolates/model/file_type.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:test/test.dart';

// Bản thuần Dart của CrossFileConverters.convertFile (bản thật đọc thời gian sửa tệp qua lõi Rust).
Future<CrossFile> _convert(File file) async => CrossFile(
  name: file.uri.pathSegments.last,
  fileType: FileType.other,
  size: await file.length(),
  thumbnail: null,
  asset: null,
  path: file.path,
  bytes: null,
  lastModified: null,
  lastAccessed: null,
);

void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('lotus-args-'));
  tearDown(() => tmp.deleteSync(recursive: true));

  File tao(String ten, String noiDung) => File('${tmp.path}${Platform.pathSeparator}$ten')..writeAsStringSync(noiDung);

  test('mỗi đối số là đường dẫn tuyệt đối của tệp => vào danh sách gửi, đúng thứ tự', () async {
    final a = tao('bao-cao.pdf', 'a');
    final b = tao('anh chup.png', 'bb');
    final service = ReduxNotifier.test(redux: SelectedSendingFilesNotifier());

    final added = await service.dispatchAsyncTakeResult(LoadSelectionFromArgsAction([a.absolute.path, b.absolute.path], fileConverter: _convert));

    expect(added, isTrue, reason: 'có tệp => mở tab Gửi');
    expect(service.state.map((f) => f.name), ['bao-cao.pdf', 'anh chup.png']);
    expect(service.state.map((f) => f.size), [1, 2]);
  });

  test('cờ bắt đầu bằng "-" bị bỏ qua, không thành tệp; đường dẫn không tồn tại bị bỏ qua', () async {
    final a = tao('a.txt', 'x');
    final service = ReduxNotifier.test(redux: SelectedSendingFilesNotifier());

    final added = await service.dispatchAsyncTakeResult(
      LoadSelectionFromArgsAction(
        ['--hidden', '-v', a.absolute.path, '${tmp.path}${Platform.pathSeparator}khong-co.txt'],
        fileConverter: _convert,
      ),
    );

    expect(added, isTrue);
    expect(service.state.map((f) => f.name), ['a.txt']);
  });

  test('--text / -t: đối số kế tiếp là tin nhắn văn bản', () async {
    final service = ReduxNotifier.test(redux: SelectedSendingFilesNotifier());

    final added = await service.dispatchAsyncTakeResult(LoadSelectionFromArgsAction(['--text', 'xin chào', '-t', '  ']));

    expect(added, isTrue);
    expect(service.state, hasLength(1), reason: 'tin nhắn rỗng bị bỏ qua');
    expect(service.state.single.name.endsWith('.txt'), isTrue);
  });

  test('không có tệp hợp lệ => không mở tab Gửi', () async {
    final service = ReduxNotifier.test(redux: SelectedSendingFilesNotifier());

    final added = await service.dispatchAsyncTakeResult(LoadSelectionFromArgsAction(['--hidden']));

    expect(added, isFalse);
    expect(service.state, isEmpty);
  });
}
