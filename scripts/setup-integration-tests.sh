#!/bin/bash
# Phase 3.3c: Setup for running integration tests from host machine
# Configures DNS so tests can resolve qbert.guba.com to localhost

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=========================================="
echo "Integration Tests Setup - Phase 3.3c"
echo "=========================================="

# Check if running from correct project
if [ ! -f "$PROJECT_ROOT/build.gradle" ]; then
    echo "ERROR: Could not find project root (build.gradle not found)"
    exit 1
fi

# Add qbert.guba.com to /etc/hosts
echo ""
echo "[1/2] Configuring /etc/hosts..."
HOSTS_ENTRY="127.0.0.1 qbert.guba.com"

if grep -q "qbert.guba.com" /etc/hosts 2>/dev/null; then
    echo "✓ qbert.guba.com already in /etc/hosts"
else
    echo "Adding qbert.guba.com to /etc/hosts (requires sudo)..."
    echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts > /dev/null
    echo "✓ Added qbert.guba.com to /etc/hosts"
fi

# Check if Docker containers are running
echo ""
echo "[2/2] Verifying MogileFS containers..."
TRACKER_RUNNING=$(docker ps --filter "name=mogilefs-infra" --format "{{.State}}" 2>/dev/null || echo "")

if [ "$TRACKER_RUNNING" != "running" ]; then
    echo "ERROR: MogileFS container is not running"
    echo "Start it with: cd infra && docker compose up -d"
    exit 1
fi

echo "✓ MogileFS containers are running"

echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "You can now run integration tests:"
echo "  ./gradlew runIntegrationTests"
echo ""
echo "Or run individual tests:"
echo "  ./gradlew testBackend"
echo "  ./gradlew testMogileFS"
echo ""
