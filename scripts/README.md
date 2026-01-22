# Test Scripts

Helper scripts for running integration tests.

## Quick Reference

**Run all tests:**

```bash
./scripts/run-full-test.sh
```

## Scripts

### run-full-test.sh

Automated test orchestration - starts Docker, configures DNS, runs tests.

**What it does:**

1. Starts MogileFS Docker container (if not running)
2. Configures `/etc/hosts` for DNS resolution
3. Initializes MogileFS domain/storage class
4. Runs integration tests from your Mac

### setup-integration-tests.sh

One-time DNS configuration for running tests from your Mac.

**Usage:**

```bash
./scripts/setup-integration-tests.sh
```

**What it does:**

- Adds `qbert.guba.com` to `/etc/hosts` (requires sudo)
- Verifies Docker container is running

**When to run:**

- Before first test run
- If you get "connection refused" errors

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
