import 'package:localsend_app/provider/local_ip_provider.dart';
import 'package:test/test.dart';

void main() {
  group('rankIpAddresses', () {
    test('should only sort list if no primary', () {
      expect(rankIpAddresses(['123.456', '222.1', '321.222'], null), ['123.456', '321.222', '222.1']);
    });

    test('should only take primary', () {
      expect(rankIpAddresses([], '123.123'), ['123.123']);
    });

    test('should sort primary first', () {
      expect(rankIpAddresses(['123.456', '222.1', '321.222'], '123.123'), ['123.123', '123.456', '321.222', '222.1']);
    });

    test('should sort primary first and remove duplicates', () {
      expect(rankIpAddresses(['123.456', '123.123', '222.1', '222.1', '321.222'], '123.123'), ['123.123', '123.456', '321.222', '222.1']);
    });
  });

  // lotus-share: card mạng ảo/VPN xếp cuối để quét đúng mạng LAN thật.
  group('rankIpAddresses virtual', () {
    test('should rank virtual interfaces after real ones', () {
      expect(
        rankIpAddresses(['172.29.64.1', '192.168.1.20', '100.101.5.7'], null, virtualIps: {'172.29.64.1'}),
        ['192.168.1.20', '172.29.64.1', '100.101.5.7'],
      );
    });

    test('should rank virtual below gateway-like addresses', () {
      expect(rankIpAddresses(['25.1.2.3', '10.0.0.1', '10.0.0.5'], null), ['10.0.0.5', '10.0.0.1', '25.1.2.3']);
    });

    test('primary from wifi plugin stays first', () {
      expect(rankIpAddresses(['172.29.64.1', '192.168.1.20'], '192.168.1.20', virtualIps: {'172.29.64.1'}), ['192.168.1.20', '172.29.64.1']);
    });
  });

  group('isVirtualInterfaceName', () {
    test('detects common virtual adapters', () {
      for (final name in [
        'vEthernet (WSL (Hyper-V firewall))',
        'vEthernet (Default Switch)',
        'VirtualBox Host-Only Network',
        'VMware Network Adapter VMnet8',
        'docker0',
        'br-1a2b3c',
        'tailscale0',
        'Tailscale',
        'ZeroTier One [abc]',
        'utun3',
        'wg0',
        'Bluetooth Network Connection',
        'Radmin VPN',
      ]) {
        expect(isVirtualInterfaceName(name), isTrue, reason: name);
      }
    });

    test('keeps real adapters', () {
      for (final name in ['Wi-Fi', 'Ethernet', 'wlan0', 'eth0', 'en0', 'wlp2s0', 'enp3s0', 'ap0', 'swlan0', 'rmnet_data0']) {
        expect(isVirtualInterfaceName(name), isFalse, reason: name);
      }
    });
  });
}
