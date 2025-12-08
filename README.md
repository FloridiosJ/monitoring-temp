# 🚀 Template de Monitoring Docker - Stack Complète

Une solution clé-en-main de monitoring et d'alerting pour serveurs Docker, facilement déployable et réutilisable sur tous vos serveurs.

## 📋 Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation rapide](#-installation-rapide)
- [Configuration](#️-configuration)
- [Alertes](#-alertes)
- [Dashboards Grafana](#-dashboards-grafana)
- [Déploiement multi-serveurs](#-déploiement-multi-serveurs)
- [Maintenance](#-maintenance)
- [Dépannage](#-dépannage)
- [Architecture](#-architecture)

## 🎯 Vue d'ensemble

Cette stack de monitoring fournit une solution complète pour surveiller :
- ✅ Ressources système (CPU, mémoire, disque, réseau)
- ✅ Containers Docker (état, ressources, restarts)
- ✅ Logs des applications et containers
- ✅ Alertes par email automatiques
- ✅ Dashboards Grafana pré-configurés

### Technologies utilisées

| Composant | Rôle | Port |
|-----------|------|------|
| **Prometheus** | Collecte et stockage des métriques | 9090 |
| **Alertmanager** | Gestion des alertes et notifications | 9093 |
| **Grafana** | Visualisation et dashboards | 3000 |
| **Node Exporter** | Métriques système (CPU, RAM, disque) | 9100 |
| **cAdvisor** | Métriques des containers Docker | 8080 |
| **Loki** | Agrégation et stockage des logs | 3100 |
| **Promtail** | Collecte des logs Docker | 9080 |

## ✨ Fonctionnalités

### Monitoring système
- 📊 Utilisation CPU (par core et globale)
- 💾 Utilisation mémoire (RAM, swap, cache)
- 💿 Espace disque et inodes
- 🌐 Trafic réseau (entrée/sortie)
- 📈 Charge système (load average)

### Monitoring Docker
- 🐳 État des containers (running/stopped)
- 🔄 Compteur de restarts
- 📊 Consommation CPU par container
- 💾 Consommation mémoire par container
- 🌐 Trafic réseau par container
- 📝 Logs centralisés de tous les containers

### Alertes automatiques
- 🚨 CPU > 80% (warning) ou > 95% (critical)
- 🚨 Mémoire > 85% (warning) ou > 95% (critical)
- 🚨 Disque > 85% (warning) ou > 95% (critical)
- 🚨 Inodes > 85%
- 🚨 Container arrêté
- 🚨 Container avec restarts fréquents
- 🚨 Prédiction de saturation disque sous 24h

## 📦 Prérequis

- Docker Engine 20.10+
- Docker Compose 2.0+
- Serveur Linux (Ubuntu, Debian, CentOS, etc.)
- Accès root ou sudo
- Au moins 2 GB de RAM libre
- Ports disponibles : 3000, 3100, 9090, 9093 (ou Traefik configuré)

## 🚀 Installation rapide

### 1. Cloner ou copier le repository

```bash
# Cloner depuis GitHub
git clone https://github.com/votre-org/monitoring-temp.git
cd monitoring-temp

# OU copier manuellement tous les fichiers sur votre serveur
scp -r monitoring-temp/ user@your-server:/opt/monitoring/
```

### 2. Configuration minimale

```bash
# Copier le fichier d'exemple
cp .env.example .env

# Éditer la configuration
nano .env
```

**Configuration minimale requise :**

```bash
# Identification du serveur
SERVER_NAME=mon-serveur-prod
ENVIRONMENT=production

# Credentials Grafana
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=votre_mot_de_passe_securise

# Configuration SMTP pour les alertes email
SMTP_HOST=smtp.gmail.com:587
SMTP_USER=votre-email@gmail.com
SMTP_PASSWORD=votre-app-password
SMTP_FROM_ADDRESS=votre-email@gmail.com
ALERT_EMAIL_TO=admin@example.com,ops@example.com
```

> **Note Gmail :** Pour utiliser Gmail, créez un [App Password](https://support.google.com/accounts/answer/185833) au lieu d'utiliser votre mot de passe principal.

### 3. Démarrer la stack

```bash
# Créer le réseau Docker (si pas déjà créé)
docker network create monitoring

# Démarrer tous les services
docker-compose -f compose.monitoring.yaml up -d

# Vérifier que tous les containers sont démarrés
docker-compose -f compose.monitoring.yaml ps
```

### 4. Accéder à Grafana

1. Ouvrez votre navigateur : `http://votre-serveur:3000`
2. Connectez-vous avec vos identifiants (définis dans `.env`)
3. Le dashboard "Docker Server Monitoring - Complete" est déjà configuré

## ⚙️ Configuration

### Variables d'environnement détaillées

Consultez le fichier `.env.example` pour toutes les options disponibles :

#### Identification du serveur
```bash
SERVER_NAME=production-server-01  # Nom unique du serveur
ENVIRONMENT=production             # Environnement (production, staging, dev)
```

#### Seuils d'alertes personnalisables
```bash
ALERT_CPU_THRESHOLD=80            # % CPU pour déclencher une alerte
ALERT_MEMORY_THRESHOLD=85         # % RAM pour déclencher une alerte
ALERT_DISK_THRESHOLD=85           # % disque pour déclencher une alerte
ALERT_INODE_THRESHOLD=85          # % inodes pour déclencher une alerte
ALERT_CONTAINER_RESTART_THRESHOLD=5  # Nombre de restarts
```

#### Rétention des données
```bash
PROMETHEUS_RETENTION=15d          # Durée de conservation des métriques
LOKI_RETENTION=168h               # Durée de conservation des logs (7 jours)
```

### Configuration avec Traefik (optionnel)

Si vous utilisez Traefik comme reverse proxy :

```bash
# Dans .env
USE_TRAEFIK=true
GRAFANA_DOMAIN=monitoring.votre-domaine.com
TRAEFIK_NETWORK=traefik_monitoring
```

Assurez-vous que le réseau Traefik existe :
```bash
docker network create traefik_monitoring
```

### Personnalisation des règles d'alertes

Éditez le fichier `alert-rules.yml` pour :
- Modifier les seuils d'alerte
- Ajouter de nouvelles règles
- Personnaliser les messages

Après modification :
```bash
# Recharger la configuration Prometheus
docker exec prometheus kill -HUP 1

# OU redémarrer Prometheus
docker-compose -f compose.monitoring.yaml restart prometheus
```

## 📧 Alertes

### Configuration des notifications email

Les alertes sont gérées par Alertmanager et envoyées par email selon 3 niveaux de gravité :

1. **CRITICAL** 🚨 : Envoi immédiat, répété toutes les heures
2. **WARNING** ⚠️ : Envoi groupé, répété toutes les 4 heures
3. **MONITORING** 🔧 : Alertes système de monitoring, répétées toutes les 2 heures

### Types d'alertes configurées

#### Alertes système
- `HighCpuUsage` : CPU > 80% pendant 5 minutes
- `CriticalCpuUsage` : CPU > 95% pendant 2 minutes
- `HighMemoryUsage` : RAM > 85% pendant 5 minutes
- `CriticalMemoryUsage` : RAM > 95% pendant 2 minutes
- `HighDiskUsage` : Disque > 85% pendant 5 minutes
- `CriticalDiskUsage` : Disque > 95% pendant 2 minutes
- `HighInodeUsage` : Inodes > 85% pendant 5 minutes
- `DiskWillFillIn24Hours` : Prédiction de saturation

#### Alertes Docker
- `ContainerDown` : Container arrêté depuis 1 minute
- `ContainerRestartingFrequently` : Plus de 5 restarts en 15 minutes
- `ContainerHighCpu` : Container utilise > 80% CPU
- `ContainerHighMemory` : Container utilise > 85% de sa limite mémoire
- `ContainerMemoryLimitReached` : Container proche de sa limite (> 95%)

#### Alertes monitoring
- `PrometheusTargetDown` : Target Prometheus injoignable
- `PrometheusTooManyFailedScrapes` : Échecs de collecte
- `PrometheusConfigReloadFailed` : Échec du rechargement config

### Tester les alertes

```bash
# Simuler une charge CPU élevée
docker run --rm -it progrium/stress --cpu 8 --timeout 360s

# Vérifier les alertes actives dans Prometheus
# http://votre-serveur:9090/alerts

# Vérifier les alertes dans Alertmanager
# http://votre-serveur:9093
```

### Personnaliser les templates email

Éditez `alertmanager-config.yml` pour modifier :
- Le format des emails
- Les destinataires par type d'alerte
- Les intervalles de répétition
- Les règles d'inhibition

## 📊 Dashboards Grafana

### Dashboard principal : "Docker Server Monitoring - Complete"

Le dashboard pré-configuré inclut :

#### Vue d'ensemble (Row 1)
- 📊 Gauges : CPU, Mémoire, Disque, Nombre de containers

#### CPU & Load (Row 2)
- Utilisation CPU par mode (user, system, idle, etc.)
- Load average (1m, 5m, 15m)

#### Memory (Row 3)
- Détails mémoire (Used, Buffers, Cached, Free)

#### Disk (Row 4)
- Utilisation par point de montage
- I/O disque (lecture/écriture)

#### Network (Row 5)
- Trafic réseau par interface

#### Docker Containers (Row 6)
- CPU par container
- Mémoire par container
- Trafic réseau par container
- Table d'état des containers

### Accéder aux dashboards

1. Connectez-vous à Grafana : `http://votre-serveur:3000`
2. Allez dans **Dashboards** (menu latéral)
3. Ouvrez "Docker Server Monitoring - Complete"

### Créer vos propres dashboards

Les dashboards sont automatiquement provisionnés depuis le dossier `grafana/dashboards/`.

Pour ajouter un nouveau dashboard :
1. Créez votre dashboard dans Grafana
2. Exportez-le en JSON (Share > Export > Save to file)
3. Copiez le fichier JSON dans `grafana/dashboards/`
4. Redémarrez Grafana ou attendez 30 secondes (auto-refresh)

## 🌐 Déploiement multi-serveurs

### Architecture multi-serveurs

Cette stack peut être déployée sur plusieurs serveurs de deux façons :

#### Option 1 : Stack complète sur chaque serveur (recommandé)

Chaque serveur a sa propre stack de monitoring indépendante.

**Avantages :**
- Isolation complète
- Pas de dépendance réseau entre serveurs
- Redondance en cas de panne

**Déploiement :**
```bash
# Sur chaque serveur
cp -r monitoring-temp/ /opt/monitoring/
cd /opt/monitoring/

# Personnaliser .env avec le nom unique du serveur
nano .env
# Modifier SERVER_NAME=server-01, server-02, etc.

docker-compose -f compose.monitoring.yaml up -d
```

#### Option 2 : Prometheus centralisé (avancé)

Un Prometheus central collecte les métriques de tous les serveurs.

**Architecture :**
- 1 serveur central : Prometheus + Alertmanager + Grafana
- N serveurs distants : Node Exporter + cAdvisor + Promtail uniquement

**Configuration serveur distant :**
```bash
# Créer un docker-compose-exporters.yaml
version: '3.8'
services:
  node-exporter:
    image: prom/node-exporter:v1.9.1
    ports:
      - "9100:9100"
    # ... (voir compose.monitoring.yaml)
  
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    # ... (voir compose.monitoring.yaml)
```

**Configuration Prometheus central :**
```yaml
# prometheus.yml sur le serveur central
scrape_configs:
  - job_name: 'server-01'
    static_configs:
      - targets: ['server-01.example.com:9100']  # Node Exporter
        labels:
          server: 'server-01'
      - targets: ['server-01.example.com:8080']  # cAdvisor
        labels:
          server: 'server-01'
  
  - job_name: 'server-02'
    static_configs:
      - targets: ['server-02.example.com:9100']
        labels:
          server: 'server-02'
      - targets: ['server-02.example.com:8080']
        labels:
          server: 'server-02'
```

### Filtrage par serveur dans Grafana

Les labels `SERVER_NAME` et `ENVIRONMENT` permettent de filtrer les données :

```promql
# CPU usage pour un serveur spécifique
100 - (avg by(instance, cluster) (rate(node_cpu_seconds_total{mode="idle", cluster="server-01"}[5m])) * 100)

# Containers d'un environnement spécifique
container_last_seen{environment="production"}
```

## 🔧 Maintenance

### Vérifier l'état des services

```bash
# État des containers
docker-compose -f compose.monitoring.yaml ps

# Logs d'un service
docker-compose -f compose.monitoring.yaml logs -f prometheus

# Ressources utilisées
docker stats
```

### Sauvegarder les données

```bash
# Sauvegarder les volumes Docker
docker run --rm \
  -v prometheus-data:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/prometheus-$(date +%Y%m%d).tar.gz /data

docker run --rm \
  -v grafana-storage:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/grafana-$(date +%Y%m%d).tar.gz /data
```

### Mettre à jour les images

```bash
# Récupérer les dernières versions
docker-compose -f compose.monitoring.yaml pull

# Redémarrer avec les nouvelles images
docker-compose -f compose.monitoring.yaml up -d
```

### Nettoyer les anciennes données

```bash
# Supprimer les logs Docker anciens
docker system prune -a --volumes

# Nettoyer manuellement les volumes (⚠️ perte de données)
docker volume rm prometheus-data loki-storage
```

### Rotation des logs Loki

La configuration par défaut conserve les logs pendant 7 jours (168h).

Pour modifier :
```yaml
# loki-config.yaml
limits_config:
  retention_period: 336h  # 14 jours
```

## 🐛 Dépannage

### Les alertes ne sont pas envoyées

1. Vérifier la configuration SMTP :
```bash
# Tester la connexion SMTP
docker exec alertmanager wget -O- http://localhost:9093/-/healthy

# Vérifier les logs
docker logs alertmanager
```

2. Vérifier les credentials email dans `.env`
3. Pour Gmail, assurez-vous d'utiliser un App Password

### Prometheus ne collecte pas les métriques

```bash
# Vérifier les targets dans Prometheus
# http://votre-serveur:9090/targets

# Vérifier la connectivité réseau
docker exec prometheus wget -O- http://node-exporter:9100/metrics
docker exec prometheus wget -O- http://cadvisor:8080/metrics
```

### Grafana ne démarre pas

```bash
# Vérifier les logs
docker logs grafana

# Vérifier les permissions
docker exec grafana ls -la /var/lib/grafana

# Recréer le volume si nécessaire
docker-compose -f compose.monitoring.yaml down
docker volume rm grafana-storage
docker-compose -f compose.monitoring.yaml up -d
```

### Les dashboards ne s'affichent pas

1. Vérifier que les datasources sont configurés :
   - Grafana > Configuration > Data sources
2. Vérifier que Prometheus collecte bien les données :
   - Prometheus > Status > Targets
3. Vérifier les requêtes dans le dashboard (bouton "Edit")

### Container cAdvisor ne démarre pas

Sur certains systèmes, cAdvisor nécessite des permissions supplémentaires :

```yaml
# compose.monitoring.yaml
cadvisor:
  privileged: true
  devices:
    - /dev/kmsg:/dev/kmsg
```

### Erreur "network not found"

```bash
# Créer le réseau manuellement
docker network create monitoring

# OU si vous utilisez Traefik
docker network create traefik_monitoring
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker Host Server                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐                     │
│  │ Node Exporter│◄─────┤  Prometheus  │                     │
│  └──────────────┘      │              │                     │
│                        │   Collecte   │                     │
│  ┌──────────────┐      │   Métriques  │                     │
│  │  cAdvisor    │◄─────┤   & Règles   │                     │
│  └──────────────┘      │   d'alertes  │                     │
│                        └───────┬──────┘                     │
│  ┌──────────────┐             │                             │
│  │   Promtail   │             │                             │
│  │              │             ▼                             │
│  │  Collecte    │      ┌──────────────┐                     │
│  │   Logs       │      │ Alertmanager │                     │
│  └──────┬───────┘      │              │                     │
│         │              │  Routing &   │                     │
│         │              │  Envoi Email │                     │
│         │              └──────────────┘                     │
│         │                                                    │
│         ▼                                                    │
│  ┌──────────────┐                                           │
│  │     Loki     │      ┌──────────────┐                     │
│  │              │◄─────┤   Grafana    │                     │
│  │  Agrégation  │      │              │                     │
│  │    Logs      │      │ Visualisation│                     │
│  └──────────────┘      │  Dashboards  │                     │
│                        └──────────────┘                     │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Flux de données

1. **Collecte** :
   - Node Exporter expose les métriques système (CPU, RAM, disque)
   - cAdvisor expose les métriques containers Docker
   - Promtail collecte les logs Docker

2. **Stockage** :
   - Prometheus collecte et stocke les métriques
   - Loki collecte et stocke les logs

3. **Alerting** :
   - Prometheus évalue les règles d'alertes
   - Alertmanager reçoit les alertes et envoie les emails

4. **Visualisation** :
   - Grafana interroge Prometheus et Loki
   - Affichage dans les dashboards

## 📚 Ressources supplémentaires

- [Documentation Prometheus](https://prometheus.io/docs/)
- [Documentation Grafana](https://grafana.com/docs/)
- [Documentation Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Prometheus Query Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)
- [Grafana Dashboard Examples](https://grafana.com/grafana/dashboards/)

## 🤝 Contribution

Pour améliorer cette stack :
1. Forkez le repository
2. Créez une branche (`git checkout -b feature/amelioration`)
3. Committez vos changements (`git commit -am 'Ajout fonctionnalité'`)
4. Pushez (`git push origin feature/amelioration`)
5. Créez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

---

**Développé avec ❤️ pour simplifier le monitoring Docker**
