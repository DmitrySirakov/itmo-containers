# Берем конкретную версию
FROM jupyterhub/jupyterhub:5

# Под root устанавливаем необходимые пакеты
USER root

# В плохом мы не чистили .deb файлы, а так как после установки 
# они не нужны, стоит явно прописать их отчистку (последние 2 строки RUN)
# Еще в плохом файле установка зависимостей через pip, но установки пакета не было
RUN apt-get update && \
    apt-get install -y \
    python3-dev \
    python3-pip \
    git \
    vim \
    nano \
    curl \
    wget \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Создаем папку под рутом и даем права для пользователя
RUN mkdir -p /home/jovyan/jupyter && chown -R 1000:1000 /home/jovyan

WORKDIR /home/jovyan/jupyter

COPY requirements.txt ./

RUN /srv/venv/bin/pip install --no-cache-dir -r requirements.txt

# Даем права на папку для пользователя и переключаемся на него
RUN chown -R 1000:1000 /home/jovyan
USER 1000

# Вообще это есть в наследуемом докер файле образа, но пусть для читаемости будет
EXPOSE 8000



