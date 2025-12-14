#!/bin/bash

# Скрипт для развертывания JupyterHub в Kubernetes

echo "Начинаем развертывание JupyterHub в Kubernetes."

# Проверяем, запущен ли minikube
if ! minikube status > /dev/null 2>&1; then
    echo "Запускаем Minikube."
    minikube start
    minikube addons enable ingress
fi

# Сборка кастомного образа JupyterHub
echo "Собираем кастомный образ JupyterHub."
eval $(minikube docker-env)
docker build -t jupyterhub-custom:latest .

# Применяем манифесты в правильном порядке
echo "Создаем ConfigMaps и Secrets."
kubectl apply -f postgres-configmap.yml
kubectl apply -f redis-configmap.yml
kubectl apply -f jupyterhub-configmap.yml
kubectl apply -f nginx-configmap.yml

kubectl apply -f postgres-secret.yml
kubectl apply -f redis-secret.yml
kubectl apply -f jupyterhub-secret.yml

echo "Создаем PersistentVolumeClaims."
kubectl apply -f postgres-pvc.yml
kubectl apply -f redis-pvc.yml

# Проверяем статус PVC
echo "Проверяем статус PersistentVolumeClaims..."
kubectl get pvc

echo "Развертываем PostgreSQL."
kubectl apply -f postgres-deployment.yml
kubectl apply -f postgres-service.yml

echo "Проверяем статус развертывания PostgreSQL..."
kubectl get deployment postgres
kubectl get pods -l app=postgres

echo "Ожидаем готовности PostgreSQL."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s

echo "Развертываем Redis."
kubectl apply -f redis-deployment.yml
kubectl apply -f redis-service.yml

echo "Проверяем статус развертывания Redis..."
kubectl get deployment redis
kubectl get pods -l app=redis

echo "Ожидаем готовности Redis."
kubectl wait --for=condition=ready pod -l app=redis --timeout=300s

echo "Развертываем JupyterHub."
kubectl apply -f jupyterhub-deployment.yml
kubectl apply -f jupyterhub-service.yml

echo "Проверяем статус развертывания JupyterHub..."
kubectl get deployment jupyterhub
kubectl get pods -l app=jupyterhub

echo "Ожидаем готовности JupyterHub."
kubectl wait --for=condition=ready pod -l app=jupyterhub --timeout=300s

echo "Развертываем Nginx."
kubectl apply -f nginx-deployment.yml
kubectl apply -f nginx-service.yml

echo "Проверяем статус развертывания Nginx..."
kubectl get deployment nginx
kubectl get pods -l app=nginx

echo "Ожидаем готовности Nginx."
kubectl wait --for=condition=ready pod -l app=nginx --timeout=300s

echo "Развертывание завершено!"
echo ""
echo "Проверяем статус подов:"
kubectl get pods

echo ""
echo "Проверяем PersistentVolumeClaims:"
kubectl get pvc

echo ""
echo "Проверяем сервисы:"
kubectl get services

echo ""
echo "Проверяем события для диагностики возможных проблем:"
kubectl get events --sort-by=.metadata.creationTimestamp

echo ""
echo "URL для доступа к JupyterHub:"
minikube service nginx-service --url

echo ""
echo "Для доступа к JupyterHub используйте любые логин и пароль"

bash