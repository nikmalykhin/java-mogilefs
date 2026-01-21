# Quick Start Guide

## Clean Infrastructure Structure

All infrastructure code is now organized:

- **`infra/`** - Docker configuration
  - `Dockerfile` - Java 6 + Ant builder image (Phase 2, legacy)
  - `Dockerfile.gradle` - Java 8 + Gradle 7.6 (Phase 3, modern)
  - `docker-entrypoint.sh` - DNS resolution script
  - `docker-compose.yml` - Service orchestration
- **`scripts/`** - Helper scripts
  - `init-mogilefs.sh` - Domain initialization
  - `run-full-test.sh` - Automated test orchestration

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

### Manual Workflow (Phase 3 - Gradle)

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

# 4. Start gradle-bridge (return to infra)
cd infra
sudo docker compose up -d gradle-bridge

# 5. Run tests
sudo docker compose exec gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.URITest
sudo docker compose exec gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.TestMogileFS

# 6. Cleanup when done (from infra)
sudo docker compose down -v
```

### Legacy Ant Workflow (Phase 2)

The original Ant-based workflow is still available:

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

See [GRADLE-BRIDGE-CHEATSHEET.md](GRADLE-BRIDGE-CHEATSHEET.md) for comprehensive Gradle reference.

## Architecture Docs

- [infra/README.md](infra/README.md) - Infrastructure configuration details
- [scripts/README.md](scripts/README.md) - Script documentation

---

**Phase 3: The Strangler Lift - Gradle Bridge**

Zero Java code modifications. Modern build system wrapping legacy code.
