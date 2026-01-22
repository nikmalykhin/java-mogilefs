# Java MogileFS Client

A Java client library for **MogileFS**, a distributed file storage system.

## Quick Start

**Run all tests:**

```bash
./scripts/run-full-test.sh
```

**Run tests directly:**

```bash
./gradlew runIntegrationTests
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

**Run specific test:**

```bash
./gradlew testBackend    # Tracker connectivity
./gradlew testMogileFS   # File operations
```

**Stop infrastructure:**

```bash
cd infra && docker compose down -v
```

## How It Works

- **DNS:** `/etc/hosts` maps `qbert.guba.com` → `127.0.0.1`
- **Ports:** Docker exposes 7001 (tracker), 7500/7501 (storage)
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
chmod +x scripts/init-mogilefs.sh
bash scripts/run-full-test.sh
```

## Documentation

- **[PHASE-4.0-MIGRATION.md](PHASE-4.0-MIGRATION.md)** - Phase 4.0 project structure standardization
- **[FUTURE-IMPROVEMENTS.md](FUTURE-IMPROVEMENTS.md)** - Planned improvements
- **[infra/README.md](infra/README.md)** - Docker infrastructure configuration details
- **[scripts/README.md](scripts/README.md)** - Script documentation and usage
- **[README](README)** - Original MogileFS client library documentation

## About

2008-era Java MogileFS client preserved and containerized. Docker handles networking and DNS - no code changes needed.

For more information about MogileFS: <http://www.danga.com/mogilefs/>
