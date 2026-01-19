#!/bin/bash
# Helper script to initialize MogileFS domain configuration
# Run this after docker compose up -d mogilefs-infra

set -e

echo "Initializing MogileFS domain configuration..."

# Wait for container to be healthy
MAX_RETRIES=30
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if docker exec mogilefs-infra nc -z localhost 7001 2>/dev/null; then
        echo "✓ Tracker is responsive"
        break
    fi
    RETRY=$((RETRY + 1))
    echo "  Waiting for tracker... ($RETRY/$MAX_RETRIES)"
    sleep 1
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "✗ Tracker failed to become responsive"
    exit 1
fi

# Register domain and class
echo "Registering domain www.guba.com..."
docker exec mogilefs-infra mogadm --trackers=localhost:7001 domain add www.guba.com 2>/dev/null || echo "  (domain may already exist)"

echo "Registering class oneDeviceTest..."
docker exec mogilefs-infra mogadm --trackers=localhost:7001 class add www.guba.com oneDeviceTest --mindevcount=1 2>/dev/null || echo "  (class may already exist)"

echo "Verifying configuration..."
docker exec mogilefs-infra mogadm --trackers=localhost:7001 domain list

echo "✓ MogileFS initialization complete!"
