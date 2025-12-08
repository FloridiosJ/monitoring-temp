# 🚀 Guide de Démarrage Rapide - 5 Minutes

Ce guide vous permet de déployer la stack de monitoring en quelques minutes.

## Étape 1 : Préparation (1 min)

```bash
# Cloner ou télécharger le projet
git clone <repository-url>
cd monitoring-temp

# OU si vous copiez manuellement
scp -r monitoring-temp/ user@server:/opt/monitoring/
ssh user@server
cd /opt/monitoring
```

## Étape 2 : Configuration (2 min)

```bash
# Copier le fichier de configuration
cp .env.example .env

# Éditer avec votre éditeur préféré
nano .env
```

**Modifiez au minimum ces valeurs :**

```bash
# Identification du serveur
SERVER_NAME=mon-serveur-production
ENVIRONMENT=production

# Grafana
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=VotreMotDePasseSecurise123!

# Email pour les alertes
SMTP_HOST=smtp.gmail.com:587
SMTP_USER=votre-email@gmail.com
SMTP_PASSWORD=votre-app-password-gmail
SMTP_FROM_ADDRESS=votre-email@gmail.com
ALERT_EMAIL_TO=admin@example.com
```

> **💡 Astuce Gmail :** Créez un App Password sur https://myaccount.google.com/apppasswords

## Étape 3 : Démarrage (1 min)

```bash
# Créer le réseau Docker
docker network create monitoring

# Démarrer tous les services
docker-compose -f compose.monitoring.yaml up -d

# Vérifier que tout est démarré
docker-compose -f compose.monitoring.yaml ps
```

Vous devriez voir :
```
NAME                IMAGE                              STATUS
alertmanager        prom/alertmanager:v0.27.0         Up
cadvisor            gcr.io/cadvisor/cadvisor:latest   Up
grafana             grafana/grafana:12.0.0            Up
loki                grafana/loki:2.9.4                Up
node-exporter       prom/node-exporter:v1.9.1         Up
prometheus          prom/prometheus:v3.3.1            Up
promtail            grafana/promtail:2.9.4            Up
```

## Étape 4 : Accès (30 sec)

### Grafana (Interface principale)
- URL : `http://votre-serveur:3000`
- Login : celui défini dans `.env`
- Dashboard : "Docker Server Monitoring - Complete"

### Prometheus (Métriques brutes)
- URL : `http://votre-serveur:9090`
- Status > Targets : vérifier que tout est "UP"

### Alertmanager (Alertes)
- URL : `http://votre-serveur:9093`
- Voir les alertes actives

## Étape 5 : Validation (30 sec)

### Vérifier les métriques dans Prometheus

1. Ouvrir `http://votre-serveur:9090`
2. Dans la barre de recherche, tester ces requêtes :

```promql
# CPU usage
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Running containers
count(container_last_seen{name!=""})
```

### Vérifier le dashboard Grafana

1. Ouvrir `http://votre-serveur:3000`
2. Se connecter
3. Menu > Dashboards > "Docker Server Monitoring - Complete"
4. Vous devriez voir toutes les métriques s'afficher

## ✅ C'est fait !

Votre stack de monitoring est opérationnelle. Les alertes seront envoyées automatiquement par email.

## 🧪 Tester les alertes (optionnel)

### Test 1 : Alerte CPU élevé

```bash
# Simuler une charge CPU pendant 6 minutes (l'alerte se déclenche après 5 min)
docker run --rm -d --name stress-test progrium/stress --cpu 8 --timeout 360s

# Attendre 5-6 minutes, puis vérifier :
# 1. Prometheus > Alerts : vous verrez "HighCpuUsage" en FIRING
# 2. Alertmanager : vous verrez l'alerte active
# 3. Email : vous devriez recevoir une notification

# Nettoyer
docker stop stress-test
```

### Test 2 : Vérifier un container down

```bash
# Arrêter un container temporairement
docker stop un-container-existant

# Attendre 1-2 minutes
# Vérifier Prometheus > Alerts : "ContainerDown" devrait apparaître

# Redémarrer le container
docker start un-container-existant
```

## 📚 Prochaines étapes

- 📖 Lire le [README.md](README.md) complet
- ⚙️ Personnaliser les seuils d'alertes dans `.env`
- 🎨 Créer vos propres dashboards Grafana
- 📧 Configurer plusieurs destinataires d'alertes
- 🌐 Déployer sur d'autres serveurs

## 🆘 Problème ?

### Les services ne démarrent pas

```bash
# Voir les logs
docker-compose -f compose.monitoring.yaml logs

# Redémarrer
docker-compose -f compose.monitoring.yaml restart
```

### Grafana : "Bad Gateway" ou ne charge pas

```bash
# Attendre 30 secondes supplémentaires (initialisation)
# Vérifier les logs
docker logs grafana
```

### Pas d'alertes email reçues

1. Vérifiez les credentials SMTP dans `.env`
2. Pour Gmail, utilisez un App Password (pas votre mot de passe normal)
3. Vérifiez les logs : `docker logs alertmanager`
4. Testez manuellement la configuration SMTP

### Prometheus ne voit pas les targets

```bash
# Vérifier la connectivité réseau
docker exec prometheus wget -O- http://node-exporter:9100/metrics
docker exec prometheus wget -O- http://cadvisor:8080/metrics

# Vérifier que tous les services sont dans le même réseau
docker network inspect monitoring
```

## 💡 Commandes utiles

```bash
# Voir tous les logs
docker-compose -f compose.monitoring.yaml logs -f

# Redémarrer un service
docker-compose -f compose.monitoring.yaml restart prometheus

# Arrêter tout
docker-compose -f compose.monitoring.yaml down

# Redémarrer tout
docker-compose -f compose.monitoring.yaml restart

# Mettre à jour les images
docker-compose -f compose.monitoring.yaml pull
docker-compose -f compose.monitoring.yaml up -d
```

---

**🎉 Félicitations ! Votre monitoring est opérationnel.**
