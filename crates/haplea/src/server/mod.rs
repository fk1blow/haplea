use axum::{
    routing::get,
    Router,
    Json,
};
use haplea_common::Result;
use serde_json::{json, Value};

pub async fn start(port: u16) -> Result<()> {
    let app = Router::new()
        .route("/", get(root))
        .route("/health", get(health));

    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{}", port))
        .await
        .map_err(|e| haplea_common::HapleaError::Network(format!("Failed to bind: {}", e)))?;

    println!("🌐 Server listening on http://0.0.0.0:{}", port);

    axum::serve(listener, app)
        .await
        .map_err(|e| haplea_common::HapleaError::Network(format!("Server error: {}", e)))?;

    Ok(())
}

async fn root() -> Json<Value> {
    Json(json!({
        "name": "Haplea",
        "version": "0.1.0",
        "status": "running"
    }))
}

async fn health() -> Json<Value> {
    Json(json!({
        "status": "ok"
    }))
}
