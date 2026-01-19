# Phase 2: Quick Start Guide

## Clean Infrastructure Structure

All infrastructure code is now organized:

- **`infra/`** - Docker configuration
  - `Dockerfile` - Java 6 + Ant builder image
  - `docker-entrypoint.sh` - DNS resolution script
  - `docker-compose.yml` - Service orchestration
  
- **`scripts/`** - Helper scripts
  - `init-mogilefs.sh` - Domain initialization

## Quick Start

### Automated (Recommended)

Run the full test suite with automatic cleanup:

```bash
# From project root (java-mogilefs/)
sudo bash scripts/run-full-test.sh
```

This script:

1. Cleans up previous state
2. Starts MogileFS infrastructure
3. Initializes the domain
4. Runs all tests (URITest + TestMogileFS)
5. Cleans up on success or failure

### Manual Workflow

If you prefer step-by-step control:

```bash
# From project root (java-mogilefs/)

# 1. Clean up any previous containers
cd infra
sudo docker compose down -v

# 2. Start infrastructure
sudo docker compose up -d mogilefs-infra

# 3. Initialize domain (go back to root)
cd ..
sudo bash scripts/init-mogilefs.sh

# 4. Run tests (return to infra)
cd infra
sudo docker compose run --rm builder bash -c \
  "ant compile && java -cp classes:lib/* com.guba.mogilefs.test.URITest && java -cp classes:lib/* com.guba.mogilefs.test.TestMogileFS"

# 5. Cleanup when done (from infra)
sudo docker compose down -v
```

## Full Documentation

See [PHASE-2-SETUP.md](PHASE-2-SETUP.md) for comprehensive documentation.

## Architecture Docs

- [infra/README.md](infra/README.md) - Infrastructure configuration details
- [scripts/README.md](scripts/README.md) - Script documentation

---

**Phase 2: The "Wet" Time Capsule - Docker Compose Setup**

Zero Java code modifications. Pure infrastructure orchestration.
