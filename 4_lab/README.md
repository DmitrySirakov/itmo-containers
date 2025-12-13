# Лабораторная работа 4: More Kubernetes

## Задание

Развернуть свой собственный сервис в Kubernetes, по аналогии с ЛР 3, используя сервисы из ЛР 2 (JupyterHub) (некоторые файлы просто взяты из ЛР 2).

## Архитектура

В данной работе развернута система JupyterHub со следующими компонентами:

1. **PostgreSQL** - база данных пользователей
   - Использует init контейнер для инициализации
   - Хранит данные в PersistentVolume
   - Имеет liveness и readiness пробы

2. **Redis** - кэш сессий
   - Использует PersistentVolume для хранения данных
   - Имеет liveness и readiness пробы

3. **JupyterHub** - основное приложение
   - Использует кастомный образ, собранный из Dockerfile
   - Имеет liveness и readiness пробы
   - Подключается к PostgreSQL и Redis

4. **Nginx** - reverse proxy
   - Предоставляет внешний доступ к JupyterHub
   - Использует NodePort для доступа из вне кластера

## Требования задания

- Минимум два Deployment (у нас 4: postgres, redis, jupyterhub, nginx)
- Кастомный образ для JupyterHub
- Init контейнер в PostgreSQL
- Volume для PostgreSQL и Redis
- ConfigMap и Secret для конфигурации
- Service для всех сервисов
- Liveness и readiness пробы
- Лейблы для всех ресурсов

## Развертывание

### Автоматическое развертывание (рекомендуется)

```bash
cd itmo-containers/4_lab
chmod +x deploy.sh
./deploy.sh
```

1. Проверит и запустит Minikube
2. Соберет кастомный образ JupyterHub
3. Применит все манифесты в правильном порядке
4. Дождется готовности всех сервисов
5. Выведет URL для доступа к JupyterHub

### Ручное развертывание

#### 1. Сборка кастомного образа JupyterHub

```bash
cd itmo-containers/4_lab
eval $(minikube docker-env)  # Для использования Docker в Minikube
docker build -t jupyterhub-custom:latest .
```

#### 2. Запуск Minikube

```bash
minikube start
minikube addons enable ingress
```

#### 3. Развертывание в Kubernetes

Порядок развертывания важен - сначала зависимости, затем сервисы:

```bash
# Создаем ConfigMaps и Secrets
kubectl apply -f postgres-configmap.yml
kubectl apply -f redis-configmap.yml
kubectl apply -f jupyterhub-configmap.yml
kubectl apply -f nginx-configmap.yml

kubectl apply -f postgres-secret.yml
kubectl apply -f redis-secret.yml

# Создаем PersistentVolumeClaims
kubectl apply -f postgres-pvc.yml
kubectl apply -f redis-pvc.yml

# Развертываем сервисы в порядке зависимостей
kubectl apply -f postgres-deployment.yml
kubectl apply -f postgres-service.yml

kubectl apply -f redis-deployment.yml
kubectl apply -f redis-service.yml

kubectl apply -f jupyterhub-deployment.yml
kubectl apply -f jupyterhub-service.yml

kubectl apply -f nginx-deployment.yml
kubectl apply -f nginx-service.yml
```

Или можно применить все файлы разом:

```bash
kubectl apply -f .
```

### 4. Проверка развертывания

```bash
# Проверяем статус подов
kubectl get pods

# Проверяем сервисы
kubectl get services

# Проверяем PVC
kubectl get pvc

# Смотрим логи при необходимости
kubectl logs -f deployment/postgres
kubectl logs -f deployment/redis
kubectl logs -f deployment/jupyterhub
kubectl logs -f deployment/nginx
```

### 5. Доступ к JupyterHub

После развертывания JupyterHub будет доступен по адресу:

```bash
minikube service nginx-service --url
```

Или напрямую через NodePort:
```
http://<minikube-ip>:30080
```

### 6. Вход в JupyterHub

- Логин: user
- Пароль: 1234

## Скриншоты работы

![Скриншот 1](images/img1.png)
*Развернутые поды в Kubernetes*

(честно я не поняла что такое этот второй юпитер, удалить этот под у меня не получилось и откуда он берется я не поняла)

![Скриншот 2](images/img2.png)
*Сервисы Kubernetes*

![Скриншот 3](images/img3.png)
*JupyterHub интерфейс*

![Скриншот 4](images/img4.png)
*Работа Jupyter Notebook*

## Очистка

Для удаления всех ресурсов:

```bash
kubectl delete -f .
```

Или по отдельности:

```bash
kubectl delete deployment postgres redis jupyterhub nginx
kubectl delete service postgres-service redis-service jupyterhub-service nginx-service
kubectl delete configmap postgres-config redis-config jupyterhub-config nginx-config
kubectl delete secret postgres-secret redis-secret
kubectl delete pvc postgres-pvc redis-pvc

## Устранение неполадок

### Проблема: JupyterHub в состоянии CrashLoopBackOff

Если под JupyterHub постоянно перезапускается со статусом `CrashLoopBackOff` и вы получаете ошибку 502 Bad Gateway при доступе через nginx, выполните следующие шаги:

1. **Проверьте логи пода JupyterHub**:
   ```bash
   kubectl logs -l app=jupyterhub
   ```

2. **Примените исправленную конфигурацию**:
   
   Для Linux/Mac:
   ```bash
   cd itmo-containers/4_lab
   chmod +x fix-jupyterhub.sh
   ./fix-jupyterhub.sh
   ```
   
   Для Windows:
   ```cmd
   cd itmo-containers\4_lab
   fix-jupyterhub.bat
   ```

3. **Если проблема сохраняется**, проверьте события:
   ```bash
   kubectl get events --sort-by=.metadata.creationTimestamp
   ```

4. **Для детальной диагностики** можно зайти в под:
   ```bash
   kubectl exec -it $(kubectl get pods -l app=jupyterhub -o jsonpath='{.items[0].metadata.name}') -- /bin/bash
   ```

### Основные причины проблемы

1. **Неправильная конфигурация JupyterHub** - исправлена в обновленном ConfigMap
2. **Несоответствие портов** - исправлено в конфигурации
3. **Проблемы с подключением к базе данных** - исправлено использованием переменных окружения
4. **Неправильный путь монтирования конфигурации** - исправлено в deployment.yml

### Проверка после исправлений

После применения исправлений проверьте статус подов:
```bash
kubectl get pods
```

JupyterHub должен быть в состоянии `Running` и `1/1` в колонке READY.

Затем проверьте доступ к JupyterHub:
```bash
minikube service nginx-service --url
```