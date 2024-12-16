<h1>Rust web app</h1>

<h2>Start app<h2>
docker build -t rustweb 
docker run -p 8080:8080 rustweb




docker-compose up
docker-compose down
# Пересобрать образы
docker-compose build

# Посмотреть логи
docker-compose logs

# Посмотреть статус сервисов
docker-compose ps

# Перезапустить сервисы
docker-compose restart

# Остановить и удалить все контейнеры и сети
docker-compose down --volumes