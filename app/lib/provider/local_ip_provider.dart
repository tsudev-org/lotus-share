import 'dart:async';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:localsend_app/model/state/network_state.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_isolates/util/network_interfaces.dart';
import 'package:logging/logging.dart';
import 'package:network_info_plus/network_info_plus.dart' as plugin;
import 'package:refena_flutter/refena_flutter.dart';

final _logger = Logger('NetworkInfo');

final localIpProvider = ReduxProvider<LocalIpService, NetworkState>((ref) {
  return LocalIpService(
    ref.notifier(settingsProvider),
  );
});

StreamSubscription? _subscription;

class LocalIpService extends ReduxNotifier<NetworkState> {
  final SettingsService _settingsService;

  LocalIpService(this._settingsService);

  @override
  NetworkState init() {
    return const NetworkState(
      localIps: [],
      initialized: false,
    );
  }

  @override
  get initialAction => InitLocalIpAction();
}

/// Fetches the local IP address and registers a listener to update the IP address
class InitLocalIpAction extends ReduxAction<LocalIpService, NetworkState> {
  @override
  NetworkState reduce() {
    if (!kIsWeb) {
      // ignore: discarded_futures
      _subscription?.cancel();

      if (checkPlatform([TargetPlatform.windows])) {
        // https://github.com/localsend/localsend/issues/12
        // https://github.com/localsend/localsend/issues/78
      } else {
        _subscription = Connectivity().onConnectivityChanged.listen((_) async {
          await dispatchAsync(FetchLocalIpAction());
        });
      }
    }

    return state;
  }

  @override
  void after() {
    // ignore: discarded_futures
    dispatchAsync(FetchLocalIpAction());
  }
}

class FetchLocalIpAction extends AsyncReduxAction<LocalIpService, NetworkState> {
  @override
  Future<NetworkState> reduce() async {
    return NetworkState(
      localIps: await _getIp(
        whitelist: notifier._settingsService.state.networkWhitelist,
        blacklist: notifier._settingsService.state.networkBlacklist,
      ),
      initialized: true,
    );
  }
}

Future<List<String>> _getIp({
  required List<String>? whitelist,
  required List<String>? blacklist,
}) async {
  final info = plugin.NetworkInfo();
  String? ip;
  try {
    ip = await info.getWifiIP();
  } catch (e) {
    _logger.warning('Failed to get wifi IP', e);
  }

  final interfaces = await getNetworkInterfaces(
    whitelist: whitelist,
    blacklist: blacklist,
  );
  final nativeResult = interfaces
      .map((interface) => interface.addresses.map((a) => a.address).toList())
      .expand((ip) => ip)
      .where((ip) => !ip.contains(':')) // ignore IPv6 for now
      .toList();

  // lotus-share: card mạng ảo/VPN (WSL, Hyper-V, VirtualBox, Docker, Tailscale...) xếp cuối, để 3 mạng
  // được quét HTTP (StartSmartScan.maxInterfaces) là mạng LAN thật mà điện thoại đang dùng.
  final virtualIps = {
    for (final interface in interfaces)
      if (isVirtualInterfaceName(interface.name))
        for (final a in interface.addresses) a.address,
  };

  final addresses = rankIpAddresses(nativeResult, ip, virtualIps: virtualIps);
  _logger.info('Network state: $addresses');
  return addresses;
}

List<String> rankIpAddresses(List<String> nativeResult, String? thirdPartyResult, {Set<String> virtualIps = const {}}) {
  if (thirdPartyResult == null) {
    // only take the list
    return nativeResult._rankIpAddresses(null, virtualIps);
  } else if (nativeResult.isEmpty) {
    // only take the first IP from third party library
    return [thirdPartyResult];
  } else if (thirdPartyResult.endsWith('.1')) {
    // merge
    return {thirdPartyResult, ...nativeResult}.toList()._rankIpAddresses(null, virtualIps);
  } else {
    // merge but prefer result from third party library
    return {thirdPartyResult, ...nativeResult}.toList()._rankIpAddresses(thirdPartyResult, virtualIps);
  }
}

// lotus-share: tên card mạng ảo/VPN thường gặp (Windows, Linux, macOS). So khớp không phân biệt hoa thường.
final _virtualNamePrefix = RegExp(
  r'^(docker|br-|veth|virbr|vmnet|vboxnet|lxcbr|lxdbr|cni|flannel|podman|tun|tap|wg|utun|ppp|zt|tailscale|ham|awdl|llw|anpi)',
  caseSensitive: false,
);
final _virtualNameContains = RegExp(
  r'(vethernet|hyper-v|wsl|virtualbox|vmware|hamachi|radmin|zerotier|tailscale|wireguard|openvpn|nordlynx|vpn|bluetooth|npcap|loopback|pseudo)',
  caseSensitive: false,
);

/// lotus-share: `true` khi tên card mạng là card ảo/VPN/Bluetooth - điện thoại gần như không bao giờ nằm ở mạng đó.
bool isVirtualInterfaceName(String name) => _virtualNamePrefix.hasMatch(name) || _virtualNameContains.hasMatch(name);

/// lotus-share: dải địa chỉ của VPN/mạng ảo phổ biến: CGNAT/Tailscale 100.64.0.0/10, Hamachi 25.0.0.0/8,
/// Radmin 26.0.0.0/8, link-local 169.254.0.0/16 (không có DHCP).
bool isLikelyVirtualIp(String ip) {
  final parts = ip.split('.').map(int.tryParse).toList();
  if (parts.length != 4 || parts.any((p) => p == null)) {
    return false;
  }
  final a = parts[0]!;
  final b = parts[1]!;
  return (a == 100 && b >= 64 && b <= 127) || a == 25 || a == 26 || (a == 169 && b == 254);
}

/// Sorts Ip addresses with first being the most likely primary local address
/// Currently,
/// - sorts ending with ".1" last
/// - primary is always first
/// - lotus-share: virtual/VPN addresses after everything else
extension ListIpExt on List<String> {
  List<String> _rankIpAddresses(String? primary, Set<String> virtualIps) {
    int score(String ip) {
      if (ip == primary) {
        return 10;
      }
      if (virtualIps.contains(ip) || isLikelyVirtualIp(ip)) {
        return -1;
      }
      return ip.endsWith('.1') ? 0 : 1;
    }

    return sorted((a, b) => score(b).compareTo(score(a)));
  }
}
