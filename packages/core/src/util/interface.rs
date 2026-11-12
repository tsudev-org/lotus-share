//! Enumeration and filtering of the local network interfaces.

use std::net::{IpAddr, Ipv4Addr};

/// Restricts the network interfaces that are used.
///
/// Filters are matched against every address of an interface. A `*` matches one
/// or more characters that are not a `.`, so `192.168.1.*` matches
/// `192.168.1.42` but not `192.168.10.1`.
#[derive(Clone, Debug, Default)]
pub struct InterfaceFilter {
    /// When set, only interfaces with a matching address are used.
    pub whitelist: Option<Vec<String>>,

    /// When set, interfaces with a matching address are skipped.
    pub blacklist: Option<Vec<String>>,
}

impl InterfaceFilter {
    /// Returns `true` when an interface with the given addresses must not be used.
    pub fn is_ignored(&self, addresses: &[IpAddr]) -> bool {
        if let Some(whitelist) = &self.whitelist {
            if !any_address_matches(addresses, whitelist) {
                return true;
            }
        }

        if let Some(blacklist) = &self.blacklist {
            if any_address_matches(addresses, blacklist) {
                return true;
            }
        }

        false
    }
}

/// Returns `true` when at least one of `addresses` matches at least one of `patterns`.
fn any_address_matches(addresses: &[IpAddr], patterns: &[String]) -> bool {
    addresses.iter().any(|address| {
        let address = address.to_string();
        patterns
            .iter()
            .any(|pattern| matches_ip_filter(pattern, &address))
    })
}

/// Matches the whole address against a filter pattern.
fn matches_ip_filter(pattern: &str, address: &str) -> bool {
    match pattern.split_once('*') {
        None => pattern == address,
        Some((prefix, rest)) => {
            let Some(remainder) = address.strip_prefix(prefix) else {
                return false;
            };

            // `*` must consume at least one character and may not cross a `.`.
            let max_len = remainder
                .find('.')
                .unwrap_or(remainder.len())
                .min(remainder.len());

            (1..=max_len).any(|len| matches_ip_filter(rest, &remainder[len..]))
        }
    }
}

/// A local IPv4 address that a multicast socket can be bound to.
#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct LocalInterfaceV4 {
    /// The name of the interface, only used for logging.
    pub(crate) name: String,

    /// The IPv4 address of the interface, used to join the multicast group.
    pub(crate) address: Ipv4Addr,

    /// lotus-share: the directed broadcast address of the subnet (e.g. `192.168.1.255`), if the
    /// subnet has one. Announcements are also sent there, because many Wi-Fi access points,
    /// routers with IGMP snooping and Android devices without a multicast lock drop multicast.
    pub(crate) broadcast: Option<Ipv4Addr>,
}

/// A local interface that an IPv6 multicast socket can be bound to.
///
/// IPv6 group membership is joined per interface rather than per address, so a
/// single socket per interface covers all of its IPv6 addresses.
#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct LocalInterfaceV6 {
    /// The name of the interface, only used for logging.
    pub(crate) name: String,

    /// The index of the interface, used to join the multicast group.
    pub(crate) index: u32,
}

/// The local network interfaces that multicast sockets can be bound to.
pub(crate) struct LocalInterfaces {
    /// One entry per IPv4 address of an interface.
    pub(crate) v4: Vec<LocalInterfaceV4>,

    /// One entry per interface that has at least one IPv6 address.
    pub(crate) v6: Vec<LocalInterfaceV6>,
}

