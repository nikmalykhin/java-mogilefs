# Gradle Bridge - Reference Card

**TL;DR:** Run legacy Java 1.5 code through modern Gradle 7.6 in Docker on ARM.

## One-Liner Setup

```bash
docker-compose -f infra/docker-compose.yml build gradle-bridge && \
docker-compose -f infra/docker-compose.yml up -d mogilefs-infra && \
docker-compose -f infra/docker-compose.yml run --rm gradle-bridge gradle compile
```

## Common Commands

| Goal | Command |
|------|---------|
| Build image | `docker-compose -f infra/docker-compose.yml build gradle-bridge` |
| Start services | `docker-compose -f infra/docker-compose.yml up -d mogilefs-infra` |
| Compile | `docker-compose -f infra/docker-compose.yml run --rm gradle-bridge gradle compile` |
| Clean | `docker-compose -f infra/docker-compose.yml run --rm gradle-bridge gradle clean` |
| Docs | `docker-compose -f infra/docker-compose.yml run --rm gradle-bridge gradle doc` |
| List tasks | `docker-compose -f infra/docker-compose.yml run --rm gradle-bridge gradle tasks` |
| Check Java | `docker-compose -f infra/docker-compose.yml run --rm gradle-bridge java -version` |
| Check Gradle | `docker-compose -f infra/docker-compose.yml run --rm gradle-bridge gradle --version` |
| Stop services | `docker-compose -f infra/docker-compose.yml down` |

## Local Alias (Optional)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias gradle-docker='docker-compose -f infra/docker-compose.yml run --rm gradle-bridge gradle'
```

Then use:

```bash
gradle-docker compile
gradle-docker clean
gradle-docker testMogileFS
```

## Directory Structure

```
root/
├── build.gradle              ← Gradle (wraps Ant)
├── build.xml                 ← Ant (unchanged)
├── gradlew                   ← Gradle wrapper script
├── gradle/wrapper/
│   └── gradle-wrapper.properties
├── infra/
│   ├── Dockerfile            ← Old: Java 6 + Ant
│   ├── Dockerfile.gradle     ← New: Java 8 + Gradle 7.6
│   └── docker-compose.yml    ← Both services defined
└── java/                     ← Source code
```

## The Magic Line

```gradle
ant.importBuild('build.xml')
```

This makes all Ant targets available as Gradle tasks. Period.

## Available Gradle Tasks

```
- gradle clean              # Remove build artifacts
- gradle compile            # Compile Java code
- gradle compileAnt         # Alias for compile
- gradle doc                # Generate Javadoc
- gradle testMogileFS       # Run integration tests
- gradle tasks              # List all tasks
- gradle --version          # Show Gradle version
```

## Docker Services

```
mogilefs-net (Docker network)
├── mogilefs-infra
│   ├── Tracker: qbert.guba.com:7001
│   ├── Storage: :7500, :7501
│   └── MySQL: :3306
└── gradle-bridge (NEW)
    └── Can resolve qbert.guba.com
    └── Has source code mounted
    └── Java 8 + Gradle 7.6
```

## Build Performance & Pre-Caching

### First Build (Fresh Clone)

On a fresh clone, the first `gradle compile` will download the Gradle 7.6.1 distribution:

```bash
sudo bash scripts/run-full-test.sh
# First run: ~10-15s (includes Gradle download)
# Subsequent runs: ~3-5s (cached)
```

### Pre-Cache Gradle Locally (Optional)

To get fast builds on first run, pre-download the Gradle distribution:

```bash
# From project root
mkdir -p gradle/wrapper/dists/gradle-7.6.1-bin-5c35f9b877e6ee4cba72dbdd3841304c6403e9ee64c5fc42970ed1aa671773dc

# Download the zip
cd gradle/wrapper/dists/gradle-7.6.1-bin-5c35f9b877e6ee4cba72dbdd3841304c6403e9ee64c5fc42970ed1aa671773dc
curl -L -O https://services.gradle.org/distributions/gradle-7.6.1-bin.zip

# Extract it
unzip -q gradle-7.6.1-bin.zip

# Create marker file (tells wrapper it's valid)
touch .ok

# Cleanup
rm gradle-7.6.1-bin.zip
```

**Result:** Docker image includes pre-cached Gradle → first build runs in ~3s

**Note:** The `gradle/wrapper/dists/` directory is git-ignored to keep the repo lean (117MB would be added otherwise). The JDK tarball is committed because it's a one-time build dependency; Gradle can be re-downloaded quickly.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Cannot connect to Docker" | Start Docker Desktop (Mac/Windows) or Docker daemon (Linux) |
| "mogilefs-infra not healthy" | Wait 30 seconds: `sleep 30 && docker-compose ps` |
| "Permission denied: ./gradlew" | Run: `chmod +x gradlew` |
| "Cannot find TestMogileFS" | Expected in Phase 3.1; Phase 3.2 will add it |
| "Slow first build" | See "Pre-Cache Gradle Locally" above to speed up first run |
| "Connection refused" | Ensure mogilefs-infra is running: `docker-compose ps` |

## Documentation

- **[build.gradle](build.gradle)** - Self-documented Gradle config
- **[scripts/verify-gradle-bridge.sh](scripts/verify-gradle-bridge.sh)** - Automated verification

## Speed Tips

- Container image is ~1GB (download once, cached locally)
- Compilation takes ~10 seconds after download
- First `gradle-bridge` build takes ~30 seconds
- Subsequent runs are fast (use `docker-compose ps` to check service status)

## Environment Inside Container

| Variable | Value |
|----------|-------|
| JAVA_HOME | `/opt/java` (Java 8) |
| GRADLE_HOME | `/opt/gradle` |
| CLASSPATH | Auto-resolved from `./lib/**/*.jar` |
| Working Dir | `/app` |
| Source Dir | `/app/java` → Mounted to host root |

## Phase 3.1 Checklist

- [x] Gradle 7.6 Dockerfile created
- [x] build.gradle with Ant integration created
- [x] Gradle wrapper installed (gradlew + properties)
- [x] docker-compose.yml updated with gradle-bridge service
- [x] Networking configured (qbert.guba.com alias)
- [x] Volume mounts for source code
- [x] Documentation written
- [ ] Verification script run (next step)

## Next Phase (3.2)

- Add JUnit 3.8.x to classpath
- Create test runner task
- Execute TestMogileFS
- Document results
