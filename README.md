# Java MogileFS Client

**Modernized Java 8 client library for MogileFS**, a distributed file storage system.

## Project Status

This is a **modernized and production-ready** MogileFS client with:

- ✅ **Thread-safe connection pooling** (ArrayList-based, replaced legacy Vector)
- ✅ **Modern build system** (Gradle 8.5)
- ✅ **JUnit 5 test suite** with integration tests
- ✅ **Concurrent load testing** (verified under 1,000+ operations)
- ✅ **Docker-based testing infrastructure**
- ✅ **Generic type safety** (no raw types)

**API Compatibility:** This version uses modern Java collections (`List<String>`, `Map<String, String>`) and is **not backward compatible** with the pre-2008 API that used `Vector`.

## Prerequisites

- **Java 8+** (JDK 8 or higher)
- **Docker** (for running MogileFS backend)
- **macOS, Linux, or WSL2** (x86_64 architecture)

## Quick Start

**Run all tests (JUnit + load test):**

```bash
./scripts/run-full-test.sh
```

**Build and test manually:**

```bash
# Build the project
./gradlew clean build

# Run unit tests
./gradlew test

# Run concurrent load test (1,000 operations)
./gradlew runStoreALot
```

## Project Structure

```
├── README.md                    # This file
├── build.gradle                 # Gradle 8.5 build configuration
├── src/
│   ├── main/java/               # Production code
│   │   └── com/guba/mogilefs/   # MogileFS client implementation
│   └── test/java/               # Test code
│       └── com/guba/mogilefs/test/
├── infra/                       # Docker infrastructure
│   ├── docker-compose.yml       # MogileFS server configuration
│   └── README.md
└── scripts/                     # Test automation scripts
    ├── run-full-test.sh         # Runs all tests
    └── setup-integration-tests.sh
```

## Getting Started

### 1. Start MogileFS Backend

```bash
cd infra && docker compose up -d
```

This starts the MogileFS tracker and storage servers in Docker. The domain `www.guba.com` with storage class `oneDeviceTest` is automatically initialized.

### 2. Build the Project

```bash
./gradlew clean build
```

### 3. Run Tests

**Integration tests (JUnit 5):**

```bash
./gradlew test
```

**Concurrent load test:**

```bash
./gradlew runStoreALot
```

This runs 1,000 file operations across 10 threads to verify thread-safe connection pooling.

### 4. Stop Infrastructure

```bash
cd infra && docker compose down -v
```

## Testing

### Prerequisites

The tests expect `qbert.guba.com` to resolve to `127.0.0.1`. Add this to `/etc/hosts`:

```
127.0.0.1 qbert.guba.com
```

Or run the setup script:

```bash
./scripts/setup-integration-tests.sh
```

### Test Architecture

**Backend:** MogileFS runs in Docker with ports exposed to your host machine.

**Tests:** Run on your host machine and connect to Docker via localhost.

```
Your Mac/Linux
  │
  ├─ ./gradlew test           # JUnit integration tests
  ├─ ./gradlew runStoreALot   # Concurrent load test
  │
  └─► Docker Container (mogilefs-infra)
       ├─ 7001:7001 (tracker)
       ├─ 7500:7500 (storage node 1)
       └─ 7501:7501 (storage node 2)
```

### Test Suite

**JUnit 5 Integration Tests** (`./gradlew test`):

- **TestBackend** - Validates tracker connection and error handling
- **TestMogileFS** - Validates file storage/retrieval lifecycle

**Concurrent Load Test** (`./gradlew runStoreALot`):

- **StoreALot** - Stress test: 1,000 file operations (100 iterations × 10 threads)
- Verifies thread-safe `ArrayList`-based connection pooling
- Confirms no `ConcurrentModificationException` under load
- Reports throughput (operations/sec)

## Key Changes from Legacy Version

This modernized version includes the following breaking changes:

