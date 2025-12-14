#!/bin/bash

# Скрипт для очистки ресурсов Kubernetes

echo "Удаляем развертывание JupyterHub из Kubernetes..."

# Удаляем все ресурсы в обратном порядке
echo "Удаляем сервисы..."
kubectl delete -f nginx-service.yml --ignore-not-found=true
kubectl delete -f jupyterhub-service.yml --ignore-not-found=true
kubectl delete -f redis-service.yml --ignore-not-found=true
kubectl delete -f postgres-service.yml --ignore-not-found=true

echo "Удаляем деплойменты..."
kubectl delete -f nginx-deployment.yml --ignore-not-found=true
kubectl delete -f jupyterhub-deployment.yml --ignore-not-found=true
kubectl delete -f redis-deployment.yml --ignore-not-found=true
kubectl delete -f postgres-deployment.yml --ignore-not-found=true

echo "Удаляем PVC..."
kubectl delete -f redis-pvc.yml --ignore-not-found=true
kubectl delete -f postgres-pvc.yml --ignore-not-found=true

echo "Удаляем ConfigMaps и Secrets..."
kubectl delete -f nginx-configmap.yml --ignore-not-found=true
kubectl delete -f jupyterhub-configmap.yml --ignore-not-found=true
kubectl delete -f redis-configmap.yml --ignore-not-found=true
kubectl delete -f postgres-configmap.yml --ignore-not-found=true

kubectl delete -f redis-secret.yml --ignore-not-found=true
kubectl delete -f postgres-secret.yml --ignore-not-found=true

echo "Очистка завершена!"

# Проверяем статус
echo ""
echo "Текущие поды:"
kubectl get pods

echo ""
echo "Текущие сервисы:"
kubectl get services

echo ""
echo "Текущие PVC:"
kubectl get pvc