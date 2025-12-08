# 📊 Stack de Monitoring - Vue d'ensemble Technique

## 🎯 Objectif atteint

Ce repository fournit une **solution complète de monitoring et d'alerting** pour serveurs Docker, prête à l'emploi et facilement déployable sur n'importe quel serveur.

## 📦 Composants de la Stack

| Service | Fonction | Image Docker |
|---------|----------|--------------|
| **Prometheus** | Collecte et stockage des métriques | `prom/prometheus:v3.3.1` |
| **Alertmanager** | Gestion des alertes et notifications email | `prom/alertmanager:v0.27.0` |
| **Grafana** | Dashboards et visualisation | `grafana/grafana:12.0.0` |
| **Node Exporter** | Métriques système (CPU, RAM, disque, réseau) | `prom/node-exporter:v1.9.1` |
| **cAdvisor** | Métriques containers Docker | `gcr.io/cadvisor/cadvisor:latest` |
| **Loki** | Agrégation et stockage des logs | `grafana/loki:2.9.4` |
| **Promtail** | Collecte des logs Docker | `grafana/promtail:2.9.4` |

## ✨ Fonctionnalités Clés

### 1. Monitoring Système Complet
- ✅ CPU (usage global et par core)
- ✅ Mémoire (RAM, swap, cache, buffers)
- ✅ Disque (espace, inodes, I/O)
- ✅ Réseau (trafic entrant/sortant)
- ✅ Load average

### 2. Monitoring Docker Avancé
- ✅ État des containers (up/down)
- ✅ Compteur de restarts
- ✅ Ressources par container (CPU, mémoire, réseau)
- ✅ Logs centralisés de tous les containers

### 3. Système d'Alertes Intelligent
- ✅ 15+ règles d'alertes pré-configurées
- ✅ 3 niveaux de gravité (critical, warning, monitoring)
- ✅ Notifications email avec templates HTML
- ✅ Prévention du spam d'alertes (inhibition rules)
- ✅ Alertes prédictives (ex: disque plein dans 24h)

### 4. Dashboards Grafana
- ✅ Dashboard complet avec 20+ panels
- ✅ Provisioning automatique (aucune config manuelle)
- ✅ Visualisation en temps réel
- ✅ Adaptatif et responsive

### 5. Configuration Portable
- ✅ Variables d'environnement (.env)
- ✅ Aucun credential hardcodé
- ✅ Configuration multi-serveur
- ✅ Personnalisation facile

## 📁 Structure du Repository

```
monitoring-temp/
├── .env.example                    # Template de configuration
├── .gitignore                      # Exclusions git (données sensibles)
├── README.md                       # Documentation complète (598 lignes)
├── QUICKSTART.md                   # Guide démarrage rapide (5 min)
│
├── compose.monitoring.yaml         # Stack monitoring Docker Compose
├── compose.service.yaml            # Exemple d'app à monitorer
│
├── prometheus.yml                  # Config Prometheus + targets
├── alert-rules.yml                 # 15+ règles d'alertes
├── alertmanager-config.yml         # Config alertes + emails
│
├── loki-config.yaml                # Config Loki (logs)
├── promtail-config.yaml            # Config Promtail (collecte logs)
│
└── grafana/
    ├── dashboards/
    │   └── docker-monitoring.json  # Dashboard complet (20+ panels)
    └── provisioning/
        ├── datasources/
        │   └── datasources.yml     # Prometheus, Loki, Alertmanager
        └── dashboards/
            └── dashboards.yml      # Provisioning auto dashboards
```

## 🚀 Déploiement Simplifié

### En 3 commandes :

```bash
# 1. Configurer
cp .env.example .env && nano .env

# 2. Démarrer
docker network create monitoring
docker-compose -f compose.monitoring.yaml up -d

# 3. Accéder
# Grafana: http://votre-serveur:3000
```

## 📧 Alertes Email

### Types d'alertes configurées :

#### 🚨 Alertes CRITICAL (envoi immédiat)
- CPU > 95% pendant 2 minutes
- RAM > 95% pendant 2 minutes
- Disque > 95% pendant 2 minutes
- Container down
- Container mémoire limite atteinte (> 95%)

#### ⚠️ Alertes WARNING (envoi groupé)
- CPU > 80% pendant 5 minutes
- RAM > 85% pendant 5 minutes
- Disque > 85% pendant 5 minutes
- Inodes > 85% pendant 5 minutes
- Container restarts fréquents (> 5 en 15 min)
- Container CPU élevé (> 80%)
- Container mémoire élevée (> 85%)
- Prédiction disque plein sous 24h

#### 🔧 Alertes MONITORING (santé du système)
- Target Prometheus down
- Échecs de scraping
- Échec rechargement config

### Exemple d'email d'alerte :

```
🚨 [CRITICAL] HighMemoryUsage on node-exporter:9100

Status: FIRING
Severity: CRITICAL
Instance: node-exporter:9100
Summary: High memory usage on node-exporter:9100
Description: Memory usage is 92.5% on node-exporter:9100
Started at: 2024-12-08 11:45:00 UTC

Server: production-server-01 | Environment: production
```

## 📊 Dashboard Grafana

### Sections du dashboard :

1. **System Overview**
   - Gauges : CPU, Memory, Disk, Container Count

2. **CPU & Load**
   - CPU Usage by Mode (user, system, idle, iowait)
   - System Load Average (1m, 5m, 15m)

3. **Memory**
   - Memory Usage Details (Used, Buffers, Cached, Free)

4. **Disk**
   - Disk Space Usage by Mountpoint
   - Disk I/O (Read/Write)

5. **Network**
   - Network Traffic (RX/TX by interface)

