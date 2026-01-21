#!/bin/bash
# Phase 3.3b: Full Integration Test Suite
# Orchestrates: cleanup → start infra → init domain → setup host → run tests
# Supports running from laptop (host) OR from Docker container

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"

# Determine if running from Docker or host
DOCKER_MODE="${DOCKER_MODE:-auto}"
if [ "$DOCKER_MODE" = "auto" ]; then
    if [ -f "/.dockerenv" ]; then
        DOCKER_MODE="true"
    else
        DOCKER_MODE="false"
    fi
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3.3b: Full Integration Test Suite (Gradle Bridge)"
echo "Mode: $([ "$DOCKER_MODE" = "true" ] && echo "DOCKER" || echo "HOST MACHINE")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Cleanup function - always runs on exit
cleanup() {
    local exit_code=$?
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ All tests passed!"
        if [ "$DOCKER_MODE" = "true" ]; then
            echo "Cleaning up Docker infrastructure..."
            cd "$INFRA_DIR"
            docker compose down -v 2>/dev/null || true
        fi
    else
        echo "❌ Tests failed (exit code: $exit_code)"
        if [ "$DOCKER_MODE" = "true" ]; then
            echo "Cleaning up Docker infrastructure..."
            cd "$INFRA_DIR"
            docker compose down -v 2>/dev/null || true
        fi
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    exit $exit_code
}

trap cleanup EXIT

if [ "$DOCKER_MODE" = "true" ]; then
    # ====================
    # DOCKER MODE
    # ====================
    
    # Step 1: Cleanup any previous state
    echo ""
    echo "[1/5] Cleaning up previous state..."
    cd "$INFRA_DIR"
    docker compose down -v 2>/dev/null || true
    echo "✓ Cleanup complete"

    # Step 2: Build gradle-bridge image
    echo ""
    echo "[2/5] Building gradle-bridge Docker image..."
    cd "$INFRA_DIR"
    docker compose build gradle-bridge
    echo "✓ Image built"

    # Step 3: Start MogileFS infrastructure
    echo ""
    echo "[3/5] Starting MogileFS infrastructure..."
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
    echo "[4/5] Initializing MogileFS domain and storage class..."
    docker exec mogilefs-infra mogadm --trackers=localhost:7001 domain add www.guba.com 2>/dev/null || true
    docker exec mogilefs-infra mogadm --trackers=localhost:7001 class add www.guba.com oneDeviceTest 2>/dev/null || true
    echo "✓ Domain initialization complete"

    # Step 5: Start gradle-bridge and run tests inside Docker
    echo ""
    echo "[5/5] Starting gradle-bridge and running integration tests..."
    cd "$INFRA_DIR"
    docker compose up -d --no-build gradle-bridge
    
    # Run the new integrated test task
    docker compose exec -T gradle-bridge bash -c "cd /app && ./gradlew runIntegrationTests"
    echo "✓ All integration tests passed in Docker"

else
    # ====================
    # HOST MACHINE MODE
    # ====================
    
    # Step 1: Verify Docker containers are running
    echo ""
    echo "[1/4] Verifying MogileFS Docker containers..."
    if ! docker ps --filter "name=mogilefs-infra" --filter "status=running" --format "{{.Names}}" 2>/dev/null | grep -q mogilefs-infra; then
        echo "Starting Docker containers..."
        cd "$INFRA_DIR"
        docker-compose up -d
        echo "Waiting for MogileFS to be healthy..."
        sleep 12
    else
        echo "✓ MogileFS containers already running"
    fi

    # Step 2: Setup host system (DNS + port forwarding)
    echo ""
    echo "[2/4] Configuring host system..."
    chmod +x "$PROJECT_ROOT/scripts/setup-integration-tests.sh"
    bash "$PROJECT_ROOT/scripts/setup-integration-tests.sh"

    # Step 3: Initialize MogileFS domain
    echo ""
    echo "[3/4] Initializing MogileFS domain and storage class..."
    docker exec mogilefs-infra mogadm --trackers=localhost:7001 domain add www.guba.com 2>/dev/null || echo "✓ Domain already configured"
    docker exec mogilefs-infra mogadm --trackers=localhost:7001 class add www.guba.com oneDeviceTest 2>/dev/null || echo "✓ Storage class already configured"

    # Step 4: Run integration tests from host
    echo ""
    echo "[4/4] Running integration tests from host machine..."
    cd "$PROJECT_ROOT"
    ./gradlew runIntegrationTests
    echo "✓ All integration tests passed on host machine"
fi
