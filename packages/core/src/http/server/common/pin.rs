use crate::http::server::common::error::AppError;
use hyper::StatusCode;
use lru::LruCache;
use std::collections::HashMap;
use std::net::{IpAddr, Ipv6Addr};
use tokio::sync::Mutex;

/// Maximum failed PIN attempts per IP before requests are blocked with 429.
const MAX_PIN_ATTEMPTS: u32 = 3;

/// Checks the `pin` query parameter against the required PIN (if any).
pub(crate) async fn check_pin(
    required_pin: Option<&str>,
    pin_attempts: &Mutex<LruCache<IpAddr, u32>>,
    query: &HashMap<String, String>,
    ip: IpAddr,
) -> Result<(), AppError> {
    let Some(required_pin) = required_pin else {
        return Ok(());
    };

    // tsudev-lotus: đếm lần sai theo "chủ thể" thay vì từng địa chỉ - xem `attempt_key`.
    let ip = attempt_key(ip);
    let mut attempts = pin_attempts.lock().await;
    let count = attempts.get(&ip).copied().unwrap_or(0);
    if count >= MAX_PIN_ATTEMPTS {
        return Err(AppError::Message(
            StatusCode::TOO_MANY_REQUESTS,
            "Too many requests".to_string(),
        ));
    }

    match query.get("pin") {
        // tsudev-lotus: so sánh thời gian hằng, không lộ độ dài tiền tố đúng qua thời gian phản hồi.
        Some(pin) if constant_time_eq(pin.as_bytes(), required_pin.as_bytes()) => {
            attempts.pop(&ip);
            Ok(())
        }
        Some(_) => {
            attempts.put(ip, count + 1);
            Err(AppError::Message(
                StatusCode::UNAUTHORIZED,
                "Invalid PIN".to_string(),
            ))
        }
        None => Err(AppError::Message(
            StatusCode::UNAUTHORIZED,
            "PIN required".to_string(),
        )),
    }
}

/// tsudev-lotus: khóa dùng để đếm số lần nhập PIN sai.
///
/// Một máy trong LAN tự sinh được vô số địa chỉ IPv6 trong khối /64 của mình (SLAAC, địa chỉ tạm thời), nên đếm
/// theo từng địa chỉ IPv6 cho phép đoán PIN không giới hạn bằng cách đổi địa chỉ. Gom IPv6 theo /64 chặn việc
/// đó. Địa chỉ IPv4 ánh xạ trong IPv6 (`::ffff:a.b.c.d`) quy về IPv4 để hai dạng không được đếm riêng.
fn attempt_key(ip: IpAddr) -> IpAddr {
    match ip {
        IpAddr::V4(_) => ip,
        IpAddr::V6(v6) => match v6.to_ipv4_mapped() {
            Some(v4) => IpAddr::V4(v4),
            None => {
                let s = v6.segments();
                IpAddr::V6(Ipv6Addr::new(s[0], s[1], s[2], s[3], 0, 0, 0, 0))
            }
        },
    }
}

/// tsudev-lotus: so sánh hai chuỗi byte trong thời gian chỉ phụ thuộc độ dài, không phụ thuộc nội dung.
fn constant_time_eq(a: &[u8], b: &[u8]) -> bool {
    if a.len() != b.len() {
        return false;
    }
    a.iter().zip(b).fold(0u8, |acc, (x, y)| acc | (x ^ y)) == 0
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::num::NonZeroUsize;

    fn query(pin: &str) -> HashMap<String, String> {
        HashMap::from([("pin".to_string(), pin.to_string())])
    }

    fn attempts() -> Mutex<LruCache<IpAddr, u32>> {
        Mutex::new(LruCache::new(NonZeroUsize::new(200).unwrap()))
    }

    #[test]
    fn constant_time_eq_matches_only_equal_input() {
        assert!(constant_time_eq(b"123456", b"123456"));
        assert!(!constant_time_eq(b"123456", b"123457"));
        assert!(!constant_time_eq(b"12345", b"123456"));
        assert!(constant_time_eq(b"", b""));
    }

    #[test]
    fn attempt_key_groups_ipv6_by_64_and_unmaps_ipv4() {
        let a: IpAddr = "fd00:1:2:3:aaaa::1".parse().unwrap();
        let b: IpAddr = "fd00:1:2:3:bbbb::2".parse().unwrap();
        let other_net: IpAddr = "fd00:1:2:4::1".parse().unwrap();
        assert_eq!(attempt_key(a), attempt_key(b));
        assert_ne!(attempt_key(a), attempt_key(other_net));

        let mapped: IpAddr = "::ffff:192.168.1.7".parse().unwrap();
        let v4: IpAddr = "192.168.1.7".parse().unwrap();
        assert_eq!(attempt_key(mapped), v4);
        assert_eq!(attempt_key(v4), v4);
    }

    #[tokio::test]
    async fn rotating_ipv6_addresses_in_same_64_is_still_blocked() {
        let store = attempts();
        for host in 1..=MAX_PIN_ATTEMPTS {
            let ip: IpAddr = format!("fd00::{host:x}").parse().unwrap();
            assert!(check_pin(Some("424242"), &store, &query("000000"), ip)
                .await
                .is_err());
        }
        // Địa chỉ mới cùng /64, kể cả đúng PIN, vẫn bị chặn 429.
        let fresh: IpAddr = "fd00::ffff".parse().unwrap();
        let err = check_pin(Some("424242"), &store, &query("424242"), fresh)
            .await
            .unwrap_err();
        assert!(matches!(
            err,
            AppError::Message(StatusCode::TOO_MANY_REQUESTS, _)
        ));
    }

    #[tokio::test]
    async fn correct_pin_passes_and_resets_counter() {
        let store = attempts();
        let ip: IpAddr = "192.168.1.20".parse().unwrap();
        assert!(check_pin(Some("424242"), &store, &query("1"), ip)
            .await
            .is_err());
        assert!(check_pin(Some("424242"), &store, &query("424242"), ip)
            .await
            .is_ok());
        assert!(store.lock().await.get(&ip).is_none());
        assert!(check_pin(None, &store, &HashMap::new(), ip).await.is_ok());
    }
}
