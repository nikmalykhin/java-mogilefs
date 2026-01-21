# Infrastructure Configuration

This directory contains all Docker and containerization configuration for running legacy Java code in modern environments.

## Files

- **Dockerfile** - Builds the `java-mogilefs-builder` image with Java 6, Ant 1.9.7 (Phase 2, legacy)
- **Dockerfile.gradle** - Builds the `gradle-bridge` image with Java 8, Gradle 8.5 (Phase 3.3, modern)
- **docker-entrypoint.sh** - Container entrypoint script that:
  - Resolves the mogilefs-infra service IP dynamically
  - Adds qbert.guba.com mapping to /etc/hosts
  - Executes the passed command
- **docker-compose.yml** - Orchestrates three services:
  - `mogilefs-infra` - MogileFS backend (Tracker + Storage + MySQL)
  - `builder` - Legacy Java 6 + Ant compiler and test runner (Phase 2)
  - `gradle-bridge` - Modern Java 8 + Gradle 8.5 build system (Phase 3.3)

## Usage

### Prerequisites

- You must be in the `infra/` directory to run `docker compose` commands
- The project root (`java-mogilefs/`) is needed for scripts and source files
- Always use `sudo` for docker commands

### Step-by-Step Workflow (Phase 3 - Gradle)

**Step 1: Clean up any existing containers** (from `infra/` directory)

```bash
cd infra
sudo docker compose down -v
```

**Step 2: Start MogileFS infrastructure** (stay in `infra/`)

```bash
sudo docker compose up -d mogilefs-infra
```

**Step 3: Initialize domain** (go back to project root)

```bash
cd ..
sudo bash scripts/init-mogilefs.sh
```

**Step 4: Start gradle-bridge** (return to `infra/`)

```bash
cd infra
sudo docker compose up -d gradle-bridge
```

**Step 5: Run tests** (from `infra/`)

```bash
# Run specific test class
sudo docker compose exec gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.TestMogileFS

# Run URI test (no infrastructure needed)
sudo docker compose run --rm gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.URITest
```

**Step 6: Cleanup** (from `infra/`)

```bash
sudo docker compose down -v
```

### Legacy Ant Workflow (Phase 2)

The original Ant-based builder is still available:

```bash
cd infra
sudo docker compose run --rm builder bash -c "ant compile && java -cp classes:lib/* com.guba.mogilefs.test.URITest"
```

## Key Configuration Details

- **Builder context:** Points to the project root (`..`) so it can access all source files
- **Volumes:** Project root mounted as `/app` in both builder and gradle-bridge containers
- **Volume mount for hardcoded path:** `/Users/ericlambrecht/...` mapped for legacy code compatibility
- **Network:** Private `mogilefs-net` bridge network with `qbert.guba.com` alias on mogilefs-infra
- **Entrypoint:** Dynamic DNS resolution to support hardcoded hostname
- **Healthcheck:** mogilefs-infra validates tracker on port 7001
- **Gradle-bridge command:** Runs `tail -f /dev/null` to keep container alive for `docker exec`

## See Also

- [../GRADLE-BRIDGE-CHEATSHEET.md](../GRADLE-BRIDGE-CHEATSHEET.md) - Phase 3 Gradle reference
- [../QUICK-START.md](../QUICK-START.md) - Quick start guide
- [../scripts/init-mogilefs.sh](../scripts/init-mogilefs.sh) - Domain initialization script
