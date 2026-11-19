//! lotus-share: bộ mẫu thông điệp giao thức Lotus v2 (`docs/giao-thuc-mau/`, đặc tả `docs/GIAO-THUC-LOTUS-V2.md`)
//! phải khớp kiểu dữ liệu thật của lõi: đọc được VÀ ghi lại ra đúng JSON đó. Client ngoài (nếu có) đối chiếu với
//! các tệp mẫu này; đổi DTO mà quên đổi mẫu (hoặc ngược lại) là test đỏ.
#![cfg(all(feature = "http", feature = "multicast"))]

use localsend::http::dto_v2::{
    InfoResponseDtoV2, PrepareUploadRequestDtoV2, PrepareUploadResponseDtoV2, RegisterDtoV2,
    RegisterResponseDtoV2,
};
use localsend::model::discovery::{MulticastMessageV2, PROTOCOL_VERSION_V2};
use serde::{de::DeserializeOwned, Serialize};
use serde_json::Value;
use std::path::PathBuf;

fn sample(name: &str) -> Value {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../docs/giao-thuc-mau")
        .join(name);
    serde_json::from_str(
        &std::fs::read_to_string(&path).unwrap_or_else(|e| panic!("{}: {e}", path.display())),
    )
    .unwrap_or_else(|e| panic!("{name}: JSON sai: {e}"))
}

/// Đọc mẫu bằng kiểu thật rồi ghi lại: phải ra đúng JSON ban đầu (không thiếu, không thừa trường).
fn round_trip<T: DeserializeOwned + Serialize>(name: &str) -> T {
    let json = sample(name);
    let dto: T = serde_json::from_value(json.clone())
        .unwrap_or_else(|e| panic!("{name}: lõi không đọc được: {e}"));
    assert_eq!(
        serde_json::to_value(&dto).unwrap(),
        json,
        "{name}: lõi ghi ra JSON khác mẫu"
    );
    dto
}

#[test]
fn register_samples_match_core() {
    let req: RegisterDtoV2 = round_trip("register-request.json");
    assert_eq!(req.version, PROTOCOL_VERSION_V2);
    round_trip::<RegisterResponseDtoV2>("register-response.json");
    round_trip::<InfoResponseDtoV2>("info-response.json");
}

#[test]
fn prepare_upload_samples_match_core() {
    let req: PrepareUploadRequestDtoV2 = round_trip("prepare-upload-request.json");
    for (id, file) in &req.files {
        assert_eq!(id, &file.id, "khóa của `files` phải trùng `id` của tệp");
    }
    let res: PrepareUploadResponseDtoV2 = round_trip("prepare-upload-response.json");
    assert!(res.files.keys().all(|id| req.files.contains_key(id)));
}

#[test]
fn multicast_sample_matches_core() {
    let mut json = sample("multicast.json");
    // `announce` do lớp gửi multicast thêm vào (xem multicast::tests), không thuộc MulticastMessageV2.
    assert_eq!(
        json.as_object_mut().unwrap().remove("announce"),
        Some(Value::Bool(true))
    );
    let msg: MulticastMessageV2 = serde_json::from_value(json.clone()).unwrap();
    assert_eq!(serde_json::to_value(&msg).unwrap(), json);
    assert_eq!(msg.port, 53420);
}

#[test]
fn error_sample_shape() {
    let json = sample("error-response.json");
    let obj = json.as_object().unwrap();
    assert_eq!(obj.len(), 1);
    assert!(obj["message"].is_string());
}

#[test]
fn fingerprints_in_samples_are_uppercase_sha256_hex() {
    for name in [
        "multicast.json",
        "register-request.json",
        "register-response.json",
        "info-response.json",
    ] {
        let fp = sample(name)["fingerprint"].as_str().unwrap().to_string();
        assert_eq!(fp.len(), 64, "{name}");
        assert!(
            fp.bytes()
                .all(|b| b.is_ascii_digit() || (b'A'..=b'F').contains(&b)),
            "{name}"
        );
    }
}
