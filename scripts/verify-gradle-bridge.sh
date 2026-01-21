#!/bin/bash
# Gradle Bridge Verification Script (Phase 3.1)
# Tests that the gradle-bridge service can compile legacy Java 1.5 code
# For full Phase 3.2 testing, use: ./scripts/run-full-test.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"
cd "$PROJECT_ROOT"

echo "=========================================="
echo "Gradle 7.6 Bridge Verification (Phase 3.1)"
echo "=========================================="
echo

# Check if docker compose is available
if ! command -v docker &> /dev/null; then
    echo "ERROR: docker not found"
    exit 1
fi

echo "1. Building the gradle-bridge Docker image..."
cd "$INFRA_DIR"
docker compose build gradle-bridge

echo
echo "2. Checking if mogilefs-infra is running..."
if ! docker compose ps mogilefs-infra 2>/dev/null | grep -q "Up"; then
    echo "   Starting mogilefs-infra..."
    docker compose up -d mogilefs-infra
    echo "   Waiting for mogilefs-infra to be healthy..."
    sleep 30
fi

echo
echo "3. Starting gradle-bridge service..."
docker compose up -d gradle-bridge

echo
echo "4. Verifying Java 8 in gradle-bridge..."
docker compose exec gradle-bridge java -version

echo
echo "5. Compiling legacy Java 1.5 code via Gradle..."
docker compose exec gradle-bridge gradle compileJava

echo
echo "6. Verifying compiled classes exist..."
if docker compose exec gradle-bridge test -d /app/build/classes/java/main; then
    echo "   ✓ Classes compiled successfully"
else
    echo "   ✗ Compilation may have failed"
    exit 1
fi

echo
echo "=========================================="
echo "✓ Phase 3.1 Verification Complete"
echo "=========================================="
echo
echo "Next steps:"
echo "  1. List tasks: docker compose exec gradle-bridge gradle tasks"
echo "  2. Run Phase 3.2 tests: cd $PROJECT_ROOT && bash scripts/run-full-test.sh"
echo "  3. Manual test: docker compose exec gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.URITest"