/// Returns the addresses of all non-loopback interfaces that pass `filter`.
pub(crate) fn local_interfaces(filter: &InterfaceFilter) -> std::io::Result<LocalInterfaces> {
    struct Entry {
        name: String,
        index: Option<u32>,
        addresses: Vec<IpAddr>,
        // lotus-share: broadcast address per IPv4 address, same order as the V4 entries of `addresses`.
        broadcasts: Vec<Option<Ipv4Addr>>,
    }

    // Filters apply to an interface as a whole, so all of its addresses have to
    // be known before any of them can be accepted.
    let mut by_name: Vec<Entry> = Vec::new();
    for interface in if_addrs::get_if_addrs()? {
        if interface.is_loopback() {
            continue;
        }

        // lotus-share: keep the broadcast address of each IPv4 address.
        let broadcast = match &interface.addr {
            if_addrs::IfAddr::V4(v4) => Some(
                v4.broadcast
                    .or_else(|| directed_broadcast(v4.ip, v4.prefixlen))
                    .filter(|b| is_usable_broadcast(*b, v4.ip, v4.prefixlen)),
            ),
            if_addrs::IfAddr::V6(_) => None,
        };

        match by_name
            .iter_mut()
            .find(|entry| entry.name == interface.name)
        {
            Some(entry) => {
                entry.index = entry.index.or(interface.index);
                entry.addresses.push(interface.ip());
                if let Some(broadcast) = broadcast {
                    entry.broadcasts.push(broadcast);
                }
            }
            None => by_name.push(Entry {
                name: interface.name.clone(),
                index: interface.index,
                addresses: vec![interface.ip()],
                broadcasts: broadcast.into_iter().collect(),
            }),
        }
    }

    let mut result = LocalInterfaces {
        v4: Vec::new(),
        v6: Vec::new(),
    };
    for entry in by_name {
        if filter.is_ignored(&entry.addresses) {
            tracing::debug!(
                "Ignoring network interface {} ({:?})",
                entry.name,
                entry.addresses
            );
            continue;
        }

        let mut has_v6 = false;
        let mut broadcasts = entry.broadcasts.iter();
        for address in &entry.addresses {
            match address {
                // IPv4 group membership is joined per address.
                IpAddr::V4(address) => result.v4.push(LocalInterfaceV4 {
                    name: entry.name.clone(),
                    address: *address,
                    broadcast: broadcasts.next().copied().flatten(),
                }),
                IpAddr::V6(_) => has_v6 = true,
            }
        }

        if has_v6 {
            match entry.index {
                Some(index) => result.v6.push(LocalInterfaceV6 {
                    name: entry.name,
                    index,
                }),
                // Joining an IPv6 group requires the interface index.
                None => tracing::debug!(
                    "Interface {} has no index, not using it for IPv6 multicast",
                    entry.name
                ),
            }
        }
    }

    Ok(result)
}

/// The IPv4 addresses of all usable (non-loopback, unfiltered) local
/// interfaces, e.g. the subnets to fall back-scan when multicast is silent.
pub fn local_interface_addresses(filter: &InterfaceFilter) -> std::io::Result<Vec<Ipv4Addr>> {
    Ok(local_interfaces(filter)?
        .v4
        .into_iter()
        .map(|interface| interface.address)
        .collect())
}

/// lotus-share: the directed broadcast address of `ip/prefixlen` (host bits all set).
fn directed_broadcast(ip: Ipv4Addr, prefixlen: u8) -> Option<Ipv4Addr> {
    if prefixlen == 0 || prefixlen > 32 {
        return None;
    }
    let mask = u32::MAX.checked_shl(32 - u32::from(prefixlen)).unwrap_or(0);
    Some(Ipv4Addr::from(u32::from(ip) | !mask))
}

