# Infrastructure Configuration

This directory contains Docker configuration for running the Java MogileFS client with a local MogileFS server for testing.

## Phase 3.3 Status: Host Networking

**Current Architecture:** Docker host networking eliminates port forwarding complexity. All services run on `localhost` with direct port access.

## Files

- **docker-compose.yml** - Orchestrates two active services:
  - `mogilefs-infra` - MogileFS all-in-one (Tracker + Storage + MySQL) with host networking
  - `gradle-bridge` - Java 8 + Gradle 8.5 build environment with host networking
- **Dockerfile.gradle** - Builds the `gradle-bridge` image (Java 8, Gradle 8.5)
- **docker-entrypoint.sh** - Simplified passthrough script (host networking requires no special config)

## Quick Start

### Option 1: Automated Full Test (Recommended)

From project root:

```bash
bash scripts/run-full-test.sh
```

This script:

1. Starts MogileFS infrastructure
2. Initializes domain/storage class
3. Runs integration tests in Docker
4. Cleans up containers

### Option 2: Manual Workflow

**Start Infrastructure:**

```bash
cd infra
docker compose up -d
```

**Initialize MogileFS domain:**

```bash
cd ..
bash scripts/init-mogilefs.sh
```

**Run tests inside Docker:**

```bash
cd infra
docker compose exec gradle-bridge ./gradlew runIntegrationTests
```

**Cleanup:**

```bash
docker compose down -v
```

### Option 3: Run Tests from Host Machine

**Prerequisites:** Docker containers running, `/etc/hosts` configured

**Setup (one-time):**

```bash
bash scripts/setup-integration-tests.sh
```

**Run tests:**

```bash
./gradlew runIntegrationTests
```

This runs tests **on your Mac**, connecting to MogileFS in Docker via `localhost`.

## Architecture: Host Networking

```
┌─────────────────────────────────────┐
│   macOS (localhost)                 │
│                                     │
│   ┌─────────────────────────────┐   │
│   │  mogilefs-infra container   │   │
│   │  network_mode: host         │   │
│   │                             │   │
│   │  :7001 (tracker)            │ ◄─┼─── Direct access from Mac
│   │  :7500 (storage)            │ ◄─┼─── No port forwarding needed
│   │  :7501 (storage)            │ ◄─┼─── No socat needed
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │
│   │  gradle-bridge container    │   │
│   │  network_mode: host         │   │
│   │                             │   │
│   │  Connects to localhost:7001 │ ◄─┼─── Same localhost as Mac
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Key Benefit:** `127.0.0.1:7500` means the same thing everywhere - no ambiguity.

## Key Configuration Details

- **Host Networking:** Both containers use `network_mode: "host"` for direct localhost access
- **No Port Mapping:** Ports section removed; all ports automatically available on Mac
- **No Network Bridge:** `mogilefs-net` removed; not needed with host networking
- **Build Context:** Points to project root (`..`) to access source files
- **Volumes:** Project root mounted as `/app` in gradle-bridge
- **Hardcoded Path:** `/Users/ericlambrecht/...` mapped for legacy TestMogileFS compatibility
- **Healthcheck:** Validates tracker on port 7001 before starting gradle-bridge
- **Entrypoint:** Simplified; no DNS or port forwarding setup needed

## Available Gradle Tasks

From inside `gradle-bridge` container:

```bash
# Compile Java code
./gradlew compileJava

# Build JAR
./gradlew jar

# Run specific test
./gradlew testBackend
./gradlew testMogileFS

# Run all integration tests
./gradlew runIntegrationTests
```

## Troubleshooting

### Containers won't start

```bash
cd infra
docker compose down -v
docker compose up -d
```

### Tests can't connect to tracker

**Symptom:** `NoTrackersException` when running tests from Mac

**Fix:** Add to `/etc/hosts`:

```
127.0.0.1 qbert.guba.com
```

Or run the setup script:

```bash
bash scripts/setup-integration-tests.sh
```

### Domain not found error

**Symptom:** `ERR unreg_domain`

**Fix:** Initialize MogileFS domain:

```bash
bash scripts/init-mogilefs.sh
```

### Port already in use

**Symptom:** `bind: address already in use`

**Fix:** Stop conflicting services or old containers:

```bash
lsof -i :7001
docker compose down -v
```

## See Also

- [../PHASE-3.3-COMPLETION.md](../PHASE-3.3-COMPLETION.md) - Phase 3.3 completion report
- [../TEST-HOST-NETWORKING.md](../TEST-HOST-NETWORKING.md) - Host networking implementation details
- [../scripts/run-full-test.sh](../scripts/run-full-test.sh) - Automated test runner
- [../build.gradle](../build.gradle) - Gradle build configuration
