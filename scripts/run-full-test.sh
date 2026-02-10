#!/bin/bash
# Phase 3.3c: Integration Test Suite (Host Machine Only)
# Orchestrates: verify containers → setup host → wait for auto-init → run tests
# Domain initialization is now automatic via docker-compose

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3.3c: Integration Test Suite"
echo "Mode: HOST MACHINE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Cleanup function - always runs on exit
cleanup() {
    local exit_code=$?
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ All tests passed!"
    else
        echo "❌ Tests failed (exit code: $exit_code)"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    exit $exit_code
}

trap cleanup EXIT

# Step 1: Verify Docker containers are running
echo ""
echo "[1/4] Verifying MogileFS Docker containers..."
if ! docker ps --filter "name=mogilefs-infra" --filter "status=running" --format "{{.Names}}" 2>/dev/null | grep -q mogilefs-infra; then
    echo "Starting Docker containers..."
    cd "$INFRA_DIR"
    docker compose up -d
    echo "Waiting for MogileFS to be healthy..."
    sleep 12
else
    echo "✓ MogileFS containers already running"
fi

# Step 2: Setup host system (DNS)
echo ""
echo "[2/4] Configuring host system..."
chmod +x "$PROJECT_ROOT/scripts/setup-integration-tests.sh"
bash "$PROJECT_ROOT/scripts/setup-integration-tests.sh"

# Step 3: Wait for domain auto-initialization
echo ""
echo "[3/4] Waiting for domain auto-initialization..."
for i in {1..10}; do
    if docker exec mogilefs-infra mogadm --trackers=localhost:7001 class list 2>/dev/null | grep -q "www.guba.com"; then
        echo "✓ Domain initialized successfully"
        break
    fi
    sleep 2
done

# Step 4: Run integration tests from host
echo ""
echo "[4/4] Running tests from host machine..."
cd "$PROJECT_ROOT"
./gradlew test
echo "✓ All tests passed on host machine"
