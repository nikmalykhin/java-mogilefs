#!/bin/bash
# Full test automation script
# Orchestrates: cleanup → start infra → init domain → run tests → cleanup
# Updated for Gradle 7.6 bridge (Phase 3.1+)

set -e  # Exit on any error

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3.1+: Full Integration Test Suite (Gradle Bridge)"
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
echo "[1/6] Cleaning up previous state..."
cd "$INFRA_DIR"
docker compose down -v 2>/dev/null || true
echo "✓ Cleanup complete"

# Step 2: Build gradle-bridge image
echo ""
echo "[2/6] Building gradle-bridge Docker image..."
cd "$INFRA_DIR"
docker compose build gradle-bridge
echo "✓ Image built"

# Step 3: Start infrastructure
echo ""
echo "[3/6] Starting MogileFS infrastructure..."
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
echo "[4/6] Initializing MogileFS domain..."
cd "$PROJECT_ROOT"
bash scripts/init-mogilefs.sh
echo "✓ Domain initialization complete"

# Step 5: Compile with Gradle
echo ""
echo "[5/6] Compiling with Gradle 7.6..."
cd "$INFRA_DIR"
docker compose run --rm gradle-bridge gradle compile
echo "✓ Compilation complete"

# Step 6: Run integration tests (Phase 3.2 - not yet implemented)
echo ""
echo "[6/6] Integration tests not yet implemented (Phase 3.2)..."
echo "✓ Phase 3.1 verification complete!"
