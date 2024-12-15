# Используем официальный образ Rust как базовый
FROM rust:1.75 as builder

# Создаем новую директорию для приложения
WORKDIR /usr/src/app

# Копируем файлы Cargo.toml и Cargo.lock
COPY Cargo.toml Cargo.lock ./

# Копируем исходный код
COPY src ./src

# Собираем приложение
RUN cargo build --release

# Используем минимальный образ для запуска
FROM debian:bullseye-slim

# Устанавливаем необходимые зависимости
RUN apt-get update && \
    apt-get install -y openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Копируем исполняемый файл из builder
COPY --from=builder /usr/src/app/target/release/rustweb /usr/local/bin/app

# Открываем порт 8080
EXPOSE 8080

# Запускаем приложение
CMD ["app"]