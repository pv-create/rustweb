CREATE TABLE IF NOT EXISTS your_database.queue_messages
(
    message_id String,
    timestamp DateTime,
    payload String
) ENGINE = RabbitMQ
SETTINGS 
    rabbitmq_host_port = 'rabbitmq:5672',
    rabbitmq_username = 'admin',
    rabbitmq_password = 'admin',
    rabbitmq_exchange_name = 'your_exchange',
    rabbitmq_format = 'JSONEachRow',
    rabbitmq_routing_key = 'your_routing_key',
    rabbitmq_queue_base = 'your_queue';

-- Создайте материализованную таблицу для хранения данных
CREATE TABLE IF NOT EXISTS your_database.messages
(
    message_id String,
    timestamp DateTime,
    payload String
) ENGINE = MergeTree()
ORDER BY (timestamp, message_id);

-- Создайте материализованное представление для автоматической вставки данных
CREATE MATERIALIZED VIEW IF NOT EXISTS your_database.rabbitmq_mv
TO your_database.messages
AS SELECT * FROM your_database.queue_messages;