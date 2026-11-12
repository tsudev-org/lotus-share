import 'dart:io';

import 'package:localsend_app/util/update_check.dart';
import 'package:test/test.dart';

void main() {
  group('UpdateManifest.tryParse', () {
    test('đọc tệp hợp lệ', () {
      final m = UpdateManifest.tryParse('{"schema":1,"phienBan":"2.0.0","moiNhat":66,"toiThieu":65}')!;
      expect(m.latestVersion, '2.0.0');
      expect(m.latestBuild, 66);
      expect(m.minimumBuild, 65);
    });

    test('từ chối tệp sai định dạng (không chặn ai)', () {
      for (final body in [
        '',
        'not json',
        '[]',
        '{"schema":2,"phienBan":"2.0.0","moiNhat":65,"toiThieu":65}',
        '{"schema":1,"phienBan":"2.0","moiNhat":65,"toiThieu":65}',
        '{"schema":1,"phienBan":"2.0.0","moiNhat":"65","toiThieu":65}',
        '{"schema":1,"phienBan":"2.0.0","moiNhat":64,"toiThieu":65}',
        '{"schema":1,"phienBan":"2.0.0","moiNhat":65,"toiThieu":0}',
      ]) {
        expect(UpdateManifest.tryParse(body), isNull, reason: body);
      }
    });
  });

  group('decideUpdate', () {
    test('thấp hơn tối thiểu thì bắt buộc', () {
      expect(decideUpdate(currentBuild: 64, minimumBuild: 65, latestBuild: 66), UpdateDecision.required);
    });
    test('đủ tối thiểu nhưng có bản mới thì không bắt buộc', () {
      expect(decideUpdate(currentBuild: 65, minimumBuild: 65, latestBuild: 66), UpdateDecision.optional);
    });
    test('mới nhất', () {
      expect(decideUpdate(currentBuild: 66, minimumBuild: 65, latestBuild: 66), UpdateDecision.upToDate);
      expect(decideUpdate(currentBuild: 70, minimumBuild: 65, latestBuild: 66), UpdateDecision.upToDate);
    });
    test('không biết số build hoặc không có thông tin thì không chặn', () {
      expect(decideUpdate(currentBuild: null, minimumBuild: 65, latestBuild: 66), UpdateDecision.upToDate);
      expect(decideUpdate(currentBuild: 1, minimumBuild: null, latestBuild: null), UpdateDecision.upToDate);
    });
  });

  group('fetchUpdateManifest', () {
    late HttpServer server;
    late String body;
    late int status;

    setUp(() async {
      body = '{"schema":1,"phienBan":"2.0.0","moiNhat":65,"toiThieu":65}';
      status = 200;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        request.response.statusCode = status;
        request.response.write(body);
        await request.response.close();
      });
    });

    tearDown(() => server.close(force: true));

    Uri uri() => Uri.parse('http://127.0.0.1:${server.port}/phien-ban.json');

    test('tải được tệp', () async {
      final m = await fetchUpdateManifest(uri: uri());
      expect(m?.minimumBuild, 65);
    });

    test('lỗi HTTP hoặc nội dung lạ trả null', () async {
      status = 404;
      expect(await fetchUpdateManifest(uri: uri()), isNull);
      status = 200;
      body = 'x' * 20000;
      expect(await fetchUpdateManifest(uri: uri()), isNull);
    });

    test('không kết nối được trả null', () async {
      final closed = uri();
      await server.close(force: true);
      expect(await fetchUpdateManifest(uri: closed, timeout: const Duration(seconds: 2)), isNull);
    });
  });
}