1. **Collections Framework:**
   - Replaced `Vector` with `ArrayList` for thread-safe connection pooling
   - API returns `List<String>` and `Map<String, String>` instead of raw types

2. **Build System:**
   - Migrated from Ant (`build.xml`) to Gradle 8.5
   - Dependencies managed via Gradle, not manual `lib/` folder

3. **Testing:**
   - Migrated to JUnit 5 (from JUnit 3)
   - Added Docker-based integration testing infrastructure
   - Added concurrent load testing (`StoreALot`)

4. **Thread Safety:**
   - Connection pooling verified under concurrent load
   - Proper synchronization in `PooledMogileFSImpl`

**API Compatibility:** This version is **not backward compatible** with pre-2008 versions due to generics and collection type changes.

## Troubleshooting

### "Connection refused" or "NoTrackersException"

**Cause:** DNS not configured or Docker not running.

**Fix:**

```bash
# 1. Check Docker is running
docker ps | grep mogilefs-infra

# 2. Add to /etc/hosts if missing
echo "127.0.0.1 qbert.guba.com" | sudo tee -a /etc/hosts

# 3. Or run the setup script
./scripts/setup-integration-tests.sh
```

### "ERR unreg_domain" or domain not found

**Cause:** Container still initializing or initialization failed.

**Fix:** Wait a few seconds, then verify:

```bash
docker logs mogilefs-infra
docker exec mogilefs-infra mogadm --trackers=localhost:7001 class list
```

Expected output should show `www.guba.com` domain with `oneDeviceTest` storage class.

### Tests timeout or infrastructure won't start

**Cause:** Port conflicts or insufficient Docker resources.

**Fix:**

```bash
# Clean everything
cd infra && docker compose down -v
docker system prune -a --volumes

# Restart
docker compose up -d
```

### "Permission denied" when running scripts

**Fix:**

```bash
chmod +x scripts/*.sh
./scripts/run-full-test.sh
```

## Documentation

- **[infra/README.md](infra/README.md)** - Docker infrastructure details
- **[scripts/README.md](scripts/README.md)** - Script documentation
- **[FUTURE-IMPROVEMENTS.md](FUTURE-IMPROVEMENTS.md)** - Planned enhancements
- **[README](README)** - Original 2008 client library documentation

## Usage Examples

### Simple Non-Pooled Client

```java
import com.guba.mogilefs.*;

String[] trackers = {"qbert.guba.com:7001"};
MogileFS mfs = new SimpleMogileFSImpl("www.guba.com", trackers);

// Store a file
byte[] data = "Hello MogileFS".getBytes();
mfs.storeBytes("test_key", "oneDeviceTest", data);

// Retrieve paths
List<String> paths = mfs.getPaths("test_key", false);
System.out.println("Stored at: " + paths.get(0));
```

### Thread-Safe Pooled Client (Recommended)

```java
import com.guba.mogilefs.*;

String[] trackers = {"qbert.guba.com:7001"};
MogileFS mfs = new PooledMogileFSImpl("www.guba.com", trackers);

// Safe for concurrent use
mfs.storeBytes("key1", "oneDeviceTest", data1);
mfs.storeBytes("key2", "oneDeviceTest", data2);
```

### Local File System Mock (Testing)

```java
import com.guba.mogilefs.*;

MogileFS mfs = new LocalFileMogileFSImpl("/tmp/mogilefs-local");
mfs.storeBytes("test", "default", data);
// Stores to /tmp/mogilefs-local/test
```

## Contributing

This is a legacy modernization project. For feature requests or bug reports, see [FUTURE-IMPROVEMENTS.md](FUTURE-IMPROVEMENTS.md).

## License

See original license terms in [README](README).

## About

Modernized Java client for MogileFS distributed file storage system. Originally developed in 2008, modernized in 2026 with thread-safe connection pooling, Gradle build system, and comprehensive test infrastructure.

For more about MogileFS: <http://www.danga.com/mogilefs/>
