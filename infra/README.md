# Infrastructure Configuration

This directory contains all Docker and containerization configuration for Phase 2 (The "Wet" Time Capsule).

## Files

- **Dockerfile** - Builds the `java-mogilefs-builder` image with Java 6, Ant 1.9.7, and the docker-entrypoint.sh script
- **docker-entrypoint.sh** - Container entrypoint script that:
  - Resolves the mogilefs-infra service IP dynamically
  - Adds qbert.guba.com mapping to /etc/hosts
  - Executes the passed command
- **docker-compose.yml** - Orchestrates two services:
  - `mogilefs-infra` - MogileFS backend (Tracker + Storage + MySQL)
  - `builder` - Legacy Java 6 compiler and test runner

## Usage

### Prerequisites

- You must be in the `infra/` directory to run `docker compose` commands
- The project root (`java-mogilefs/`) is needed for scripts and source files
- Always use `sudo` for docker commands

### Step-by-Step Workflow

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

**Step 4: Run tests** (return to `infra/`)

```bash
cd infra
sudo docker compose run --rm builder bash -c "ant compile && java -cp classes:lib/* com.guba.mogilefs.test.URITest && java -cp classes:lib/* com.guba.mogilefs.test.TestMogileFS"
```

**Step 5: Cleanup** (from `infra/`)

```bash
sudo docker compose down -v
```

## Key Configuration Details

- **Builder context:** Points to the project root (`..`) so it can access all source files
- **Volumes:** Project root mounted as `/app` in the builder container
- **Network:** Private `mogilefs-net` bridge network with `qbert.guba.com` alias on mogilefs-infra
- **Entrypoint:** Dynamic DNS resolution to support hardcoded hostname
- **Healthcheck:** mogilefs-infra validates tracker on port 7001

## See Also

- [../PHASE-2-SETUP.md](../PHASE-2-SETUP.md) - Complete Phase 2 documentation
- [../scripts/init-mogilefs.sh](../scripts/init-mogilefs.sh) - Domain initialization script
