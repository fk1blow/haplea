mod config;
mod discovery;
mod server;

use std::sync::Arc;

use clap::Parser;
use config::Config;
use discovery::DiscoveryEvent;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let config = Config::parse();

    println!("Haplea v{:?}", config);

    // Generate instance name if not provided
    let instance_name = config.instance_name.clone().unwrap_or_else(|| {
        hostname::get()
            .ok()
            .and_then(|h| h.into_string().ok())
            .unwrap_or_else(|| {
                format!(
                    "haplea-{}",
                    uuid::Uuid::new_v4().to_string()[..8].to_string()
                )
            })
    });

    println!("🚀 Starting Haplea...");
    println!("📛 Instance: {}", instance_name);
    println!("🔌 Port: {}", config.port);

    // Initialize discovery service
    if config.enable_discovery {
        println!("🔍 mDNS service discovery enabled");
        // let discovery_service = discovery::DiscoveryService::new()?;
        let discovery_service = Arc::new(discovery::DiscoveryService::new()?);

        // Advertise this instance
        discovery_service
            .advertise(&instance_name, config.port)
            .await?;

        // haha i can do this XD
        discovery::DiscoveryService::start_health_check(Arc::clone(&discovery_service));

        // Start browsing for peers
        let mut event_rx = discovery_service.browse().await?;

        // Spawn task to handle discovery events
        tokio::spawn(async move {
            while let Some(event) = event_rx.recv().await {
                match event {
                    DiscoveryEvent::PeerDiscovered(peer) => {
                        println!(
                            "🤝 New peer: {} ({}:{})",
                            peer.instance_name, peer.hostname, peer.port
                        );
                    }
                    DiscoveryEvent::PeerRemoved(instance) => {
                        println!("👋 Peer left: {}", instance);
                    }
                }
            }
        });
    }

    // Start HTTP server if enabled
    if config.enable_server {
        println!("🌐 HTTP server enabled on port {}", config.port);
        tokio::spawn(async move {
            if let Err(e) = server::start(config.port).await {
                eprintln!("Server error: {}", e);
            }
        });
    }

    // Wait for Ctrl+C
    println!("✨ Ready! Press Ctrl+C to exit");
    tokio::signal::ctrl_c().await?;
    println!("👋 Shutting down...");

    Ok(())
}