6. **Docker Containers**
   - Container CPU Usage
   - Container Memory Usage
   - Container Network Traffic
   - Container Status Table

### Refresh automatique : 30 secondes

## 🌐 Déploiement Multi-Serveurs

### Option 1 : Stack indépendante par serveur (recommandé)

```bash
# Server 1
SERVER_NAME=web-server-01
ENVIRONMENT=production

# Server 2
SERVER_NAME=db-server-01
ENVIRONMENT=production

# Server 3
SERVER_NAME=api-server-01
ENVIRONMENT=staging
```

### Option 2 : Prometheus centralisé

Un Prometheus central qui collecte les métriques de tous les serveurs distants.

## ⚙️ Personnalisation

### Modifier les seuils d'alertes :

```bash
# .env
ALERT_CPU_THRESHOLD=70          # Au lieu de 80
ALERT_MEMORY_THRESHOLD=90       # Au lieu de 85
ALERT_DISK_THRESHOLD=80         # Au lieu de 85
```

### Ajouter une nouvelle alerte :

```yaml
# alert-rules.yml
- alert: CustomAlert
  expr: your_metric > threshold
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Your alert summary"
    description: "Your alert description"
```

### Modifier les destinataires d'alertes :

```bash
# .env
ALERT_EMAIL_TO=admin@example.com,ops@example.com,devops@example.com
```

## 🔒 Sécurité

### Bonnes pratiques appliquées :

- ✅ Aucun credential hardcodé
- ✅ Variables d'environnement pour données sensibles
- ✅ `.gitignore` pour exclure `.env` et volumes
- ✅ Images Docker officielles et à jour
- ✅ Aucune vulnérabilité détectée (vérifié)
- ✅ Restart policies pour haute disponibilité
- ✅ Volumes Docker pour persistance des données

### Credentials à configurer :

```bash
# Grafana admin
GRAFANA_ADMIN_PASSWORD=MotDePasseSecurise123!

# SMTP pour alertes
SMTP_USER=votre-email@gmail.com
SMTP_PASSWORD=votre-app-password
```

## 📚 Documentation

- **README.md** (598 lignes) : Documentation exhaustive
- **QUICKSTART.md** (216 lignes) : Guide démarrage rapide
- **.env.example** (88 lignes) : Toutes les variables configurables
- **Commentaires inline** : Dans tous les fichiers de config

### Sujets couverts dans la documentation :

- Installation complète
- Configuration détaillée
- Types d'alertes
- Dashboards Grafana
- Déploiement multi-serveurs
- Maintenance et mises à jour
- Dépannage (troubleshooting)
- Architecture système

## 🔍 Métriques Disponibles

### Métriques système (Node Exporter)

```promql
# CPU
node_cpu_seconds_total

# Mémoire
node_memory_MemTotal_bytes
node_memory_MemAvailable_bytes

# Disque
node_filesystem_size_bytes
node_filesystem_avail_bytes
node_filesystem_files
node_filesystem_files_free

# Réseau
node_network_receive_bytes_total
node_network_transmit_bytes_total

# Load
node_load1, node_load5, node_load15
```

### Métriques containers (cAdvisor)

```promql
# CPU
container_cpu_usage_seconds_total

# Mémoire
container_memory_usage_bytes
container_spec_memory_limit_bytes

# Réseau
container_network_receive_bytes_total
container_network_transmit_bytes_total

# État
container_last_seen
```

## 🎓 Exemples de Requêtes PromQL

```promql
# CPU usage en %
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Mémoire usage en %
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disque usage en %
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100

# Containers running
count(container_last_seen{name!=""})

# CPU par container
sum by (name) (rate(container_cpu_usage_seconds_total{name!=""}[5m])) * 100

# Top 5 containers par mémoire
topk(5, container_memory_usage_bytes{name!=""})
```

## ✅ Validation

### Tests effectués :
- ✅ Validation syntaxe YAML (tous les fichiers)
- ✅ Validation syntaxe JSON (dashboard Grafana)
- ✅ Vérification vulnérabilités (aucune trouvée)
- ✅ Code review (feedback adressé)
- ✅ Structure des fichiers validée

### Prêt pour :
- ✅ Déploiement production
- ✅ Déploiement multi-serveurs
- ✅ Personnalisation selon besoins

## 💡 Cas d'Usage

### 1. Serveur Web en Production
Monitorer les ressources et recevoir des alertes en cas de problème.

### 2. Infrastructure Multi-Serveurs
Déployer la stack sur chaque serveur avec une configuration centralisée.

### 3. Environnements Staging/Dev
Identifier les problèmes avant la production avec les mêmes outils.

### 4. Debugging et Optimisation
Analyser l'utilisation des ressources pour optimiser les performances.

## 🆘 Support

### Dépannage rapide :

```bash
# Vérifier l'état
docker-compose -f compose.monitoring.yaml ps

# Voir les logs
docker-compose -f compose.monitoring.yaml logs -f

# Redémarrer un service
docker-compose -f compose.monitoring.yaml restart prometheus

# Vérifier Prometheus targets
# http://votre-serveur:9090/targets

# Vérifier Alertmanager
# http://votre-serveur:9093
```

### Documentation détaillée :
- README.md : Guide complet
- QUICKSTART.md : Démarrage rapide
- Commentaires inline dans les configs

## 🎉 Résultat Final

Une stack de monitoring **clé-en-main**, **portable**, **sécurisée** et **documentée** qui peut être déployée en **5 minutes** sur n'importe quel serveur Docker.

**Objectif accompli : disposer d'une stack de monitoring/alerting clé-en-main duplicable pour tous les serveurs Docker.** ✅
