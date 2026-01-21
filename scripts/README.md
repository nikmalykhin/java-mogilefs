# Helper Scripts

This directory contains automation scripts for infrastructure initialization and testing.

## Quick Reference

**Run everything with one command:**

```bash
bash scripts/run-full-test.sh
```

This handles: cleanup → start infra → init domain → run tests → cleanup (on success or failure).

**Or run tests from your Mac:**

```bash
# One-time setup
bash scripts/setup-integration-tests.sh

# Run tests
./gradlew runIntegrationTests
```

## Scripts

### run-full-test.sh

Complete end-to-end automation script that orchestrates the entire testing workflow.

**Usage (from project root):**

```bash
bash scripts/run-full-test.sh
```

**What it does:**

**Docker Mode** (auto-detected when running inside container):

1. Cleans up any previous containers and volumes
2. Builds gradle-bridge Docker image
3. Starts mogilefs-infra service
4. Initializes MogileFS domain/storage class
5. Starts gradle-bridge and runs integration tests inside Docker
6. Cleans up infrastructure on exit

**Host Mode** (auto-detected when running on Mac):

1. Verifies MogileFS containers are running
2. Runs setup-integration-tests.sh (DNS configuration)
3. Initializes MogileFS domain/storage class
4. Runs integration tests from your laptop

**Expected output:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase 3.3b: Full Integration Test Suite (Gradle Bridge)
Mode: HOST MACHINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/4] Verifying MogileFS Docker containers...
✓ MogileFS containers already running

[2/4] Configuring host system...
✓ Setup complete

[3/4] Initializing MogileFS domain and storage class...
✓ Domain already configured

[4/4] Running integration tests from host machine...
✓ All integration tests passed on host machine

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ All tests passed!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### setup-integration-tests.sh

Configures your Mac to run integration tests locally (host machine mode).

**Usage (from project root):**

```bash
bash scripts/setup-integration-tests.sh
```

**When to run:**

- One time before first test run from your Mac
- Or if you encounter DNS/connection issues

**What it does:**

1. Adds `qbert.guba.com` to `/etc/hosts` (requires sudo password)
2. Verifies Docker containers are running

**Expected output:**

```
==========================================
Integration Tests Setup - Phase 3.3b
Using Docker Host Networking
==========================================

[Step 1/2] Configuring /etc/hosts...
✓ qbert.guba.com already in /etc/hosts

[Step 2/2] Verifying MogileFS containers...
✓ MogileFS containers are running

==========================================
✅ Setup Complete!
==========================================

Docker host networking is configured - all ports
are automatically available on your Mac!

You can now run integration tests from your laptop:
  ./gradlew runIntegrationTests
```

### init-mogilefs.sh

Initializes the MogileFS backend with required domain and storage class configuration.

**Usage (from project root):**

```bash
bash scripts/init-mogilefs.sh
```

**When to run:**

- After starting MogileFS containers for the first time
- Automatically run by `run-full-test.sh`

**What it does:**

1. Waits for mogilefs-infra tracker to respond on port 7001
2. Registers the `www.guba.com` domain
3. Creates the `oneDeviceTest` storage class (mindevcount=1)
4. Verifies the configuration

**Expected output:**

```
Initializing MogileFS domain configuration...
✓ Tracker is responsive
Registering domain www.guba.com...
Registering class oneDeviceTest...
Verifying configuration...
 domain               class                mindevcount   replpolicy
 www.guba.com         default                   2        MultipleHosts()
 www.guba.com         oneDeviceTest             1        MultipleHosts()
✓ MogileFS initialization complete!
```

## Workflow Examples

### Quick Test Cycle (Host Machine)

```bash
# Start MogileFS (once)
cd infra && docker compose up -d && cd ..

# Setup (once)
bash scripts/setup-integration-tests.sh

# Initialize domain (once per container restart)
bash scripts/init-mogilefs.sh

# Run tests (as many times as needed)
./gradlew runIntegrationTests
```

### Full Automated Cycle (Docker)

```bash
# Everything in one command
bash scripts/run-full-test.sh
```

## See Also

- [../infra/README.md](../infra/README.md) - Docker configuration details
- [../PHASE-3.3-COMPLETION.md](../PHASE-3.3-COMPLETION.md) - Phase 3.3 completion report
- [../TEST-HOST-NETWORKING.md](../TEST-HOST-NETWORKING.md) - Host networking implementation
- [../build.gradle](../build.gradle) - Gradle tasks documentation
