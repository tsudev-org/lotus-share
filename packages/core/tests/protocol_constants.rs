//! lotus-share: protocol identity of Lotus Share 2.x.
//!
//! The app passes its own constants (`packages/localsend_isolates/lib/constants.dart`) while the CLI uses the
//! Rust ones; 2.0.0-lotus.6 shipped a CLI on the old multicast group because only the Dart side was changed.
//! Both sides are pinned here so they cannot drift apart again.
#![cfg(feature = "multicast")]

use localsend::multicast::{DEFAULT_MULTICAST_GROUP, DEFAULT_MULTICAST_GROUP_V6, DEFAULT_PORT};
use std::net::{Ipv4Addr, Ipv6Addr};

const DART_CONSTANTS: &str = include_str!("../../localsend_isolates/lib/constants.dart");

fn dart_const(name: &str) -> String {
    let prefix = format!("const {name} = ");
    let line = DART_CONSTANTS
        .lines()
        .find(|l| l.trim_start().starts_with(&prefix))
        .unwrap_or_else(|| panic!("{name} not found in constants.dart"));
    line.trim_start()[prefix.len()..]
        .trim_end_matches(';')
        .trim()
        .trim_matches('\'')
        .to_string()
}

#[test]
fn rust_protocol_constants_are_lotus_share() {
    assert_eq!(DEFAULT_PORT, 53420);
    assert_eq!(DEFAULT_MULTICAST_GROUP, Ipv4Addr::new(224, 0, 0, 168));
    assert_eq!(
        DEFAULT_MULTICAST_GROUP_V6,
        "ff12::1075:5ea0".parse::<Ipv6Addr>().unwrap()
    );
}

#[test]
fn dart_and_rust_protocol_constants_match() {
    assert_eq!(
        dart_const("defaultPort").parse::<u16>().unwrap(),
        DEFAULT_PORT
    );
    assert_eq!(
        dart_const("defaultMulticastGroup")
            .parse::<Ipv4Addr>()
            .unwrap(),
        DEFAULT_MULTICAST_GROUP
    );
}
