# Test Scripts

Helper scripts for running the complete test suite (integration tests + load test).

## Quick Reference

**Run all tests (JUnit + concurrent load test):**

```bash
./scripts/run-full-test.sh
```

This executes:

1. JUnit integration tests (TestBackend, TestMogileFS)
2. Concurrent load test (StoreALot: 1,000 operations across 10 threads)

## Scripts

### run-full-test.sh

Automated test orchestration - starts Docker, configures DNS, runs JUnit tests and load test.

**What it does:**

1. Starts MogileFS Docker container (if not running)
2. Configures `/etc/hosts` for DNS resolution
3. Waits for automatic domain initialization
4. Runs JUnit integration tests from your Mac
5. Runs concurrent load test (1,000 file stores across 10 threads)
   - Tests thread-safe ArrayList-based connection pooling
   - Verifies no `ConcurrentModificationException` under load
   - Reports throughput (ops/sec)

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
  ./gradlew test
```

### Domain Initialization

**Automatic:** Domain initialization (`www.guba.com` with `oneDeviceTest` storage class) is now handled automatically by docker-compose on container startup.

**Manual verification:**

```bash
docker exec mogilefs-infra mogadm --trackers=localhost:7001 class list
```

**Expected output:**

```
 domain               class                mindevcount   replpolicy
 www.guba.com         default                   2        MultipleHosts()
 www.guba.com         oneDeviceTest             1        MultipleHosts()
```

## Workflow Examples

### Quick Test Cycle (Host Machine)

```bash
# Start MogileFS (once - domain auto-initializes)
cd infra && docker compose up -d && cd ..

# Setup (once)
bash scripts/setup-integration-tests.sh

# Run tests (as many times as needed)
./gradlew test
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
