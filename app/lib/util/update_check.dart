import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

final _logger = Logger('UpdateCheck');

/// Tệp phiên bản do website phát hành (nguồn `website/public/phien-ban.json`). Địa chỉ cố định trong ứng dụng; liên kết
/// tải về cũng cố định ([updateDownloadUrl]) - không bao giờ lấy URL từ nội dung tệp, nên tệp bị sửa cũng không dẫn
/// người dùng tới nơi khác.
const updateManifestUrl = 'https://lotus.tsudev.com/phien-ban.json';
const updateDownloadUrl = 'https://lotus.tsudev.com/tai-ve/';

/// Nội dung tệp phiên bản đã kiểm.
class UpdateManifest {
  /// Tên phiên bản mới nhất để hiển thị, vd "2.0.0".
  final String latestVersion;

  /// Số build của bản mới nhất.
  final int latestBuild;

  /// Số build thấp nhất còn được dùng. Bản thấp hơn bị chặn tới khi cập nhật.
  final int minimumBuild;

  const UpdateManifest({
    required this.latestVersion,
    required this.latestBuild,
    required this.minimumBuild,
  });

  /// Đọc và kiểm chặt; sai định dạng thì trả `null` (coi như không có thông tin, không chặn ai).
  static UpdateManifest? tryParse(String body) {
    try {
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic> || json['schema'] != 1) {
        return null;
      }
      final version = json['phienBan'];
      final latest = json['moiNhat'];
      final minimum = json['toiThieu'];
      if (version is! String || !RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
        return null;
      }
      if (latest is! int || minimum is! int || minimum < 1 || latest < minimum) {
        return null;
      }
      return UpdateManifest(latestVersion: version, latestBuild: latest, minimumBuild: minimum);
    } catch (_) {
      return null;
    }
  }
}

enum UpdateDecision {
  /// Đang dùng bản mới nhất (hoặc không có thông tin).
  upToDate,

  /// Có bản mới hơn, không bắt buộc.
  optional,

  /// Bản đang dùng thấp hơn mức tối thiểu: phải cập nhật mới dùng tiếp.
  required,
}

/// Quyết định theo số build hiện tại, [minimumBuild] (lớn nhất từng biết, kể cả đã lưu từ lần trước) và [latestBuild].
/// Số build không đọc được (bản tự build) thì không chặn.
UpdateDecision decideUpdate({
  required int? currentBuild,
  required int? minimumBuild,
  required int? latestBuild,
}) {
  if (currentBuild == null) {
    return UpdateDecision.upToDate;
  }
  if (minimumBuild != null && currentBuild < minimumBuild) {
    return UpdateDecision.required;
  }
  if (latestBuild != null && currentBuild < latestBuild) {
    return UpdateDecision.optional;
  }
  return UpdateDecision.upToDate;
}

/// Tải tệp phiên bản. Không có mạng/Internet, quá giờ, sai định dạng: trả `null` (ứng dụng chạy bình thường - đây là
/// ứng dụng mạng nội bộ, thường dùng khi không có Internet).
Future<UpdateManifest?> fetchUpdateManifest({
  @visibleForTesting Uri? uri,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final client = HttpClient()
    ..connectionTimeout = timeout
    ..findProxy = HttpClient.findProxyFromEnvironment;
  try {
    final request = await client.getUrl(uri ?? Uri.parse(updateManifestUrl)).timeout(timeout);
    request.followRedirects = false;
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close().timeout(timeout);
    if (response.statusCode != HttpStatus.ok) {
      _logger.info('Update manifest: HTTP ${response.statusCode}');
      return null;
    }
    // Tệp chỉ vài trăm byte; giới hạn để không đọc nội dung lạ quá lớn.
    final bytes = <int>[];
    await for (final chunk in response.timeout(timeout)) {
      bytes.addAll(chunk);
      if (bytes.length > 16 * 1024) {
        return null;
      }
    }
    return UpdateManifest.tryParse(utf8.decode(bytes, allowMalformed: true));
  } catch (e) {
    _logger.info('Update manifest unavailable: $e');
    return null;
  } finally {
    client.close(force: true);
  }
}
