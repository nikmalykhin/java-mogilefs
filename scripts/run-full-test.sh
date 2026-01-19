#!/bin/bash
# Full test automation script
# Orchestrates: cleanup → start infra → init domain → run tests → cleanup
# Cleans up on success or failure

set -e  # Exit on any error

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 2: Full Integration Test Suite"
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
    sudo docker compose down -v 2>/dev/null || true
    
    echo "✓ Cleanup complete"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    exit $exit_code
}

trap cleanup EXIT

# Step 1: Cleanup any previous state
echo ""
echo "[1/5] Cleaning up previous state..."
cd "$INFRA_DIR"
sudo docker compose down -v 2>/dev/null || true
echo "✓ Cleanup complete"

# Step 2: Start infrastructure
echo ""
echo "[2/5] Starting MogileFS infrastructure..."
cd "$INFRA_DIR"
sudo docker compose up -d mogilefs-infra
echo "✓ Infrastructure started"

# Wait for health check
echo "Waiting for MogileFS tracker to become healthy..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if sudo docker compose ps mogilefs-infra | grep -q "healthy"; then
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

# Step 3: Initialize MogileFS domain
echo ""
echo "[3/5] Initializing MogileFS domain..."
cd "$PROJECT_ROOT"
sudo bash scripts/init-mogilefs.sh
echo "✓ Domain initialization complete"

# Step 4: Run tests
echo ""
echo "[4/5] Running integration tests..."
cd "$INFRA_DIR"
sudo docker compose run --rm builder bash -c \
    "ant compile && java -cp classes:lib/* com.guba.mogilefs.test.URITest && java -cp classes:lib/* com.guba.mogilefs.test.TestMogileFS"

echo ""
echo "[5/5] Test execution complete"
echo "✓ All tests passed!"
