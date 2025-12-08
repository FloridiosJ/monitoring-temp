# ✅ Checklist de Déploiement

Utilisez cette checklist pour déployer la stack de monitoring sur un nouveau serveur.

## 📋 Pré-déploiement

### Vérifications système
- [ ] Serveur Linux accessible (SSH)
- [ ] Docker Engine installé (version 20.10+)
  ```bash
  docker --version
  ```
- [ ] Docker Compose installé (version 2.0+)
  ```bash
  docker-compose --version
  ```
- [ ] Au moins 2 GB RAM disponible
  ```bash
  free -h
  ```
- [ ] Au moins 10 GB espace disque disponible
  ```bash
  df -h
  ```
- [ ] Accès root ou sudo
  ```bash
  sudo -v
  ```

### Ports requis (si pas de Traefik)
- [ ] Port 3000 disponible (Grafana)
- [ ] Port 3100 disponible (Loki)
- [ ] Port 9090 disponible (Prometheus) - optionnel
- [ ] Port 9093 disponible (Alertmanager) - optionnel

### Credentials nécessaires
- [ ] Compte SMTP configuré (Gmail, SendGrid, etc.)
- [ ] App Password créé (si Gmail)
  - Créer sur : https://myaccount.google.com/apppasswords
- [ ] Adresse(s) email pour recevoir les alertes

## 📥 Installation

### 1. Récupérer le code
- [ ] Cloner le repository
  ```bash
  git clone https://github.com/votre-org/monitoring-temp.git
  cd monitoring-temp
  ```
  **OU** copier les fichiers manuellement
  ```bash
  scp -r monitoring-temp/ user@server:/opt/monitoring/
  ssh user@server
  cd /opt/monitoring
  ```

### 2. Configuration

- [ ] Copier le fichier d'environnement
  ```bash
  cp .env.example .env
  ```

- [ ] Éditer `.env` avec vos valeurs
  ```bash
  nano .env
  ```

#### Variables OBLIGATOIRES à configurer :

- [ ] **SERVER_NAME** : Nom unique du serveur
  ```bash
  SERVER_NAME=production-web-01
  ```

- [ ] **ENVIRONMENT** : Environnement (production, staging, dev)
  ```bash
  ENVIRONMENT=production
  ```

- [ ] **GRAFANA_ADMIN_PASSWORD** : Mot de passe sécurisé
  ```bash
  GRAFANA_ADMIN_PASSWORD=VotreMotDePasseSecurise123!
  ```

- [ ] **SMTP_HOST** : Serveur SMTP
  ```bash
  SMTP_HOST=smtp.gmail.com:587
  ```

- [ ] **SMTP_USER** : Utilisateur SMTP
  ```bash
  SMTP_USER=votre-email@gmail.com
  ```

- [ ] **SMTP_PASSWORD** : Mot de passe SMTP (App Password si Gmail)
  ```bash
  SMTP_PASSWORD=xxxx-xxxx-xxxx-xxxx
  ```

- [ ] **SMTP_FROM_ADDRESS** : Email expéditeur
  ```bash
  SMTP_FROM_ADDRESS=votre-email@gmail.com
  ```

- [ ] **ALERT_EMAIL_TO** : Destinataires des alertes (séparés par virgule)
  ```bash
  ALERT_EMAIL_TO=admin@example.com,ops@example.com
  ```

#### Variables OPTIONNELLES à personnaliser :

- [ ] **Seuils d'alertes** (laisser par défaut ou ajuster)
  ```bash
  ALERT_CPU_THRESHOLD=80
  ALERT_MEMORY_THRESHOLD=85
  ALERT_DISK_THRESHOLD=85
  ALERT_INODE_THRESHOLD=85
  ALERT_CONTAINER_RESTART_THRESHOLD=5
  ```

- [ ] **Rétention des données** (laisser par défaut ou ajuster)
  ```bash
  PROMETHEUS_RETENTION=15d
  LOKI_RETENTION=168h
  ```

- [ ] **Traefik** (si utilisé)
  ```bash
  USE_TRAEFIK=true
  GRAFANA_DOMAIN=monitoring.example.com
  TRAEFIK_NETWORK=traefik_monitoring
  ```

### 3. Réseau Docker

- [ ] Créer le réseau Docker
  ```bash
  docker network create monitoring
  ```
  
  **OU** si vous utilisez Traefik
  ```bash
  docker network create traefik_monitoring
  ```

### 4. Démarrage

- [ ] Démarrer la stack
  ```bash
  docker-compose -f compose.monitoring.yaml up -d
  ```

- [ ] Vérifier que tous les services sont démarrés
  ```bash
  docker-compose -f compose.monitoring.yaml ps
  ```
  
  Tous les services doivent être "Up" :
  - prometheus
  - alertmanager
  - grafana
  - node-exporter
  - cadvisor
  - loki
  - promtail

## ✅ Vérification

### 1. Vérifier les logs (optionnel)

- [ ] Vérifier qu'il n'y a pas d'erreurs critiques
  ```bash
  docker-compose -f compose.monitoring.yaml logs
  ```

### 2. Tester l'accès aux interfaces

- [ ] Accéder à Grafana
  - URL : `http://votre-serveur:3000`
  - Login : `admin` (ou celui défini dans .env)
  - Password : celui défini dans `GRAFANA_ADMIN_PASSWORD`
  
- [ ] Vérifier que le dashboard est présent
  - Menu > Dashboards
  - Chercher "Docker Server Monitoring - Complete"
  - Ouvrir le dashboard
  - Vérifier que les données s'affichent

