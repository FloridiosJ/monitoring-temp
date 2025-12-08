# Grafana Stack Fix - Documentation

## Issues Resolved

This fix addresses the following Grafana stack issues:

1. ❌ **Database locked error** on SQLite
2. ❌ **Missing provisioning directories** (`/etc/grafana/provisioning/plugins`, `/etc/grafana/provisioning/alerting`, `/etc/grafana/provisioning/notifiers`)
3. ❌ **Unsupported plugin** (`grafana-piechart-panel` via Angular)
4. ❌ **404 errors** in Grafana interface

## Changes Made

### 1. Removed Unsupported Plugin
- **Removed:** `GF_INSTALL_PLUGINS=grafana-piechart-panel` from `compose.monitoring.yaml`
- **Reason:** This plugin uses Angular and is no longer supported in Grafana 12.x

### 2. Enabled SQLite WAL Mode
- **Added:** `GF_DATABASE_WAL=true` environment variable in `compose.monitoring.yaml`
- **Benefit:** Write-Ahead Logging (WAL) prevents database lock issues by allowing concurrent reads and writes

### 3. Created Missing Provisioning Directories
- **Created:** 
  - `grafana/provisioning/plugins/`
  - `grafana/provisioning/alerting/`
  - `grafana/provisioning/notifiers/`
- **Benefit:** Prevents provisioning errors and 404s in Grafana interface

### 4. Updated Datasources Configuration
- **Changed:** `editable: true` → `editable: false` for all datasources
- **Benefit:** Prevents accidental modifications in production and ensures consistency across deployments

## How to Apply the Fix

### Option 1: Automated Script (Recommended)

```bash
# Make the script executable
chmod +x fix-grafana.sh

# Run the fix script
./fix-grafana.sh
```

The script will:
1. Stop all monitoring services
2. Remove the corrupted Grafana volume
3. Ensure all provisioning directories exist
4. Set correct permissions
5. Restart the monitoring stack

### Option 2: Manual Fix

If you prefer to apply the fix manually:

```bash
# 1. Stop the monitoring stack
docker-compose -f compose.monitoring.yaml down

# 2. Remove the corrupted Grafana volume
docker volume rm monitoring-temp_grafana-storage

# 3. Ensure all provisioning directories exist
mkdir -p grafana/provisioning/{datasources,dashboards,plugins,alerting,notifiers}

# 4. Set correct permissions (Grafana runs as UID 472)
sudo chown -R 472:472 grafana/

# 5. Start the monitoring stack
docker-compose -f compose.monitoring.yaml up -d
```

## Verification

After applying the fix, verify everything is working:

### 1. Check Service Status
```bash
docker-compose -f compose.monitoring.yaml ps
```

All services should show as "Up" or "running".

### 2. Check Grafana Logs
```bash
docker logs grafana
```

You should **NOT** see:
- ❌ Database locked errors
- ❌ Missing provisioning directory errors
- ❌ Plugin loading errors for grafana-piechart-panel
- ❌ 404 errors

You should see:
- ✅ "HTTP Server Listen" message
- ✅ Datasources provisioned successfully
- ✅ Dashboards provisioned successfully

### 3. Access Grafana UI
1. Open browser: `http://localhost:3000` (or your configured domain)
2. Login with credentials from `.env` file (default: admin/admin)
3. Verify:
   - ✅ Dashboard loads without errors
   - ✅ Datasources are configured (Configuration > Data Sources)
   - ✅ No 404 errors in browser console

### 4. Test Datasources
In Grafana:
1. Go to Configuration > Data Sources
2. Click on "Prometheus"
3. Click "Save & Test" button
4. Should see: ✅ "Data source is working"

Repeat for Loki and Alertmanager datasources.

## Troubleshooting

### Issue: Permission Denied

If you see permission errors in Grafana logs:

```bash
# Fix permissions (Grafana runs as UID 472)
sudo chown -R 472:472 grafana/
docker-compose -f compose.monitoring.yaml restart grafana
```

### Issue: Volume Still Exists

If you can't remove the volume:

```bash
# Force remove all monitoring containers
docker-compose -f compose.monitoring.yaml down -v

# Then remove the volume manually
docker volume rm monitoring-temp_grafana-storage --force
```

### Issue: Datasources Not Working

If datasources show errors:

1. Check that Prometheus is running: `docker logs prometheus`
2. Check network connectivity: `docker exec grafana ping prometheus`
3. Verify Prometheus is accessible: `curl http://localhost:9090/-/healthy`

### Issue: Dashboards Not Loading

If dashboards are missing:

```bash
# Verify dashboard files exist
ls -la grafana/dashboards/

# Check dashboard provisioning config
cat grafana/provisioning/dashboards/dashboards.yml

# Restart Grafana to reload provisioning
docker-compose -f compose.monitoring.yaml restart grafana
```

## Configuration Details

### SQLite WAL Mode

WAL (Write-Ahead Logging) prevents database lock issues:

- **Before:** Writes block reads (database locked errors)
- **After:** Concurrent reads and writes possible
- **Environment Variable:** `GF_DATABASE_WAL=true`

### Datasource Configuration

All datasources are now set to `editable: false`:

```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false  # ← Changed from true
```

**Benefits:**
- Prevents accidental changes in production
- Ensures consistency across deployments
- Configuration managed via code (GitOps)

### Provisioning Directories

All required provisioning directories are now present:

```
grafana/provisioning/
├── alerting/       ← New
├── dashboards/     ← Existing
├── datasources/    ← Existing
├── notifiers/      ← New
└── plugins/        ← New
```

## Migration Notes

### For Existing Deployments

If you have an existing Grafana deployment with custom configurations:

1. **Backup** your current Grafana volume before applying the fix:
   ```bash
   docker run --rm \
     -v monitoring-temp_grafana-storage:/data \
     -v $(pwd)/backup:/backup \
     alpine tar czf /backup/grafana-backup-$(date +%Y%m%d).tar.gz /data
   ```

2. Apply the fix (this will create a fresh Grafana instance)

3. If needed, manually migrate custom dashboards:
   - Export dashboards from old instance (JSON)
   - Place JSON files in `grafana/dashboards/`
   - Restart Grafana

### For New Deployments

Simply clone the repository and start the stack:

```bash
git clone https://github.com/FloridiosJ/monitoring-temp.git
cd monitoring-temp
cp .env.example .env
# Edit .env with your settings
docker-compose -f compose.monitoring.yaml up -d
```

## Additional Resources

- [Grafana Provisioning Documentation](https://grafana.com/docs/grafana/latest/administration/provisioning/)
- [SQLite WAL Mode](https://www.sqlite.org/wal.html)
- [Grafana Database Configuration](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#database)

## Support

If you encounter issues not covered in this documentation:

1. Check the logs: `docker logs grafana`
2. Verify all services are running: `docker-compose -f compose.monitoring.yaml ps`
3. Review the issue tracker on GitHub
4. Join the community discussion

---

**Last Updated:** December 2024
**Grafana Version:** 12.0.0
