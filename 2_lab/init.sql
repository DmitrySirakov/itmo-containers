-- Инициализационный скрипт для PostgreSQL
-- Создаем дополнительные таблицы если необходимо
CREATE TABLE IF NOT EXISTS jupyterhub_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

