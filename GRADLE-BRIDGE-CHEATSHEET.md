# Gradle Bridge - Reference Card

**TL;DR:** Run legacy Java 1.5 code through modern Gradle 8.5 in Docker on ARM.

## One-Liner Setup

```bash
docker-compose -f infra/docker-compose.yml build gradle-bridge && \
docker-compose -f infra/docker-compose.yml up -d mogilefs-infra && \
docker-compose -f infra/docker-compose.yml up -d gradle-bridge
```

## Common Commands

| Goal           | Command                                                                                                                              |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Build image    | `docker-compose -f infra/docker-compose.yml build gradle-bridge`                                                                     |
| Start services | `docker-compose -f infra/docker-compose.yml up -d`                                                                                   |
| Compile        | `docker-compose -f infra/docker-compose.yml exec gradle-bridge gradle compileJava`                                                   |
| Clean          | `docker-compose -f infra/docker-compose.yml exec gradle-bridge gradle clean`                                                         |
| Run test       | `docker-compose -f infra/docker-compose.yml exec gradle-bridge gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.TestMogileFS` |
| List tasks     | `docker-compose -f infra/docker-compose.yml exec gradle-bridge gradle tasks`                                                         |
| Check Java     | `docker-compose -f infra/docker-compose.yml exec gradle-bridge java -version`                                                        |
| Check Gradle   | `docker-compose -f infra/docker-compose.yml exec gradle-bridge gradle --version`                                                     |
| Stop services  | `docker-compose -f infra/docker-compose.yml down`                                                                                    |

## Local Alias (Optional)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias gradle-docker='docker-compose -f infra/docker-compose.yml exec gradle-bridge gradle'
```

Then use:

```bash
gradle-docker compileJava
gradle-docker clean
gradle-docker runLegacyTest -PmainClass=com.guba.mogilefs.test.TestMogileFS
```

## Directory Structure

```
root/
├── build.gradle              ← Gradle (authoritative build system)
├── build.xml                 ← DEPRECATED (kept for reference)
├── gradlew                   ← Gradle wrapper script
├── gradle/wrapper/
│   └── gradle-wrapper.properties
├── infra/
│   ├── Dockerfile            ← Legacy: Java 6 + Ant (deprecated)
│   ├── Dockerfile.gradle     ← Phase 3.3: Java 8 + Gradle 8.5
│   └── docker-compose.yml    ← gradle-bridge service (active)
└── java/                     ← Source code
```

## The Key Feature: runLegacyTest

```gradle
tasks.register('runLegacyTest', JavaExec) {
    mainClass.set(project.findProperty('mainClass'))
    classpath = sourceSets.main.runtimeClasspath + sourceSets.test.output
    dependsOn 'compileJava', 'compileTestJava'
}
```

This allows running any legacy main class with `-PmainClass=...` using Gradle-compiled classes and Maven Central dependencies.

# Phase 3.3: Gradle Tasks (Ant is DEPRECATED)

```bash
# Core tasks
gradle clean                # Remove build artifacts
gradle compileJava          # Compile Java code
gradle jar                  # Create JAR file
gradle tasks                # List all tasks
gradle --version            # Show Gradle version

# Phase 3.2: Test runner
gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.TestMogileFS
gradle runLegacyTest -PmainClass=com.guba.mogilefs.test.URITest
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
    └── Java 8 + Gradle 8.5
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

| Problem                                          | Solution                                                    |
| ------------------------------------------------ | ----------------------------------------------------------- |
| "Cannot connect to Docker"                       | Start Docker Desktop (Mac/Windows) or Docker daemon (Linux) |
| "mogilefs-infra not healthy"                     | Wait 30 seconds: `sleep 30 && docker-compose ps`            |
| "service gradle-bridge is not running"           | Start it: `docker-compose up -d gradle-bridge`              |
| "Could not find or load main class" with gradlew | Use system gradle: `gradle` instead of `./gradlew`          |
| "Missing -PmainClass"                            | Provide class: `gradle runLegacyTest -PmainClass=...`       |
| "Connection refused"                             | Ensure mogilefs-infra is running: `docker-compose ps`       |

## Documentation

- **[build.gradle](build.gradle)** - Self-documented Gradle config
- **[scripts/verify-gradle-bridge.sh](scripts/verify-gradle-bridge.sh)** - Automated verification

## Speed Tips

- Container image is ~1GB (download once, cached locally)
- Compilation takes ~10 seconds after download
- First `gradle-bridge` build takes ~30 seconds
- Subsequent runs are fast (use `docker-compose ps` to check service status)

## Environment Inside Container

| Variable    | Value                               |
| ----------- | ----------------------------------- |
| JAVA_HOME   | `/opt/java` (Java 8)                |
| GRADLE_HOME | `/opt/gradle`                       |
| CLASSPATH   | Auto-resolved from `./lib/**/*.jar` |
| Working Dir | `/app`                              |
| Source Dir  | `/app/java` → Mounted to host root  |

## Phase 3 Checklist

- [x] Gradle 8.5 Dockerfile created
- [x] build.gradle with native compilation created
- [x] Gradle wrapper installed (gradlew + properties)
- [x] docker-compose.yml updated with gradle-bridge service
- [x] Networking configured (qbert.guba.com alias)
- [x] Volume mounts for source code and hardcoded paths
- [x] Documentation written
- [x] **Phase 3.2:** `runLegacyTest` task created and tested
- [x] **Phase 3.2:** TestMogileFS executed successfully

## Current Status

**Phase 3.2 Complete!** The Gradle bridge can now:

- Compile Java 1.5 source code using Java 8
- Execute any legacy main class via `runLegacyTest -PmainClass=...`
- Connect to the MogileFS infrastructure via Docker networking
- Access hardcoded file paths via volume mounts
