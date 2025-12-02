# Лабораторная работа 2: Docker Compose JupyterHub

## Требования задания

- + Минимум 3 сервиса: 5 сервисов (db-init, postgres, redis, jupyterhub, nginx)
- + Минимум 1 init сервис: `db-init` (одноразовый)
- + Минимум 2 app сервиса: `postgres`, `redis`, `jupyterhub`, `nginx`
- + Автоматическая сборка образа: JupyterHub собирается из `Dockerfile`
- + Именование образа: `jupyterhub-custom:latest`
- + Жесткое именование контейнеров: `container_name` указан для всех
- + Минимум один с `depends_on`: все app-сервисы имеют зависимости
- + Минимум один с `volume`: все сервисы используют volumes
- + Минимум один с проброшенными портами: nginx (80, 443)
- + Минимум один с `command` и/или `entrypoint`: все сервисы
- + Минимум один с `healthcheck`: postgres, redis, jupyterhub, nginx
- + Все env-переменные в `.env` файле
- + Явно указана network: `jupyterhub-network`

## Установка и запуск

### 1. Создайте файл .env
(для удобства уже есть в репе .env файл)
```bash
cd /Users/dmitrysirakov/itmo-containers/2_lab
cp env.template .env
```

### 2. Запустите проект

```bash
docker-compose up -d
```

### 3. Доступ к JupyterHub

После запуска JupyterHub будет доступен по адресам:
- HTTP: http://localhost:8080
- HTTPS: https://localhost:8443

**Вход в систему:**
- Логин: **любой** (например: `user`, `admin`, `test123`)
- Пароль: **любой** (можно оставить пустым или ввести что угодно)

### 4. Ответы на вопросы 

Можно ли ограничивать ресурсы (CPU / RAM) для сервисов в docker-compose.yml?

- Да, как сделано у нас в nginx, но есть нюанс - что это работает по-честному через Swarm и поле deploy игнорируется при стандартном docker compose up.. 

Как запустить только один (или несколько) сервисов из docker-compose.yml

- Общий синтаксис, как говорили на лекции - `docker compose up -d <name_container>` - один из вариантов, можно перечислить несколько контейнеров через запятую, можно без -d и тд