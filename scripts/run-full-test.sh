#!/bin/bash
# Full test automation script
# Orchestrates: cleanup → start infra → init domain → run tests → cleanup
# Updated for Gradle 7.6 bridge (Phase 3.1+)

set -e  # Exit on any error

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3.2: Full Integration Test Suite (Gradle Bridge)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Cleanup function - always runs on exit
cleanup() {
    local exit_code=$?
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ All tests passed! Cleaning up infrastructure..."
    else
        echo "❌ Tests failed (exit code: $exit_code). Cleaning up infrastructure..."
    fi
    
    cd "$INFRA_DIR"
    echo "Removing containers and volumes..."
    docker compose down -v 2>/dev/null || true
    
    echo "✓ Cleanup complete"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    exit $exit_code
}

trap cleanup EXIT

# Step 1: Cleanup any previous state
echo ""
echo "[1/7] Cleaning up previous state..."
cd "$INFRA_DIR"
docker compose down -v 2>/dev/null || true
echo "✓ Cleanup complete"

# Step 2: Build gradle-bridge image
echo ""
echo "[2/7] Building gradle-bridge Docker image..."
cd "$INFRA_DIR"
docker compose build gradle-bridge
echo "✓ Image built"

# Step 3: Start MogileFS infrastructure
echo ""
echo "[3/7] Starting MogileFS infrastructure..."
cd "$INFRA_DIR"
docker compose up -d --no-build mogilefs-infra
echo "✓ Infrastructure started"

# Wait for health check
echo "Waiting for MogileFS tracker to become healthy..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if docker compose ps mogilefs-infra | grep -q "healthy"; then
        echo "✓ MogileFS tracker is healthy"
        break
    fi
    attempt=$((attempt + 1))
    sleep 1
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ MogileFS tracker failed to become healthy after ${max_attempts}s"
    exit 1
fi

# Step 4: Initialize MogileFS domain
echo ""
echo "[4/7] Initializing MogileFS domain..."
cd "$PROJECT_ROOT"
bash scripts/init-mogilefs.sh
echo "✓ Domain initialization complete"

# Step 5: Start gradle-bridge service
echo ""
echo "[5/7] Starting gradle-bridge service..."
cd "$INFRA_DIR"
docker compose up -d --no-build gradle-bridge
echo "✓ Gradle bridge started"

# Step 6: Run URI test (safe, no backend required)
echo ""
echo "[6/7] Running URITest..."
cd "$INFRA_DIR"
docker compose exec -T gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.URITest
echo "✓ URITest passed"

# Step 7: Run TestMogileFS (requires infrastructure)
echo ""
echo "[7/7] Running TestMogileFS integration test..."
cd "$INFRA_DIR"
docker compose exec -T gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.TestMogileFS
echo "✓ TestMogileFS passed"
