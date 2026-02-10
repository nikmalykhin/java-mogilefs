# Java MogileFS Client

A Java client library for **MogileFS**, a distributed file storage system.

## Quick Start

**Run all tests (JUnit + load test):**

```bash
./scripts/run-full-test.sh
```

**Run tests directly:**

```bash
./gradlew test            # JUnit integration tests
./gradlew runStoreALot    # Concurrent load test (1,000 operations)
```

## What You Need

- Docker
- macOS (Intel or Apple Silicon with Rosetta)

## What This Does

Runs 2008-era Java code against a modern MogileFS backend in Docker:

- ✅ Tests tracker connectivity (error handling)
- ✅ Tests file write/read cycle
- ✅ No source code modifications needed

## Project Structure

```
├── README.md                    # This file
├── build.gradle                 # Gradle 8.5 build (Java 8)
├── src/
│   ├── main/java/               # Production code (2008 origin)
│   │   └── com/guba/mogilefs/
│   └── test/java/               # Test code
│       └── com/guba/mogilefs/test/
├── infra/                       # Docker: MogileFS server
│   └── docker-compose.yml
└── scripts/                     # Test automation
    └── run-full-test.sh
```

## Development

**Start MogileFS:**

```bash
cd infra && docker compose up -d
```

**Build and test:**

```bash
./gradlew clean build test
```

**Stop infrastructure:**

```bash
cd infra && docker compose down -v
```

## How It Works

- **DNS:** `/etc/hosts` maps `qbert.guba.com` → `127.0.0.1`
- **Ports:** Docker exposes 7001 (tracker), 7500/7501 (storage)
- **Domain:** Auto-initializes `www.guba.com` with `oneDeviceTest` storage class on startup
- **Tests:** Run from your Mac, connect to Docker via localhost

See [infra/README.md](infra/README.md) for architecture details.

## Troubleshooting

### "qemu-x86_64: Could not open '/lib64/ld-linux-x86-64.so.2'"

**Problem:** You're on an ARM-based Mac (Apple Silicon M1/M2/M3).
**Solution:** This project requires x86_64 (Intel/AMD). Use an Intel Mac, Linux machine, or cloud VM.

### Tests timeout or MogileFS won't start

**Problem:** Docker resources insufficient or port conflicts.
**Solution:**

```bash
# Clean everything
cd infra && docker compose down -v
docker system prune -a --volumes
# Try again
bash scripts/run-full-test.sh
```

### "Permission denied" when running scripts

**Problem:** Scripts not executable.
**Solution:**

```bash
chmod +x scripts/run-full-test.sh
bash scripts/run-full-test.sh
```

## Test Suite

All tests use **JUnit 5** and run via `./gradlew test`:

- **TestBackend** - Validates tracker connection and error handling
- **TestMogileFS** - Validates file storage/retrieval lifecycle

**Concurrent load test** runs via `./gradlew runStoreALot`:

- **StoreALot** - Stress test: 1,000 concurrent file operations (100 iterations × 10 threads)
  - Verifies thread-safe ArrayList-based connection pooling
  - Confirms no `ConcurrentModificationException` under load
  - Measures throughput (ops/sec)

## Documentation

- **[PHASE-4.0-MIGRATION.md](PHASE-4.0-MIGRATION.md)** - Phase 4.0 project structure standardization
- **[FUTURE-IMPROVEMENTS.md](FUTURE-IMPROVEMENTS.md)** - Planned improvements
- **[infra/README.md](infra/README.md)** - Docker infrastructure configuration details
- **[scripts/README.md](scripts/README.md)** - Script documentation and usage
- **[README](README)** - Original MogileFS client library documentation

## About

2008-era Java MogileFS client preserved and containerized. Docker handles networking and DNS - no code changes needed.

For more information about MogileFS: <http://www.danga.com/mogilefs/>
