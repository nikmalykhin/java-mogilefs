# Infrastructure

Docker configuration for MogileFS test server.

## Quick Start

**Automated (recommended):**

```bash
cd .. && ./scripts/run-full-test.sh
```

**Manual:**

```bash
# Start MogileFS (domain initialization is automatic)
docker compose up -d

# Run tests from your Mac
cd .. && ./gradlew test

# Stop
docker compose down -v
```

## What's Running

Single container: `mogilefs-infra`

- MogileFS tracker (port 7001)
- Storage servers (ports 7500, 7501)
- MySQL database (port 3306)
- Auto-initializes `www.guba.com` domain with `oneDeviceTest` storage class

## Architecture

```
Your Mac (localhost)
  │
  ├─ ./gradlew runIntegrationTests
  │
  └─► Docker Container (mogilefs-infra)
       ├─ 7001:7001 (tracker)
       ├─ 7500:7500 (storage)
       └─ 7501:7501 (storage)
```

Tests run on your Mac, connect to Docker via port mappings.

Available Gradle tasks:

```bash
# Compile Java code
./gradlew compileJava

# Build JAR
./gradlew jar

# Run all tests (JUnit 5)
./gradlew test

# Clean build and test
./gradlew clean build test
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

**Cause:** Container is still initializing or initialization failed.

**Fix:** Wait a few seconds for auto-initialization to complete, or check container logs:

```bash
docker logs mogilefs-infra
```

To manually verify domain:

```bash
docker exec mogilefs-infra mogadm --trackers=localhost:7001 class list
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
