fn main() {
    // lotus-share: phiên bản + số build lấy từ app/pubspec.yaml (`version: X.Y.Z+BUILD`) - một nguồn duy nhất cho ứng
    // dụng và CLI; số build dùng để kiểm phiên-ban.json (src/update_check.rs).
    let pubspec = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../app/pubspec.yaml");
    println!("cargo:rerun-if-changed={}", pubspec.display());
    let (version, build) = std::fs::read_to_string(&pubspec)
        .ok()
        .and_then(|s| {
            let line = s.lines().find(|l| l.starts_with("version: "))?;
            let (v, b) = line["version: ".len()..].trim().split_once('+')?;
            Some((v.to_string(), b.parse::<u64>().ok()?))
        })
        .map(|(v, b)| (v, Some(b)))
        .unwrap_or_else(|| (std::env::var("CARGO_PKG_VERSION").unwrap(), None));
    println!("cargo:rustc-env=LOTUS_SHARE_VERSION={version}");
    if let Some(build) = build {
        println!("cargo:rustc-env=LOTUS_SHARE_BUILD={build}");
    }

    // VERSIONINFO metadata for the Windows exe, mirroring app/windows/runner/Runner.rc.
    // Code signing expects ProductName/ProductVersion on all signed binaries.
    if std::env::var_os("CARGO_CFG_WINDOWS").is_some() {
        let mut res = winresource::WindowsResource::new();
        res.set("ProductName", "Lotus Share"); // lotus-share
        res.set("FileDescription", "Lotus Share CLI");
        res.set("CompanyName", "tsudev");
        res.set("OriginalFilename", "lotus-share-cli.exe");
        res.set("InternalName", "lotus-share-cli");
        res.set(
            "LegalCopyright",
            "Copyright (C) 2026 tsudev. LocalSend (C) 2022-2026 Tien Do Nam. Apache-2.0",
        );
        // lotus-share: FileVersion 4 phần = phiên bản sản phẩm + ".0" (VERSIONING: `YY.M.DDNN.0`).
        let parts: Vec<u64> = version.split('.').filter_map(|p| p.parse().ok()).collect();
        if parts.len() == 3 && parts.iter().all(|p| *p <= 0xFFFF) {
            let packed = (parts[0] << 48) | (parts[1] << 32) | (parts[2] << 16);
            res.set_version_info(winresource::VersionInfo::FILEVERSION, packed);
            res.set_version_info(winresource::VersionInfo::PRODUCTVERSION, packed);
            res.set("FileVersion", &format!("{version}.0"));
            res.set("ProductVersion", &version);
        }
        res.compile().expect("failed to compile Windows resources");
    }
}
