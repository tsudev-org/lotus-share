#!/usr/bin/env bash
# lotus-share: xóa keychain tạm và khóa API App Store Connect khỏi máy chạy CI (gọi ở bước `if: always()`).
set -uo pipefail
security delete-keychain "${RUNNER_TEMP:?}/lotus-ky.keychain-db" 2>/dev/null || true
rm -rf "$HOME/.appstoreconnect/private_keys" "$RUNNER_TEMP"/AuthKey_*.p8 2>/dev/null || true
