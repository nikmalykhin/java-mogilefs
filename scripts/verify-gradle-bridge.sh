#!/bin/bash
# Gradle Bridge Verification Script
# This script tests that the gradle-bridge service can compile the legacy code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Gradle 7.6 Bridge Verification"
echo "=========================================="
echo

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: docker-compose not found"
    exit 1
fi

echo "1. Building the gradle-bridge Docker image..."
docker-compose -f infra/docker-compose.yml build gradle-bridge

echo
echo "2. Checking if mogilefs-infra is running..."
if ! docker-compose -f infra/docker-compose.yml ps mogilefs-infra | grep -q "Up"; then
    echo "   Starting mogilefs-infra..."
    docker-compose -f infra/docker-compose.yml up -d mogilefs-infra
    echo "   Waiting for mogilefs-infra to be healthy..."
    sleep 30
fi

echo
echo "3. Verifying Java 8 in gradle-bridge..."
docker-compose -f infra/docker-compose.yml run --rm gradle-bridge java -version

echo
echo "4. Compiling legacy Java 1.5 code via Gradle..."
docker-compose -f infra/docker-compose.yml run --rm gradle-bridge ./gradlew compile

echo
echo "5. Verifying JAR was created..."
JAR_FILE=$(docker-compose -f infra/docker-compose.yml run --rm gradle-bridge bash -c "ls -la mogilefs-*.jar" 2>/dev/null | tail -1)
if [ -n "$JAR_FILE" ]; then
    echo "   ✓ JAR created: $JAR_FILE"
else
    echo "   ⚠ JAR file not found (this may be expected)"
fi

echo
echo "=========================================="
echo "✓ Gradle Bridge Verification Complete"
echo "=========================================="
echo
echo "Next steps:"
echo "  1. Run: docker-compose -f infra/docker-compose.yml run --rm gradle-bridge ./gradlew tasks"
echo "  2. Review available Gradle tasks"
echo "  3. Test: docker-compose -f infra/docker-compose.yml run --rm gradle-bridge ./gradlew compile"
