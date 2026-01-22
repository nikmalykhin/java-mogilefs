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
├── java/                        # Original 2008 source code
│   └── com/guba/mogilefs/
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
- **Tests:** Run from your Mac, connect to Docker container

See [infra/README.md](infra/README.md) for architecture details.

```bash
cd infra
docker compose down -v
```

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

- **[PHASE-3.3-COMPLETION.md](PHASE-3.3-COMPLETION.md)** - Phase 3.3 architecture and completion report
- **[FUTURE-IMPROVEMENTS.md](FUTURE-IMPROVEMENTS.md)** - Planned improvements for Phase 3.4
- **[infra/README.md](infra/README.md)** - Docker infrastructure configuration details
- **[scripts/README.md](scripts/README.md)** - Script documentation and usage
- **[README](README)** - Original MogileFS client library documentation

## How It Works Under The Hood

1. **Build Phase:** Dockerfile installs Java 6 and Ant, then compiles Java source
2. **Network Phase:** Docker creates private network with MogileFS services
3. **DNS Trick:** Container entrypoint script adds hardcoded hostname to `/etc/hosts`
4. **File Trick:** Volume mounts put files at developer's expected paths
5. **Execution:** Java code connects to tracker and uploads files unchanged
6. **Cleanup:** Infrastructure automatically removed on test completion

## Success Indicators

When tests pass, you'll see:

✅ **URITest output:**

```
parsed //somehost.somewhere.com:800
authority is somehost.somewhere.com:800
```

✅ **TestMogileFS output:**

```
connected to tracker qbert.guba.com
response: OK fid=2&devid=2&path=http://127.0.0.1:7500/...
```

Both indicate the legacy code is working perfectly in the modern Docker environment.

---

## Historical Context

**Original code:** 2008-era Java MogileFS client written for a specific PC environment
**Problem:** Hardcoded paths and hostnames made it impossible to run elsewhere
**Solution:** Docker networking and filesystem virtualization (no code changes)

**Preserve the Era. Contain, Don't Modernize.**

For more information about MogileFS, visit: <http://www.danga.com/mogilefs/>