/// lotus-share: only real subnet broadcasts are used. `/31` and `/32` (point-to-point links,
/// most VPNs) have none, and the limited broadcast `255.255.255.255` would leave through an
/// arbitrary interface on some platforms.
fn is_usable_broadcast(broadcast: Ipv4Addr, ip: Ipv4Addr, prefixlen: u8) -> bool {
    (1..=30).contains(&prefixlen)
        && broadcast != ip
        && !broadcast.is_unspecified()
        && broadcast != Ipv4Addr::BROADCAST
        && !broadcast.is_multicast()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn ip(address: &str) -> IpAddr {
        address.parse().unwrap()
    }

    #[test]
    fn test_directed_broadcast() {
        let ip = |s: &str| s.parse::<Ipv4Addr>().unwrap();
        assert_eq!(
            directed_broadcast(ip("192.168.1.42"), 24),
            Some(ip("192.168.1.255"))
        );
        assert_eq!(
            directed_broadcast(ip("10.1.2.3"), 8),
            Some(ip("10.255.255.255"))
        );
        assert_eq!(
            directed_broadcast(ip("172.20.5.9"), 20),
            Some(ip("172.20.15.255"))
        );
        assert_eq!(directed_broadcast(ip("192.168.1.42"), 0), None);
    }

    #[test]
    fn test_usable_broadcast() {
        let ip = |s: &str| s.parse::<Ipv4Addr>().unwrap();
        assert!(is_usable_broadcast(
            ip("192.168.1.255"),
            ip("192.168.1.42"),
            24
        ));
        assert!(is_usable_broadcast(
            ip("169.254.255.255"),
            ip("169.254.3.4"),
            16
        ));
        // Point-to-point links and host routes have no broadcast address.
        assert!(!is_usable_broadcast(ip("10.0.0.1"), ip("10.0.0.0"), 31));
        assert!(!is_usable_broadcast(ip("100.64.0.7"), ip("100.64.0.7"), 32));
        assert!(!is_usable_broadcast(
            ip("255.255.255.255"),
            ip("192.168.1.42"),
            24
        ));
    }

    #[test]
    fn test_exact_pattern() {
        assert!(matches_ip_filter("192.168.1.42", "192.168.1.42"));
        assert!(!matches_ip_filter("192.168.1.42", "192.168.1.43"));
    }

    #[test]
    fn test_wildcard_does_not_cross_dots() {
        assert!(matches_ip_filter("192.168.1.*", "192.168.1.42"));
        assert!(!matches_ip_filter("192.168.1.*", "192.168.1.42.1"));
        assert!(!matches_ip_filter("192.168.*", "192.168.1.42"));
        assert!(matches_ip_filter("192.168.*.42", "192.168.1.42"));
    }

    #[test]
    fn test_wildcard_requires_at_least_one_character() {
        assert!(!matches_ip_filter("192.168.1.*", "192.168.1."));
    }

    #[test]
    fn test_multiple_wildcards() {
        assert!(matches_ip_filter("192.*.*.42", "192.168.1.42"));
        assert!(!matches_ip_filter("192.*.*.42", "192.168.1.43"));
    }

    #[test]
    fn test_ipv6_wildcard() {
        assert!(matches_ip_filter("1::1:*:3", "1::1:2:3"));
        assert!(!matches_ip_filter("1::1:*:3", "1::1:2:4"));
    }

    #[test]
    fn test_no_filter_accepts_everything() {
        let filter = InterfaceFilter::default();
        assert!(!filter.is_ignored(&[ip("192.168.1.42")]));
    }

    #[test]
    fn test_whitelist_skips_non_matching_interfaces() {
        let filter = InterfaceFilter {
            whitelist: Some(vec!["192.168.1.*".to_string()]),
            blacklist: None,
        };

        assert!(!filter.is_ignored(&[ip("192.168.1.42")]));
        assert!(filter.is_ignored(&[ip("10.0.0.1")]));
        // A single matching address is enough to keep the interface.
        assert!(!filter.is_ignored(&[ip("10.0.0.1"), ip("192.168.1.42")]));
    }

    #[test]
    fn test_blacklist_skips_matching_interfaces() {
        let filter = InterfaceFilter {
            whitelist: None,
            blacklist: Some(vec!["10.0.0.*".to_string()]),
        };

        assert!(!filter.is_ignored(&[ip("192.168.1.42")]));
        assert!(filter.is_ignored(&[ip("10.0.0.1")]));
        // A single matching address is enough to drop the interface.
        assert!(filter.is_ignored(&[ip("192.168.1.42"), ip("10.0.0.1")]));
    }

    #[test]
    fn test_blacklist_wins_over_whitelist() {
        let filter = InterfaceFilter {
            whitelist: Some(vec!["192.168.*.*".to_string()]),
            blacklist: Some(vec!["192.168.1.*".to_string()]),
        };

        assert!(!filter.is_ignored(&[ip("192.168.2.42")]));
        assert!(filter.is_ignored(&[ip("192.168.1.42")]));
    }
}
