# Helper Scripts

This directory contains automation scripts for infrastructure initialization and testing.

## Quick Reference

**Run everything with one command:**

```bash
sudo bash scripts/run-full-test.sh
```

This handles: cleanup → start infra → init domain → run tests → cleanup (on success or failure).

## Scripts

### run-full-test.sh

Complete end-to-end automation script that orchestrates the entire testing workflow.

**Usage (from project root):**

```bash
sudo bash scripts/run-full-test.sh
```

**What it does:**

1. Cleans up any previous containers and volumes
2. Starts the mogilefs-infra service
3. Waits for the tracker to become healthy
4. Initializes the MogileFS domain configuration
5. Runs the full test suite (URITest + TestMogileFS)
6. Cleans up infrastructure on success or failure

**Expected output:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase 2: Full Integration Test Suite
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/5] Cleaning up previous state...
✓ Cleanup complete

[2/5] Starting MogileFS infrastructure...
✓ Infrastructure started

[3/5] Initializing MogileFS domain...
✓ Domain initialization complete

[4/5] Running integration tests...
✓ All tests passed!

✅ All tests passed! Cleaning up infrastructure...
✓ Cleanup complete
```

### init-mogilefs.sh

Initializes the MogileFS backend with required domain and storage class configuration.

**Usage (from project root):**

```bash
sudo bash scripts/init-mogilefs.sh
```

**When to run:** After `docker compose up -d mogilefs-infra` and before running tests (automatically run by `run-full-test.sh`).

**Important:** This script uses `docker exec` to run commands inside the mogilefs-infra container, so it must be run from the project root.

**What it does:**

1. Waits for the mogilefs-infra container's tracker to respond on port 7001
2. Registers the `www.guba.com` domain
3. Creates the `oneDeviceTest` storage class with mindevcount=1
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

## See Also

- [../infra/](../infra/) - Docker configuration files
- [../PHASE-2-COMPLETE.md](../PHASE-2-COMPLETE.md) - Phase 2 summary with architecture details
- [../PHASE-2-SETUP.md](../PHASE-2-SETUP.md) - Complete Phase 2 documentation
