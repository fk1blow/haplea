use serde::{Deserialize, Serialize};

/// Common types shared across the application

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Recipe {
    pub title: String,
    pub ingredients: Vec<String>,
    pub instructions: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServiceInfo {
    pub name: String,
    pub port: u16,
    pub address: String,
}
