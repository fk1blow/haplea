use haplea_common::Result;
use mdns_sd::{ServiceDaemon, ServiceEvent, ServiceInfo};
use std::sync::Arc;
use std::{collections::HashMap, time::Duration};
use tokio::sync::{mpsc, RwLock};

const SERVICE_TYPE: &str = "_haplea._tcp.local.";

#[derive(Debug, Clone)]
pub struct PeerInfo {
    pub instance_name: String,
    pub hostname: String,
    pub port: u16,
    pub addresses: Vec<std::net::IpAddr>,
}

pub enum DiscoveryEvent {
    PeerDiscovered(PeerInfo),
    PeerRemoved(String),
}

pub struct DiscoveryService {
    daemon: ServiceDaemon,
    peers: Arc<RwLock<HashMap<String, PeerInfo>>>,
}

impl DiscoveryService {
    pub fn new() -> Result<Self> {
        let daemon = ServiceDaemon::new().map_err(|e| {
            haplea_common::HapleaError::Network(format!("Failed to create mDNS daemon: {}", e))
        })?;

        Ok(Self {
            daemon,
            peers: Arc::new(RwLock::new(HashMap::new())),
        })
    }

    pub async fn advertise(&self, instance_name: &str, port: u16) -> Result<()> {
        // Get hostname, fallback to instance_name if not available
        let hostname = hostname::get()
            .ok()
            .and_then(|h| h.into_string().ok())
            .unwrap_or_else(|| instance_name.to_string());

        // Hostname must end with .local. for mDNS - strip any existing .local suffix first
        let hostname_clean = hostname
            .trim_end_matches(".local.")
            .trim_end_matches(".local");
        let hostname_local = format!("{}.local.", hostname_clean);

        let service_info = ServiceInfo::new(
            SERVICE_TYPE,
            instance_name,
            &hostname_local,
            (), // Let mdns-sd auto-detect the IP address
            port,
            None,
        )
        .map_err(|e| {
            haplea_common::HapleaError::Network(format!("Failed to create service info: {}", e))
        })?
        .enable_addr_auto(); // Enable automatic address detection

        self.daemon.register(service_info).map_err(|e| {
            haplea_common::HapleaError::Network(format!("Failed to register service: {}", e))
        })?;

        println!(
            "📡 Advertising as: {} ({}:{}) on {}",
            instance_name, hostname_local, port, SERVICE_TYPE
        );
        Ok(())
    }

    pub async fn browse(&self) -> Result<mpsc::UnboundedReceiver<DiscoveryEvent>> {
        let (tx, rx) = mpsc::unbounded_channel();
        let peers = Arc::clone(&self.peers);

        let receiver = self.daemon.browse(SERVICE_TYPE).map_err(|e| {
            haplea_common::HapleaError::Network(format!("Failed to browse services: {}", e))
        })?;

        println!("🔍 Browsing for peers on {}", SERVICE_TYPE);

        tokio::spawn(async move {
            while let Ok(event) = receiver.recv_async().await {
                match event {
                    ServiceEvent::ServiceResolved(info) => {
                        let peer_info = PeerInfo {
                            instance_name: info.get_fullname().to_string(),
                            hostname: info.get_hostname().to_string(),
                            port: info.get_port(),
                            addresses: info.get_addresses().iter().copied().collect(),
                        };

                        println!(
                            "✅ Peer discovered: {} at {}:{}",
                            peer_info.instance_name, peer_info.hostname, peer_info.port
                        );

                        let instance_name = peer_info.instance_name.clone();
                        peers
                            .write()
                            .await
                            .insert(instance_name.clone(), peer_info.clone());

                        let _ = tx.send(DiscoveryEvent::PeerDiscovered(peer_info));
                    }
                    ServiceEvent::ServiceRemoved(_, fullname) => {
                        println!("❌ Peer removed: {}", fullname);
                        peers.write().await.remove(&fullname);
                        let _ = tx.send(DiscoveryEvent::PeerRemoved(fullname));
                    }
                    _ => {}
                }
            }
        });

        Ok(rx)
    }

    pub async fn get_peers(&self) -> Vec<PeerInfo> {
        self.peers.read().await.values().cloned().collect()
    }

    // New method: Remove stale peers
    pub fn start_health_check(self: Arc<Self>) {
        let peers = Arc::clone(&self.peers); // Pattern from line 78!

        tokio::spawn(async move {
            let mut interval = tokio::time::interval(Duration::from_secs(30));

            loop {
                interval.tick().await;

                // Get peer list, drop lock
                let peer_list: Vec<String> = peers.read().await.keys().cloned().collect();

                // Check each peer (no lock held during network I/O!)
                for instance_name in peer_list {
                    let peers_clone = Arc::clone(&peers);

                    tokio::spawn(async move {
                        if !Self::is_peer_alive(&instance_name).await {
                            peers_clone.write().await.remove(&instance_name);
                            println!("🗑️  Removed stale peer: {}", instance_name);
                        }
                    });
                }
            }
        });
    }

    async fn is_peer_alive(instance_name: &str) -> bool {
        // Implement health check (HTTP ping, etc.)
        true
    }
}
