use clap::Parser;

#[derive(Debug, Parser)]
#[command(name = "haplea")]
#[command(about = "A multi-feature Rust application with mDNS, HTTP server, and markdown parsing")]
pub struct Config {
    /// Enable mDNS service discovery
    #[arg(long, default_value_t = true)]
    pub enable_discovery: bool,

    /// Enable HTTP server
    #[arg(long, default_value_t = true)]
    pub enable_server: bool,

    /// HTTP server port
    #[arg(short, long, default_value_t = 3000)]
    pub port: u16,

    /// Service name for mDNS
    #[arg(long, default_value = "haplea")]
    pub service_name: String,

    /// Instance name for this node (defaults to hostname)
    #[arg(long)]
    pub instance_name: Option<String>,
}
