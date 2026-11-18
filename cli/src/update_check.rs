//! lotus-share: kiểm phiên bản lúc khởi động, giống ứng dụng (`app/lib/util/update_check.dart`,
//! `docs/vi/CAP-NHAT-BAT-BUOC.md`).
//!
//! Đọc `phien-ban.json` với thời hạn ngắn; mất mạng, quá giờ hay tệp sai định dạng đều coi như "không có thông tin" và
//! KHÔNG chặn. Địa chỉ tệp và trang tải về cố định trong mã - không bao giờ lấy URL từ nội dung tệp.

use serde::Deserialize;
use std::time::Duration;

pub const MANIFEST_URL: &str = "https://lotus.tsudev.com/phien-ban.json";
pub const DOWNLOAD_URL: &str = "https://lotus.tsudev.com/tai-ve/";
const TIMEOUT: Duration = Duration::from_secs(3);
/// Tệp phiên bản chỉ vài chục byte; đọc tối đa ngần này để máy chủ lạ không làm đầy bộ nhớ.
const MAX_BODY: usize = 16 * 1024;

/// Số build của CLI (= số sau dấu `+` trong `app/pubspec.yaml`, do `build.rs` đọc).
pub fn current_build() -> Option<u64> {
    option_env!("LOTUS_SHARE_BUILD").and_then(|b| b.parse().ok())
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Manifest {
    pub latest_version: String,
    pub latest_build: u64,
    pub minimum_build: u64,
}

#[derive(Deserialize)]
struct RawManifest {
    schema: u32,
    #[serde(rename = "phienBan")]
    version: String,
    #[serde(rename = "moiNhat")]
    latest: u64,
    #[serde(rename = "toiThieu")]
    minimum: u64,
}

impl Manifest {
    /// Đọc và kiểm chặt như ứng dụng; sai định dạng trả `None` (không chặn ai).
    pub fn parse(body: &str) -> Option<Self> {
        let raw: RawManifest = serde_json::from_str(body).ok()?;
        let version_ok = {
            let parts: Vec<&str> = raw.version.split('.').collect();
            parts.len() == 3
                && parts
                    .iter()
                    .all(|p| !p.is_empty() && p.bytes().all(|b| b.is_ascii_digit()))
        };
        if raw.schema != 1 || !version_ok || raw.minimum < 1 || raw.latest < raw.minimum {
            return None;
        }
        Some(Self {
            latest_version: raw.version,
            latest_build: raw.latest,
            minimum_build: raw.minimum,
        })
    }
}

#[derive(Debug, PartialEq, Eq)]
pub enum Decision {
    UpToDate,
    Optional,
    Required,
}

/// Số build không đọc được (bản tự build ngoài cây mã) thì không chặn.
pub fn decide(current: Option<u64>, manifest: Option<&Manifest>) -> Decision {
    match (current, manifest) {
        (Some(cur), Some(m)) if cur < m.minimum_build => Decision::Required,
        (Some(cur), Some(m)) if cur < m.latest_build => Decision::Optional,
        _ => Decision::UpToDate,
    }
}

async fn fetch() -> Option<Manifest> {
    let _ = rustls::crypto::ring::default_provider().install_default();
    let client = reqwest::Client::builder()
        .timeout(TIMEOUT)
        .connect_timeout(TIMEOUT)
        .redirect(reqwest::redirect::Policy::none())
        .user_agent(concat!("lotus-share-cli/", env!("LOTUS_SHARE_VERSION")))
        .build()
        .ok()?;
    let response = client.get(MANIFEST_URL).send().await.ok()?;
    if !response.status().is_success() {
        return None;
    }
    let body = response.bytes().await.ok()?;
    if body.len() > MAX_BODY {
        return None;
    }
    Manifest::parse(std::str::from_utf8(&body).ok()?)
}

/// Gọi lúc khởi động. Trả `Err` khi bản này thấp hơn mức tối thiểu (main thoát với mã khác 0).
pub async fn check() -> anyhow::Result<()> {
    let manifest = fetch().await;
    match decide(current_build(), manifest.as_ref()) {
        Decision::UpToDate => Ok(()),
        Decision::Optional => {
            let m = manifest.expect("Optional chỉ có khi đọc được tệp phiên bản");
            eprintln!(
                "Đã có Lotus Share {} (bạn đang dùng {}). Tải bản mới: {DOWNLOAD_URL}",
                m.latest_version,
                env!("LOTUS_SHARE_VERSION")
            );
            Ok(())
        }
        Decision::Required => {
            let m = manifest.expect("Required chỉ có khi đọc được tệp phiên bản");
            anyhow::bail!(
                "Bản {} không còn được hỗ trợ: cần cập nhật lên Lotus Share {} để tiếp tục.\n\
                 Tải bản mới: {DOWNLOAD_URL}\n\
                 (Bỏ qua kiểm tra: --khong-kiem-cap-nhat hoặc LOTUS_SHARE_KHONG_KIEM_CAP_NHAT=1)",
                env!("LOTUS_SHARE_VERSION"),
                m.latest_version
            )
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const OK: &str = r#"{"schema":1,"phienBan":"26.11.1801","moiNhat":26111801,"toiThieu":65}"#;

    fn manifest(latest: u64, minimum: u64) -> Manifest {
        Manifest {
            latest_version: "26.11.1801".into(),
            latest_build: latest,
            minimum_build: minimum,
        }
    }

    #[test]
    fn parses_the_published_shape() {
        assert_eq!(Manifest::parse(OK), Some(manifest(26111801, 65)));
        // Tệp đang phát hành ở website phải luôn đọc được.
        let published = include_str!("../../website/public/phien-ban.json");
        assert!(Manifest::parse(published).is_some());
    }

    #[test]
    fn rejects_malformed_manifests() {
        for body in [
            "",
            "not json",
            r#"{"schema":2,"phienBan":"1.0.0","moiNhat":2,"toiThieu":1}"#,
            r#"{"schema":1,"phienBan":"1.0","moiNhat":2,"toiThieu":1}"#,
            r#"{"schema":1,"phienBan":"1.0.x","moiNhat":2,"toiThieu":1}"#,
            r#"{"schema":1,"phienBan":"1.0.0","moiNhat":1,"toiThieu":2}"#,
            r#"{"schema":1,"phienBan":"1.0.0","moiNhat":2,"toiThieu":0}"#,
            r#"{"schema":1,"phienBan":"1.0.0","moiNhat":-1,"toiThieu":1}"#,
            r#"{"schema":1,"phienBan":"1.0.0","moiNhat":"2","toiThieu":1}"#,
        ] {
            assert_eq!(Manifest::parse(body), None, "{body}");
        }
    }

    #[test]
    fn decides_like_the_app() {
        let m = manifest(100, 50);
        assert_eq!(decide(Some(49), Some(&m)), Decision::Required);
        assert_eq!(decide(Some(50), Some(&m)), Decision::Optional);
        assert_eq!(decide(Some(99), Some(&m)), Decision::Optional);
        assert_eq!(decide(Some(100), Some(&m)), Decision::UpToDate);
        assert_eq!(decide(Some(101), Some(&m)), Decision::UpToDate);
        // Không có thông tin (mất mạng) hoặc bản tự build: không chặn.
        assert_eq!(decide(Some(1), None), Decision::UpToDate);
        assert_eq!(decide(None, Some(&m)), Decision::UpToDate);
    }

    #[test]
    fn build_number_comes_from_pubspec() {
        let pubspec = include_str!("../../app/pubspec.yaml");
        let line = pubspec
            .lines()
            .find(|l| l.starts_with("version: "))
            .unwrap();
        let build: u64 = line.rsplit('+').next().unwrap().trim().parse().unwrap();
        assert_eq!(current_build(), Some(build));
        assert_eq!(
            env!("LOTUS_SHARE_VERSION"),
            line["version: ".len()..].split('+').next().unwrap().trim()
        );
    }
}
