# Projet DevOps: Microservice Spring Cloud

Ce projet est basé sur le dépôt GitHub [merrixma/microservice](https://github.com/merrixma/microservice), un template de microservices Spring Cloud (Gateway, User, Order) avec Nacos pour la découverte de services. Une couche DevOps a été ajoutée pour la conteneurisation, l'orchestration et le déploiement automatisé.

## Architecture

```text
Client → Gateway (8080) → User Service (8081)
                       → Order Service (8082) → User Service (Feign)
         ↑
      Nacos (8848) — découverte de services
```

## Structure du projet

```text
microservice/
├── gateway-server/          # API Gateway (Spring Cloud Gateway)
├── user-service/            # Service utilisateurs
├── order-service/           # Service commandes (OpenFeign)
├── docker/
│   ├── Dockerfile.gateway
│   ├── Dockerfile.user
│   ├── Dockerfile.order
│   └── docker-compose.yml   # Stack complète (Nacos + microservices)
├── k8s/
│   ├── namespace.yaml
│   ├── nacos.yaml
│   ├── gateway-server.yaml
│   ├── user-service.yaml
│   ├── order-service.yaml
│   └── kustomization.yaml   # Déploiement Kubernetes
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf         # Infrastructure as Code (Kubernetes)
├── scripts/
│   └── build-images.sh      # Construction des images Docker
└── pom.xml
```

| Composant      | Rôle                                   | Port |
|----------------|----------------------------------------|------|
| Nacos          | Registre / découverte de services    | 8848 |
| gateway-server | API Gateway                            | 8080 |
| user-service   | API utilisateurs                       | 8081 |
| order-service  | API commandes                          | 8082 |

## Technologies DevOps utilisées

| Technologie | Rôle | Emplacement |
|-------------|------|-------------|
| **Docker** | Conteneurisation des microservices (build multi-étapes Maven → JRE) | `docker/` |
| **Docker Compose** | Orchestration locale de Nacos et des 3 services | `docker/docker-compose.yml` |
| **Kubernetes** | Déploiement en cluster (Deployments, Services, Namespace) | `k8s/` |
| **Terraform** | Provisionnement IaC de la stack sur Kubernetes | `terraform/` |

**Technologies applicatives** (projet source) : Spring Boot, Spring Cloud Gateway, Spring Cloud Alibaba, Nacos, OpenFeign, Hystrix, WebFlux.

## Prérequis

- Docker et Docker Compose
- Kubernetes (minikube, kind ou cluster existant) + `kubectl`
- Terraform >= 1.3 (pour le déploiement IaC)
- Java 8 et Maven 3.8+ (optionnel, build local)

## Guide de démarrage

### 1. Docker (recommandé pour débuter)

```bash
cd docker
docker compose up --build -d
```

Tester :

```bash
curl http://localhost:8080/user/1
curl http://localhost:8080/order/1
```

Console Nacos : http://localhost:8848/nacos (`nacos` / `nacos`)

Arrêter :

```bash
cd docker
docker compose down
```

### 2. Kubernetes

Construire les images :

```bash
chmod +x scripts/build-images.sh
./scripts/build-images.sh
```

Pour **minikube**, utiliser le daemon Docker du cluster :

```bash
eval $(minikube docker-env)
./scripts/build-images.sh
```

Pour **kind**, charger les images dans le cluster :

```bash
kind load docker-image microservice/gateway-server:latest
kind load docker-image microservice/user-service:latest
kind load docker-image microservice/order-service:latest
```

Déployer :

```bash
kubectl apply -k k8s/
kubectl -n microservice get pods -w
```

Accéder au gateway (NodePort 30080) :

```bash
curl http://localhost:30080/user/1
```

Supprimer :

```bash
kubectl delete -k k8s/
```

### 3. Terraform

Un cluster Kubernetes doit être accessible. Construire/charger les images comme ci-dessus, puis :

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Variables optionnelles : copier `terraform.tfvars.example` vers `terraform.tfvars`.

Détruire l'infrastructure :

```bash
terraform destroy
```

## Configuration Nacos

La variable d'environnement `NACOS_SERVER_ADDR` configure l'adresse du registre :

- Docker Compose : `nacos:8848`
- Kubernetes : `nacos.microservice.svc.cluster.local:8848`
- Développement local : `localhost:8848` (valeur par défaut)

## Références

- Projet source : https://github.com/merrixma/microservice
- Nacos 2.2.0 : https://github.com/alibaba/nacos/releases/tag/2.2.0
