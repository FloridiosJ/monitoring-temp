#!/bin/bash
# Script to fix Grafana stack issues
# This script will clean up corrupted volumes and restart the Grafana service

set -e

# Configuration variables
COMPOSE_FILE="compose.monitoring.yaml"
GRAFANA_UID=472  # Grafana runs as UID 472 in the official container
VOLUME_PREFIX="monitoring-temp"

echo "🔧 Grafana Stack Cleanup and Fix Script"
echo "========================================"
echo ""

# Check if docker compose is available
if command -v docker compose &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo "❌ Error: docker compose or docker-compose not found"
    exit 1
fi

echo "📋 Step 1: Stopping all monitoring services..."
$DOCKER_COMPOSE -f $COMPOSE_FILE down

echo ""
echo "🗑️  Step 2: Removing corrupted Grafana volume..."
docker volume rm ${VOLUME_PREFIX}_grafana-storage 2>/dev/null || echo "Volume already removed or doesn't exist"

echo ""
echo "📁 Step 3: Ensuring all provisioning directories exist..."
mkdir -p grafana/provisioning/{datasources,dashboards,plugins,alerting,notifiers}

echo ""
echo "🔐 Step 4: Setting correct permissions for Grafana directories..."
# Grafana runs as UID 472
sudo chown -R ${GRAFANA_UID}:${GRAFANA_UID} grafana/ 2>/dev/null || echo "Note: Could not set permissions (may need sudo)"

echo ""
echo "🚀 Step 5: Starting the monitoring stack..."
$DOCKER_COMPOSE -f $COMPOSE_FILE up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

echo ""
echo "📊 Checking service status..."
$DOCKER_COMPOSE -f $COMPOSE_FILE ps

echo ""
echo "✅ Grafana stack fix complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Check Grafana logs: docker logs grafana"
echo "   2. Access Grafana: http://localhost:3000"
echo "   3. Default credentials: admin/admin (or check your .env file)"
echo ""
echo "🔍 If issues persist, check logs with:"
echo "   docker logs grafana"
echo "   docker logs prometheus"
echo "   docker logs loki"
