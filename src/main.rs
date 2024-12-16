use actix_web::{get, post, web, App, HttpResponse, HttpServer, Responder, Error};
use chrono::Utc;
use lapin::{
    options::BasicPublishOptions,
    BasicProperties,
    Connection,
    ConnectionProperties,
};
use serde_json::json;
use uuid::Uuid;

struct AppState{
    app_name: String,
}

#[get("/")]
async fn index(data: web::Data<AppState>) -> Result<String, Error> {
    let app_name = &data.app_name;

    // Подключение к RabbitMQ
    let addr = "amqp://user:password@rabbitmq:5672/%2f";
    let conn = Connection::connect(
        &addr,
        ConnectionProperties::default()
    ).await.map_err(|e| {
        eprintln!("Connection error: {}", e);
        actix_web::error::ErrorInternalServerError("Failed to connect to RabbitMQ")
    })?;

    let channel = conn.create_channel().await.map_err(|e| {
        eprintln!("Channel error: {}", e);
        actix_web::error::ErrorInternalServerError("Failed to create channel")
    })?;

    // Создаем тестовое сообщение
    let message = json!({
        "message_id": Uuid::new_v4().to_string(),
        "timestamp": Utc::now().format("%Y-%m-%d %H:%M:%S").to_string(),
        "payload": format!("Test message from {}", app_name)
    });

    // Публикуем сообщение
    channel.basic_publish(
        "your_exchange",
        "your_routing_key",
        BasicPublishOptions::default(),
        &serde_json::to_vec(&message).unwrap(),
        BasicProperties::default()
    ).await.map_err(|e| {
        eprintln!("Publish error: {}", e);
        actix_web::error::ErrorInternalServerError("Failed to publish message")
    })?;

    Ok(format!("Hello {}! Message sent to RabbitMQ", app_name))
}

async fn manual_hello() -> impl Responder {
    HttpResponse::Ok().body("Hey there!")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .app_data(web::Data::new(AppState {
                app_name: String::from("Actix Web"),
            }))
            .service(index)
            .route("/hey", web::get().to(manual_hello))
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}