#!/bin/bash
# Uso: ./scripts/deploy-env.sh <staging|production>

ENV=$1

if [ -z "$ENV" ]; then
    echo "Error: Debes especificar el entorno (staging o production)."
    echo "Uso: ./scripts/deploy-env.sh <staging|production>"
    exit 1
fi

if [ "$ENV" != "staging" ] && [ "$ENV" != "production" ]; then
    echo "Error: Entorno invalido. Usa 'staging' o 'production'."
    exit 1
fi

echo "=== Desplegando en Namespace: $ENV ==="

# 1. Aplicar todos los manifiestos base sobre el namespace correspondiente
for file in k8s/base/*.yml; do
    sed "s/namespace: .*/namespace: $ENV/g" "$file" | kubectl apply -n "$ENV" -f -
done

# 2. Esperar consolidación del despliegue con timeout ampliado a 10 minutos (600s)
echo "Esperando consolidacion de despliegue en $ENV (timeout: 600s)..."
kubectl rollout status deployment/notes-backend -n "$ENV" --timeout=600s
kubectl rollout status deployment/frontend -n "$ENV" --timeout=600s

echo "[OK] Despliegue completado con exito en $ENV"