- [ ] Accéder à Prometheus (optionnel)
  - URL : `http://votre-serveur:9090`
  - Aller dans Status > Targets
  - Vérifier que tous les targets sont "UP" :
    - prometheus
    - node-exporter
    - cadvisor
    - alertmanager

- [ ] Accéder à Alertmanager (optionnel)
  - URL : `http://votre-serveur:9093`
  - Vérifier l'interface de gestion des alertes

### 3. Tester les métriques dans Prometheus

- [ ] Ouvrir Prometheus : `http://votre-serveur:9090`

- [ ] Tester quelques requêtes dans la barre de recherche :
  
  - [ ] CPU usage
    ```promql
    100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
    ```
  
  - [ ] Memory usage
    ```promql
    (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
    ```
  
  - [ ] Container count
    ```promql
    count(container_last_seen{name!=""})
    ```

- [ ] Vérifier que les résultats s'affichent correctement

### 4. Tester les alertes (optionnel mais recommandé)

#### Test 1 : Alerte CPU

- [ ] Générer une charge CPU
  ```bash
  docker run --rm -d --name stress-test progrium/stress --cpu 8 --timeout 360s
  ```

- [ ] Attendre 5-6 minutes

- [ ] Vérifier dans Prometheus (Status > Alerts)
  - L'alerte "HighCpuUsage" devrait apparaître en FIRING

- [ ] Vérifier dans Alertmanager
  - L'alerte devrait être visible

- [ ] Vérifier la réception de l'email
  - Attendre quelques minutes
  - Vérifier votre boîte email

- [ ] Nettoyer
  ```bash
  docker stop stress-test
  ```

#### Test 2 : Test manuel SMTP (optionnel)

- [ ] Se connecter au container alertmanager
  ```bash
  docker exec -it alertmanager sh
  ```

- [ ] Vérifier la configuration SMTP
  ```bash
  wget -O- http://localhost:9093/-/healthy
  exit
  ```

## 🔒 Sécurité

### Post-déploiement

- [ ] Vérifier que `.env` est dans `.gitignore`
  ```bash
  cat .gitignore | grep .env
  ```

- [ ] Vérifier les permissions du fichier `.env`
  ```bash
  chmod 600 .env
  ls -la .env
  ```

- [ ] Configurer le firewall (si nécessaire)
  ```bash
  # Exemple avec ufw
  sudo ufw allow 3000/tcp  # Grafana
  ```

- [ ] Si exposition publique, configurer HTTPS (Traefik/Nginx)

## 📊 Configuration Grafana

### Première connexion

- [ ] Se connecter à Grafana avec les credentials admin

- [ ] Vérifier les datasources (Configuration > Data sources)
  - [ ] Prometheus : ✅ (par défaut)
  - [ ] Loki : ✅
  - [ ] Alertmanager : ✅

- [ ] Ouvrir le dashboard "Docker Server Monitoring - Complete"

- [ ] Personnaliser si nécessaire (variables, thresholds, etc.)

### Configuration des alertes Grafana (optionnel)

- [ ] Configurer un canal de notification supplémentaire
  - Alerting > Contact points
  - Ajouter email, Slack, PagerDuty, etc.

## 📝 Documentation

### À garder sous la main

- [ ] Noter les credentials Grafana dans un gestionnaire de mots de passe
- [ ] Noter l'URL d'accès à Grafana
- [ ] Documenter les spécificités de ce serveur (si différent du défaut)

## 🔄 Maintenance

### Configuration de la sauvegarde (recommandé)

- [ ] Créer un script de sauvegarde des volumes Docker
  ```bash
  mkdir -p ~/backups
  ```

- [ ] Configurer une tâche cron pour sauvegardes régulières
  ```bash
  crontab -e
  # Ajouter : 0 2 * * * /path/to/backup-script.sh
  ```

### Mises à jour futures

- [ ] Noter la procédure de mise à jour
  ```bash
  cd /opt/monitoring
  docker-compose -f compose.monitoring.yaml pull
  docker-compose -f compose.monitoring.yaml up -d
  ```

## 📚 Ressources

- [ ] Marquer les URLs importantes
  - README.md : Documentation complète
  - QUICKSTART.md : Démarrage rapide
  - TECHNICAL_OVERVIEW.md : Vue d'ensemble technique

- [ ] Rejoindre le canal de support (si existant)

## ✅ Validation Finale

- [ ] Grafana accessible et dashboard fonctionnel
- [ ] Prometheus collecte les métriques
- [ ] Alertes configurées et fonctionnelles
- [ ] Email de test reçu (si test effectué)
- [ ] Documentation accessible
- [ ] Credentials sauvegardés
- [ ] `.env` sécurisé

## 🎉 Déploiement Terminé !

Votre stack de monitoring est maintenant opérationnelle et surveillera automatiquement votre serveur.

### Prochaines étapes :

1. **Surveiller** les premiers jours pour ajuster les seuils si nécessaire
2. **Personnaliser** les alertes selon vos besoins spécifiques
3. **Créer** des dashboards supplémentaires si besoin
4. **Déployer** sur d'autres serveurs en répétant ce processus

### En cas de problème :

- Consulter le [README.md](README.md) - section Troubleshooting
- Vérifier les logs : `docker-compose -f compose.monitoring.yaml logs`
- Contacter le support/l'équipe

---

**Date de déploiement** : ______________
**Serveur** : ______________
**Déployé par** : ______________
**Statut** : ☐ Succès ☐ Problèmes rencontrés

**Notes** :
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
