// tsudev-lotus: mọi địa chỉ mặc định của bản fork phải thuộc hệ sinh thái tsudev.
import 'package:localsend_app/config/fork_config.dart';
import 'package:test/test.dart';

bool _isTsudev(Uri uri) {
  final host = uri.host;
  if (host == 'tsudev.com' || host.endsWith('.tsudev.com')) {
    return true;
  }
  return host == 'github.com' && uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'tsudev-org';
}

void main() {
  test('kênh ủng hộ chỉ trỏ về hệ tsudev qua HTTPS', () {
    for (final link in forkSupportLinks) {
      final uri = Uri.parse(link.url);
      expect(uri.scheme, 'https', reason: link.url);
      expect(_isTsudev(uri), isTrue, reason: link.url);
    }
  });

  test('liên kết sản phẩm và máy chủ tín hiệu không phụ thuộc localsend.org', () {
    for (final url in [forkHomepageUrl, forkPrivacyUrl, forkRepositoryUrl, forkReleasesUrl, forkEcosystemUrl, ...forkDefaultSignalingServers]) {
      expect(_isTsudev(Uri.parse(url)), isTrue, reason: url);
    }
    for (final url in forkDefaultStunServers) {
      expect(url, isNot(contains('localsend')), reason: url);
    }
  });
}
