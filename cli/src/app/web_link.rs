//! "Share via link" (W+S) and "Receive via link" (W+R): serving the web
//! pages so browsers can download from or upload to this device.
//!
//! Browsers cannot verify the self-signed certificate, so while a link is
//! active the server is restarted without TLS and the links use plain
//! `http://`. Toggling off restarts the encrypted server.

use super::{App, sending};
use crate::picker::PickerTarget;
use crate::ui::Category;
use crate::util;
use localsend::http::server::web::{
    WebConfig, WebDownloadConfig, WebDownloadEvent, WebMode as CoreWebMode,
};
use localsend::http::server::{ServerConfigV2, start_with_port};
use localsend::model::transfer::FileContent;
use qrcode::render::unicode;
use qrcode::{EcLevel, QrCode};
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::oneshot;

/// The active web link mode. Only one at a time: the download page would
/// shadow the upload page at `/`.
pub(super) enum WebMode {
    /// "Share via link": the served files' paths, keyed by file ID.
    Share { paths: HashMap<String, PathBuf> },

    /// "Receive via link": browsers upload through the regular v2 endpoints,
    /// so incoming requests go through the usual Y/N/P prompt.
    Receive,
}

impl App {
    pub(super) async fn toggle_web_share(&mut self) {
        match &self.web {
            Some(WebMode::Share { .. }) => {
                self.disable_web(Category::Send, "Chia sẻ qua liên kết")
                    .await;
                return;
            }
            Some(WebMode::Receive) => {
                self.ui.log(
                    Category::Send,
                    "Nhận qua liên kết đang bật, nhấn W+R để tắt trước",
                );
                return;
            }
            None => {}
        }
        if self.pending.is_some() || self.receive.is_some() {
            self.ui.log(
                Category::Send,
                "Chia sẻ qua liên kết: không bật được khi đang nhận tệp (máy chủ sẽ phải khởi động lại)",
            );
            return;
        }
        match self.preselected.is_empty() {
            true => self.open_picker(PickerTarget::WebShare),
            false => self.enable_web_share(self.preselected.clone()).await,
        }
    }

    pub(super) async fn toggle_web_receive(&mut self) {
        match &self.web {
            Some(WebMode::Receive) => {
                self.disable_web(Category::Receive, "Nhận qua liên kết")
                    .await;
                return;
            }
            Some(WebMode::Share { .. }) => {
                self.ui.log(
                    Category::Receive,
                    "Chia sẻ qua liên kết đang bật, nhấn W+S để tắt trước",
                );
                return;
            }
            None => {}
        }
        if self.pending.is_some() || self.receive.is_some() {
            self.ui.log(
                Category::Receive,
                "Nhận qua liên kết: không bật được khi đang nhận tệp (máy chủ sẽ phải khởi động lại)",
            );
            return;
        }
        if let Err(err) = self.restart_server(CoreWebMode::Upload).await {
            self.ui.log(
                Category::Receive,
                &format!("Nhận qua liên kết: không khởi động lại được máy chủ: {err:#}"),
            );
            self.restore_encrypted_server().await;
            return;
        }
        self.web = Some(WebMode::Receive);
        let mut text = format!(
            "Đã bật nhận qua liên kết, mã hóa đang TẮT\nMở trong trình duyệt để tải tệp lên máy này:\n{}\n",
            self.web_links(),
        );
        if let Some(qr) = self.web_qr() {
            text.push_str(&format!("\n{qr}\n"));
        }
        text.push_str("Nhấn W+R lần nữa để tắt.\n\n");
        self.ui.log(Category::Receive, &text);
    }

    /// Restarts the server in plain-HTTP mode offering `picked` for download
    /// and prints the links to open in a browser.
    pub(super) async fn enable_web_share(&mut self, picked: Vec<PathBuf>) {
        let (files, paths, total_bytes) = sending::collect_files(&mut self.ui, picked);
        if files.is_empty() {
            self.ui.log(Category::Send, "Chưa chọn tệp nào");
            return;
        }
        let count = files.len();
        let web_mode = CoreWebMode::Download(WebDownloadConfig {
            files,
            pin: None,
            event_tx: self.web_tx.clone(),
        });
        if let Err(err) = self.restart_server(web_mode).await {
            self.ui.log(
                Category::Send,
                &format!("Chia sẻ qua liên kết: không khởi động lại được máy chủ: {err:#}"),
            );
            self.restore_encrypted_server().await;
            return;
        }
        self.web = Some(WebMode::Share { paths });
        let mut text = format!(
            "Đã bật chia sẻ qua liên kết: {count} tệp{} ({}), mã hóa đang TẮT\nMở trong trình duyệt:\n{}\n",
            if count == 1 { "" } else { "s" },
            util::format_bytes(total_bytes),
            self.web_links(),
        );
        if let Some(qr) = self.web_qr() {
            text.push_str(&format!("\n{qr}\n"));
        }
        text.push_str("Nhấn W+S lần nữa để ngừng chia sẻ.\n\n");
        self.ui.log(Category::Send, &text);
    }

