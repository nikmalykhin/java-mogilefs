# Java MogileFS Client - Legacy Edition (2008)

A Java client library for **MogileFS**, a distributed file storage system. This project resurrects 2008-era code and runs it in modern Docker environments without any source code modifications.

**Original library description:** See [README](README) (the original MogileFS client documentation)

## What This Project Does

This is a **complete Docker-based solution** that:

- ✅ Compiles legacy Java 1.5 code (from 2008) using modern Gradle 7.6
- ✅ Runs it against a live MogileFS backend
- ✅ Works without modifying any source code
- ✅ Handles hardcoded hostnames and file paths transparently
- ✅ Uses Docker networking tricks to simulate the original developer's environment
- ✅ Provides both Ant (legacy) and Gradle (modern) build systems

## Quick Start

### Option 1: Run Everything Automated (Recommended)

One command runs the full integration test suite with automatic cleanup:

```bash
sudo bash scripts/run-full-test.sh
```

This will:

1. Start MogileFS infrastructure
2. Initialize the domain
3. Run all tests
4. Clean up on success or failure

**Expected output:**

```
✅ All tests passed! Cleaning up infrastructure...
```

### Option 2: Just Run the Safe Unit Test (No Infrastructure Needed)

To test URI parsing without needing a live MogileFS server:

```bash
cd infra
sudo docker compose build gradle-bridge  # Build the Gradle 7.6 + Java 8 image
sudo docker compose run --rm gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.URITest
```

**Expected output:**

```
parsed //somehost.somewhere.com:800
authority is somehost.somewhere.com:800
host is somehost.somewhere.com
port is 800
```

### Option 3: Manual Step-by-Step Workflow

See [QUICK-START.md](QUICK-START.md) for detailed manual instructions.

## Architecture Overview

### The Problem We Solved

The original code is hardcoded for a specific PC:

- Connects to `qbert.guba.com:7001` (doesn't exist globally)
- Looks for files at `/Users/ericlambrecht/Projects/guba/MogileFS/...` (developer's machine)

### The Solution (No Code Changes)

We use **Docker networking and filesystem virtualization**:

**Layer 1 - DNS Resolution**

```dockerfile
# In docker-entrypoint.sh:
MOGILEFS_IP=$(getent hosts mogilefs-infra | awk '{ print $1 }')
echo "$MOGILEFS_IP qbert.guba.com" >> /etc/hosts
```

Maps the hardcoded hostname to the container's MogileFS service.

**Layer 2 - File Path Mapping**

```yaml
# In docker-compose.yml:
volumes:
  - ./java/com/guba/mogilefs/PooledMogileFSImpl.java:/Users/ericlambrecht/Projects/guba/MogileFS/PooledMogileFSImpl.java
```

Bind mounts the file at the exact path the code expects.

**Result:** The code runs unchanged and connects perfectly.

## Technology Stack

| Component  | Version                      | Purpose                                        |
| ---------- | ---------------------------- | ---------------------------------------------- |
| Java       | 1.5 (compiled) / 8 (runtime) | Cross-compilation: Java 5 source on Java 8 JVM |
| Gradle     | 7.6                          | Modern build system (primary)                  |
| Apache Ant | 1.9.7                        | Legacy build tool (available for reference)    |
| MogileFS   | Latest (Docker)              | Distributed file storage backend               |
| Docker     | v20+                         | Container orchestration                        |
| Ubuntu     | Latest                       | Base OS for Gradle container                   |

## Project Structure

```
java-mogilefs/
├── README                          # Original MogileFS client docs
├── README.md                        # This file (entry point)
├── QUICK-START.md                  # Quick reference guide
├── GRADLE-BRIDGE-CHEATSHEET.md     # Phase 3 Gradle reference
├── build.gradle                    # Gradle build configuration
├── build.xml                       # Legacy Ant build (preserved)
├── gradlew                         # Gradle wrapper script
│
├── infra/                          # Docker configuration
│   ├── Dockerfile                  # Java 6 + Ant builder image (legacy)
│   ├── Dockerfile.gradle           # Java 8 + Gradle 7.6 image (Phase 3)
│   ├── docker-entrypoint.sh        # DNS resolution script
│   ├── docker-compose.yml          # Service orchestration
│   └── README.md                   # Infrastructure details
│
├── scripts/                        # Helper scripts
│   ├── run-full-test.sh            # Automated test orchestration
│   ├── init-mogilefs.sh            # Domain initialization
│   └── README.md                   # Script documentation
│
└── java/                           # Original source code (unchanged)
    └── com/guba/mogilefs/          # All Java files here
        ├── MogileFS.java
        ├── PooledMogileFSImpl.java
        ├── test/
        │   ├── URITest.java        # Safe: no infrastructure needed
        │   ├── TestMogileFS.java   # Integration test
        │   └── ...
        └── ...
```

## Prerequisites

### Required

- **Docker** (any recent version)
- **Docker Compose** (v2+)
- **Linux or Mac with x86_64 CPU** (Intel/AMD, not ARM/Apple Silicon)
- **sudo privileges** (for Docker commands)
- **jdk-6u45-linux-x64.tar.gz** in project root (for licensing, not included)

### Not Required

- Java installed locally
- MogileFS installed locally
- Modern tools (we provide everything in containers)

## Common Tasks

### Run Full Integration Tests

```bash
sudo bash scripts/run-full-test.sh
```

### Run Only Safe Tests (No Backend)

```bash
cd infra
sudo docker compose run --rm gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.URITest
```

### Run Specific Test Class (with Infrastructure)

```bash
cd infra
sudo docker compose up -d
# Wait ~20 seconds for healthcheck, then:
sudo docker compose exec gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.TestMogileFS
```

### Start Infrastructure and Keep Running

```bash
cd infra
sudo docker compose up -d mogilefs-infra
cd ..
sudo bash scripts/init-mogilefs.sh
# Now infrastructure is running for manual testing
```

### Stop Infrastructure

```bash
cd infra
sudo docker compose down -v
```

## Troubleshooting

### "qemu-x86_64: Could not open '/lib64/ld-linux-x86-64.so.2'"

**Problem:** You're on an ARM-based Mac (Apple Silicon M1/M2/M3).
**Solution:** This project requires x86_64 (Intel/AMD). Use an Intel Mac, Linux machine, or cloud VM.

### "jdk-6u45-linux-x64.tar.gz not found"

**Problem:** Java tarball missing from project root.
**Solution:** Download JDK 6u45 x86_64 Linux version and place in project root.

### Tests timeout or MogileFS won't start

**Problem:** Docker resources insufficient or port conflicts.
**Solution:**

```bash
# Clean everything
cd infra && sudo docker compose down -v
sudo docker system prune -a --volumes
# Try again
sudo bash scripts/run-full-test.sh
```

### "Permission denied" when running scripts

**Problem:** Scripts not executable.
**Solution:**

```bash
chmod +x scripts/run-full-test.sh
chmod +x scripts/init-mogilefs.sh
sudo bash scripts/run-full-test.sh
```

## Documentation

- **[QUICK-START.md](QUICK-START.md)** - Quick reference with both automated and manual workflows
- **[GRADLE-BRIDGE-CHEATSHEET.md](GRADLE-BRIDGE-CHEATSHEET.md)** - Phase 3 Gradle reference and commands
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
