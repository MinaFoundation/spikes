use axum::{
    body::{to_bytes, Body},
    extract::Request,
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};

use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Payload {
    pub data: Value,
}

#[tokio::main]
async fn main() {
    // initialize tracing
    tracing_subscriber::fmt::init();

    let (prometheus_layer, metric_handle) = axum_prometheus::PrometheusMetricLayer::pair();

    // build our application routes
    let app = Router::new()
        .route("/", get(root))
        .route("/submit/stats", post(post_to_stdout))
        .route("/health", get(health))
        .route("/metrics", get(|| async move { metric_handle.render() }))
        .layer(prometheus_layer);

    // Run the server
    let addr = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    tracing::info!("listening on {:?}", addr);
    axum::serve(addr, app).await.unwrap();
}

// health handler that returns a json response
async fn health() -> impl IntoResponse {
    Json(json!({
        "status": "OK"
    }))
}

// Handler for root route
async fn root() -> &'static str {
    "Payload inspector service"
}

async fn post_to_stdout(payload: Request) -> impl IntoResponse {
    let (parts, body) = payload.into_parts();
    tracing::info!("{:?}", parts);
    let bytes = to_bytes(body, usize::MAX).await.unwrap();
    let body = std::str::from_utf8(&bytes).unwrap();
    let req: Value = json!(body);
    tracing::info!("{}", req);
}