    /// The plain-HTTP links of the running server, one per line.
    fn web_links(&self) -> String {
        match crate::banner::listening_lines(&self.server.local_addresses(), "http") {
            lines if lines.is_empty() => " - (không tìm thấy giao diện mạng)".to_string(),
            lines => lines.join("\n"),
        }
    }

    /// The first link as a QR code in half-block characters, scannable
    /// straight from the terminal. `None` when there is no address.
    ///
    /// Only the modules are drawn, in the terminal's foreground color; the
    /// rest stays the plain background. On dark terminals that inverts the
    /// code (light on dark), which phone scanners accept.
    fn web_qr(&self) -> Option<String> {
        let address = self.server.local_addresses().into_iter().next()?;
        let code =
            QrCode::with_error_correction_level(format!("http://{address}"), EcLevel::L).ok()?;
        Some(code.render::<unicode::Dense1x2>().quiet_zone(false).build())
    }

    async fn disable_web(&mut self, category: Category, feature: &str) {
        self.web = None;
        match self.restart_server(CoreWebMode::Disabled).await {
            Ok(()) => self
                .ui
                .log(category, &format!("Đã tắt {feature}, mã hóa đã bật lại")),
            Err(err) => self.ui.log(
                category,
                &format!("Đã tắt {feature}, nhưng không khởi động lại được máy chủ: {err:#}"),
            ),
        }
    }

    /// Best effort after a failed plain-HTTP restart: get back to the normal
    /// encrypted server.
    async fn restore_encrypted_server(&mut self) {
        if let Err(err) = self.restart_server(CoreWebMode::Disabled).await {
            self.ui.log(
                Category::Send,
                &format!("Không khôi phục được máy chủ mã hóa: {err:#}"),
            );
        }
    }

    /// Stops the running server and starts a fresh one on the same port:
    /// the normal encrypted one, or, when a web page is active, a plain-HTTP
    /// one that additionally serves that web page.
    async fn restart_server(&mut self, web_mode: CoreWebMode) -> anyhow::Result<()> {
        if let Some(stop_tx) = self.server_stop_tx.take() {
            let _ = stop_tx.send(());
        }
        let _ = tokio::time::timeout(Duration::from_secs(3), self.server.wait_stopped()).await;

        let identity = &self.storage.identity;
        let tls_config = match web_mode {
            CoreWebMode::Disabled => Some(identity.tls_config()),
            _ => None,
        };
        let (stop_tx, stop_rx) = oneshot::channel::<()>();
        let server = start_with_port(
            identity.port,
            tls_config,
            identity.client_info(),
            None,
            Some(ServerConfigV2 {
                pin: None,
                verify_checksums: true,
                event_tx: self.server_tx.clone(),
            }),
            WebConfig {
                mode: web_mode,
                ..WebConfig::default()
            },
            stop_rx,
        )
        .await?;
        self.server = Arc::new(server);
        self.server_stop_tx = Some(stop_tx);
        Ok(())
    }

    pub(super) fn handle_web_event(&mut self, event: WebDownloadEvent) {
        match event {
            WebDownloadEvent::PrepareDownload {
                ip,
                user_agent,
                decision_tx,
                ..
            } => {
                // For now every browser is accepted without asking.
                let _ = decision_tx.send(true);
                let agent = user_agent
                    .map(|agent| format!(" ({agent})"))
                    .unwrap_or_default();
                self.ui.log(
                    Category::Send,
                    &format!("Web: {ip} đã mở liên kết chia sẻ{agent}"),
                );
            }
            WebDownloadEvent::FileDownload {
                session_id,
                file_id,
                file,
                content_tx,
            } => {
                let path = match &self.web {
                    Some(WebMode::Share { paths }) => paths.get(&file_id),
                    _ => None,
                };
                let Some(path) = path else {
                    // Sharing ended: dropping the responder fails the download.
                    return;
                };
                let _ = content_tx.send(FileContent::Path(path.clone()));
                self.ui.log(
                    Category::Send,
                    &format!("Web: {session_id} downloads {}", file.file_name),
                );
            }
        }
    }
}
