mod app;
mod banner;
mod device_list;
mod picker;
mod sanitize;
mod send_task;
mod slots;
mod storage;
mod ui;
mod util;

use clap::{ArgAction, Parser, Subcommand};
use std::path::PathBuf;

// lotus-share: khung trợ giúp tiếng Việt (thay tiêu đề mặc định tiếng Anh của clap).
const HELP_TEMPLATE: &str = "{about-with-newline}\nCách dùng: {usage}\n\n{all-args}{after-help}";

#[derive(Subcommand)]
pub enum Command {
    /// Gửi một hay nhiều tệp, thư mục, hoặc một tin nhắn văn bản
    #[command(help_template = HELP_TEMPLATE, next_help_heading = "Tùy chọn", disable_help_flag = true)]
    Send {
        /// Thiết bị nhận: tên thiết bị chính xác hoặc địa chỉ IP
        #[arg(long, value_name = "TARGET")]
        to: Option<String>,

        /// Gửi văn bản này dưới dạng tin nhắn thay vì tệp; `-` đọc từ stdin
        #[arg(long, value_name = "TEXT", requires = "to", conflicts_with = "paths")]
        text: Option<String>,

        /// Tệp hoặc thư mục cần gửi (thư mục được gom đệ quy)
        #[arg(value_name = "PATH", required_unless_present = "text", num_args = 1..)]
        paths: Vec<PathBuf>,
    },
}

/// lotus-share CLI - gửi/nhận tệp trong mạng nội bộ
#[derive(Parser)]
#[command(
    name = "lotus-share-cli",
    version,
    about,
    after_help = HELP_SECTIONS,
    help_template = HELP_TEMPLATE,
    subcommand_help_heading = "Lệnh",
    next_help_heading = "Tùy chọn",
    disable_help_flag = true,
    disable_version_flag = true,
    disable_help_subcommand = true
)]
pub struct Args {
    /// In trợ giúp
    #[arg(short = 'h', long, action = ArgAction::Help, global = true)]
    help: Option<bool>,

    /// In phiên bản
    #[arg(short = 'V', long, action = ArgAction::Version)]
    version: Option<bool>,

    /// Tên thiết bị hiển thị với máy khác [mặc định: config.toml, không có thì tên máy]
    #[arg(long, env = "LOTUS_SHARE_ALIAS")]
    pub alias: Option<String>,

    /// Cổng máy chủ HTTP [mặc định: config.toml, không có thì 53420]
    #[arg(long, env = "LOTUS_SHARE_PORT")]
    pub port: Option<u16>,

    /// Thư mục lưu tệp nhận được [mặc định: config.toml, không có thì thư mục Tải về]
    #[arg(long, env = "LOTUS_SHARE_DESTINATION")]
    pub destination: Option<PathBuf>,

    #[command(subcommand)]
    pub command: Option<Command>,
}

// lotus-share: trợ giúp tiếng Việt.
const HELP_SECTIONS: &str = "Sự kiện:\n  \
                             D      Tìm thiết bị\n  \
                             S      Gửi tệp\n  \
                             R      Nhận tệp\n\
                             \nPhím tắt:\n  \
                             1-9    Gửi tệp tới thiết bị có số đó\n  \
                             D      Xem thiết bị đã ghép đôi và đã tìm thấy\n  \
                             W+S    Bật/tắt chia sẻ qua liên kết: trình duyệt tải tệp qua HTTP thường\n  \
                             W+R    Bật/tắt nhận qua liên kết: trình duyệt tải tệp lên qua HTTP thường\n  \
                             Y/N/P  Chấp nhận / Từ chối / Chấp nhận và ghép đôi yêu cầu đến\n  \
                             Ctrl+C Hủy lượt truyền hoặc yêu cầu hiện tại, hoặc thoát khi rảnh\n \
                             \nBiến môi trường:\n  \
                             XDG_CONFIG_HOME, LOTUS_SHARE_ALIAS, LOTUS_SHARE_PORT, LOTUS_SHARE_DESTINATION";

fn main() -> anyhow::Result<()> {
    let args = Args::parse();
    tokio::runtime::Runtime::new()?.block_on(app::run(args))
}

#[cfg(test)]
mod tests {
    use super::{Args, Command};
    use clap::Parser;
    use std::path::PathBuf;

    #[test]
    fn accepts_mixed_send_paths() {
        let args = Args::try_parse_from(["lotus-share-cli", "send", "one.txt", "two.txt", "backup"])
            .unwrap();

        let Some(Command::Send { to, paths, .. }) = args.command else {
            panic!("expected the send command");
        };
        assert_eq!(to, None);
        assert_eq!(
            paths,
            vec![
                PathBuf::from("one.txt"),
                PathBuf::from("two.txt"),
                PathBuf::from("backup"),
            ]
        );
    }

    #[test]
    fn accepts_a_destination_alias() {
        let args =
            Args::try_parse_from(["lotus-share-cli", "send", "--to", "Cute Tomato", "one.txt"])
                .unwrap();

        let Some(Command::Send { to, paths, .. }) = args.command else {
            panic!("expected the send command");
        };
        assert_eq!(to.as_deref(), Some("Cute Tomato"));
        assert_eq!(paths, vec![PathBuf::from("one.txt")]);
    }

    #[test]
    fn accepts_a_destination_ip() {
        let args =
            Args::try_parse_from(["lotus-share-cli", "send", "--to", "192.168.27.26", "one.txt"])
                .unwrap();

        let Some(Command::Send { to, paths, .. }) = args.command else {
            panic!("expected the send command");
        };
        assert_eq!(to.as_deref(), Some("192.168.27.26"));
        assert_eq!(paths, vec![PathBuf::from("one.txt")]);
    }

    #[test]
    fn requires_at_least_one_send_path() {
        assert!(Args::try_parse_from(["lotus-share-cli", "send"]).is_err());
    }

    #[test]
    fn accepts_a_text_message() {
        let args =
            Args::try_parse_from(["lotus-share-cli", "send", "--to", "Phone", "--text", "hello"])
                .unwrap();

        let Some(Command::Send { to, text, paths }) = args.command else {
            panic!("expected the send command");
        };
        assert_eq!(to.as_deref(), Some("Phone"));
        assert_eq!(text.as_deref(), Some("hello"));
        assert!(paths.is_empty());
    }

    #[test]
    fn rejects_text_together_with_paths() {
        assert!(
            Args::try_parse_from([
                "lotus-share-cli",
                "send",
                "--to",
                "Phone",
                "--text",
                "hello",
                "one.txt"
            ])
            .is_err()
        );
    }

    #[test]
    fn requires_a_destination_for_text() {
        assert!(Args::try_parse_from(["lotus-share-cli", "send", "--text", "hello"]).is_err());
    }

    #[test]
    fn accepts_interactive_mode_without_a_command() {
        let args = Args::try_parse_from(["lotus-share-cli"]).unwrap();

        assert!(args.command.is_none());
    }
}
