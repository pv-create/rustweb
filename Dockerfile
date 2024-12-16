# Используем официальный образ Rust как базовый
FROM rust:1.75 as builder

# Создаем новую директорию для приложения
WORKDIR /usr/src/app

# Устанавливаем musl-tools для статической сборки
RUN apt-get update && \
    apt-get install -y musl-tools && \
    rustup target add aarch64-unknown-linux-musl

# Копируем файлы Cargo.toml и Cargo.lock
COPY Cargo.toml Cargo.lock ./

# Копируем исходный код
COPY src ./src

# Собираем приложение статически
RUN cargo build --release --target aarch64-unknown-linux-musl

# Используем минимальный образ для ARM64
FROM arm64v8/debian:bullseye-slim

# Копируем исполняемый файл из builder
COPY --from=builder /usr/src/app/target/aarch64-unknown-linux-musl/release/rustweb /usr/local/bin/app

# Открываем порт 8080
EXPOSE 8080

# Запускаем приложение
CMD ["app"]