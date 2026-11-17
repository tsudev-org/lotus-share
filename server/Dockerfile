# Build from the repository root (workspace root):
#   docker build -f server/Dockerfile .
# lotus-share: ảnh gốc ghim digest (đo 18/11/2026; Dependabot docker cập nhật). Đổi thẻ thì đổi cả digest.
FROM rust:1.97@sha256:b1b3c9c0d921d7fa0a6d1f9ec7e4eab87f8c8ec97644c3d791450f131dec813f AS builder

WORKDIR /app

COPY Cargo.toml Cargo.lock ./
COPY packages/core ./packages/core
COPY packages/localsend_isolates/rust ./packages/localsend_isolates/rust
COPY server ./server
COPY cli ./cli

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo build --release -p server && cp target/release/server /server-bin

FROM debian:bookworm@sha256:268fb24c39bca92d326dd83ea3abebe4a3f7751c804ffef23bb6d857dd343ff8 AS runtime

COPY --from=builder /server-bin /server

EXPOSE 3000
ENTRYPOINT ["/server"]
