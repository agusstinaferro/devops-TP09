# TP09 — Kubernetes: Pods, Deployments y Services

## Arquitectura
Namespace: devops-portfolio
├── Deployment: postgres (1 réplica) ← ClusterIP :5432
├── Deployment: backend (2 réplicas) ← ClusterIP :5000
└── Deployment: frontend (2 réplicas) ← NodePort :30080

## Recursos Kubernetes usados
| Recurso | Para qué sirve |
|---|---|
| `Namespace` | Aislar todos los recursos del proyecto |
| `Secret` | Credenciales de Postgres en base64 |
| `ConfigMap` | Variables de entorno no sensibles |
| `PersistentVolumeClaim` | Almacenamiento persistente para DB |
| `Deployment` | Gestión declarativa de pods y réplicas |
| `Service ClusterIP` | Comunicación interna entre pods |
| `Service NodePort` | Exposición al exterior del cluster |
| `initContainer` | Esperar a que Postgres esté listo |
| `readinessProbe` | Verificar que el pod está listo para tráfico |
| `livenessProbe` | Reiniciar pod si está colgado |
| `resources` | Límites de CPU y memoria por pod |

## Deploy
Ejecutar en bash
bash scripts/deploy.sh
Verificar
bash scripts/verificar.sh
kubectl get all -n devops-portfolio

## Comandos útiles
# Escalar backend a 3 réplicas
kubectl scale deployment backend --replicas=3 -n devops-portfolio
# Ver logs en tiempo real
kubectl logs -l app=backend -n devops-portfolio -f
# Entrar a un pod
kubectl exec -it <pod-name> -n devops-portfolio -- /bin/bash
# Rollback
kubectl rollout undo deployment/backend -n devops-portfolio
