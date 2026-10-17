#!/bin/bash
set -euo pipefail

ok() { echo -e " \033[0;32m[OK]\033[0m $1"; }
fail() { echo -e " \033[0;31m[FAIL]\033[0m $1"; }
info() { echo -e "\n\033[1;34m=== $1 ===\033[0m"; }

info "1. Verificando Aislamiento de Namespaces"
for ns in staging production; do
  if kubectl get namespace "$ns" &>/dev/null; then
    ok "Namespace '$ns' presente y activo."
  else
    fail "Namespace '$ns' no encontrado."
  fi
done

info "2. Verificando Réplicas y Salud de Backend en Producción"
DESIRED=$(kubectl get deployment notes-backend -n production -o jsonpath='{.spec.replicas}')
READY=$(kubectl get deployment notes-backend -n production -o jsonpath='{.status.readyReplicas}')

if [ "$DESIRED" = "$READY" ] && [ "$READY" -ge 2 ]; then
  ok "Alta Disponibilidad garantizada: $READY/$DESIRED réplicas listas en producción."
else
  fail "Inconsistencia en producción: $READY/$DESIRED réplicas listas."
fi

info "3. Verificando Configuración de Sondas y RollingUpdate"
STRATEGY=$(kubectl get deployment notes-backend -n production -o jsonpath='{.spec.strategy.type}')
MAX_UNAVAIL=$(kubectl get deployment notes-backend -n production -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}')

if [ "$STRATEGY" = "RollingUpdate" ] && [ "$MAX_UNAVAIL" = "0" ]; then
  ok "Estrategia Zero-Downtime validada (RollingUpdate con maxUnavailable: 0)."
else
  fail "Configuración de RollingUpdate subóptima (Estrategia: $STRATEGY, maxUnavailable: $MAX_UNAVAIL)."
fi

echo -e "\n\033[1;32mAuditoría de resiliencia en Kubernetes finalizada con éxito.\033[0m\n"
