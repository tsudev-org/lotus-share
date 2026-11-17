# Lotus Share

**English** · [Tiếng Việt](README.vi.md)

[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/16860/badge)](https://www.bestpractices.dev/projects/16860)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/tsudev-org/lotus-share/badge)](https://scorecard.dev/viewer/?uri=github.com/tsudev-org/lotus-share)
[![Latest release](https://img.shields.io/github/v/release/tsudev-org/lotus-share?include_prereleases)](https://github.com/tsudev-org/lotus-share/releases/latest)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)

Share files and messages between phones and computers on the same local network (Wi-Fi, LAN) - no Internet, no
account, no relay server. Vietnamese is the default interface language; 60+ other languages are included.

A product of [tsudev](https://tsudev.com). Lotus Share started as a fork of LocalSend 1.18.2 and became an independent
product in 2.0 (own protocol, configuration and identifiers).

- Website: <https://lotus.tsudev.com>
- Downloads: <https://lotus.tsudev.com/tai-ve/> or [GitHub Releases](https://github.com/tsudev-org/lotus-share/releases/latest)
- Platforms: Windows (x64, ARM64), Linux (x64, ARM64: AppImage, tar.gz, APT/RPM at `pkg.tsudev.com`), Android, macOS,
  plus the command-line tool `lotus-share-cli`

## Install

| Channel | Command |
| --- | --- |
| Scoop (Windows) | `scoop bucket add tsudev https://github.com/tsudev-org/scoop-bucket` then `scoop install tsudev/lotus-share` |
| Homebrew (macOS) | `brew install --cask tsudev-org/tap/lotus-share` |
| APT / RPM (Linux) | see <https://lotus.tsudev.com/tai-ve/> (signed repository `pkg.tsudev.com`) |

## Features

| Area | Lotus Share |
| --- | --- |
| Privacy | Files and messages go directly between the two devices; nothing is uploaded. The only Internet request is a public version file checked at start-up ([details](docs/vi/CAP-NHAT-BAT-BUOC.md)) |
| Security | Every device has its own TLS certificate; its SHA-256 fingerprint is its identity. Transfers use mutual TLS; favourite devices are trusted by fingerprint only; PINs are generated with a CSPRNG |
| Protocol | Lotus Share protocol 2 (port 53420, multicast group 224.0.0.168 / ff12::1075:5ea0, `/api/lotus/v2/`). All devices need Lotus Share 2.0 or later; outdated versions are asked to update |
| Supply chain | Every release ships `SHA256SUMS.txt` signed with Sigstore, SLSA build provenance for each file (`gh attestation verify`) and an SPDX SBOM |
| CI gates | CodeQL (Rust, Actions), gitleaks over the full history, OSV vulnerability scan for Rust + Dart, translation and generated-code checks |

Security model: [docs/vi/KIEN-TRUC-BAO-MAT.md](docs/vi/KIEN-TRUC-BAO-MAT.md) (Vietnamese).

## Verify a download

```bash
gh attestation verify lotus-share-<version>-windows-x86-64-setup.exe --repo tsudev-org/lotus-share
sha256sum -c SHA256SUMS.txt --ignore-missing
```

Windows builds are not Authenticode-signed yet; see [CODE_SIGNING.md](CODE_SIGNING.md) for the current status.

## Development

Flutter is pinned in `.fvmrc` (3.47.9); the core (protocol, HTTPS, crypto) is Rust in `packages/core`.

```bash
cd app && flutter pub get && flutter run
flutter analyze && flutter test
(cd packages/core && cargo test --features full)
python3 -I tools/check_i18n_vi.py      # Vietnamese translation completeness
python3 -I tools/osv_scan.py           # dependency vulnerability scan
```

Architecture: [docs/KIEN-TRUC-KY-THUAT.md](docs/KIEN-TRUC-KY-THUAT.md). Contributing: [CONTRIBUTING.md](CONTRIBUTING.md).
Issues labelled [good first issue](https://github.com/tsudev-org/lotus-share/labels/good%20first%20issue) are a good
place to start.

## Reporting security issues

Do not open a public issue. Use private vulnerability reporting as described in [SECURITY.md](SECURITY.md).

## License

Apache License 2.0 - see [LICENSE](LICENSE) and [NOTICE](NOTICE). (c) 2026 tsudev.
