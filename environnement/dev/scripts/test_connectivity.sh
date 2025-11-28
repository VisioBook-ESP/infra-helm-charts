#!/bin/bash
set -e

# Créer un dossier temporaire pour stocker les logs
mkdir -p /tmp/test-connectivity

LOG_FILE=/tmp/test-connectivity/connectivity.log

echo "Testing connectivity to services..." > "$LOG_FILE"

# Tester le service support-storage-service
echo "==> Testing support-storage-service" >> "$LOG_FILE"
curl -s -o /dev/null -w "%{http_code}\n" http://support-storage-service-support-storage-service:80/health >> "$LOG_FILE" || echo "Failed" >> "$LOG_FILE"

# Tester le service core-user-service
echo "==> Testing core-user-service" >> "$LOG_FILE"
curl -s -o /dev/null -w "%{http_code}\n" http://core-user-service-core-user-service:80/health >> "$LOG_FILE" || echo "Failed" >> "$LOG_FILE"

echo "Connectivity test finished. Log saved to $LOG_FILE"
