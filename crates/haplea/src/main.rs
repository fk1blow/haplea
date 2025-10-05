mod config;
mod discovery;
mod server;

use clap::Parser;
use config::Config;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let config = Config::parse();

    println!("🚀 Starting Haplea...");
    println!("Config: {:?}", config);

    // TODO: Initialize components based on config
    if config.enable_discovery {
        println!("🔍 mDNS service discovery enabled");
        // discovery::start(&config).await?;
    }

    if config.enable_server {
        println!("🌐 HTTP server enabled on port {}", config.port);
        // server::start(&config).await?;
    }

    Ok(())
}
