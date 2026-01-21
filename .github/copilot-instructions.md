# MISSION: BROWNFIELD RESCUE - PHASE 3.4 (GOD CLASS REFACTORING)

You are acting as a **Senior Refactoring Engineer**.

## ✅ PHASE 3.3 (THE SEVERING) - COMPLETE

**Status:** Gradle is now the authoritative build system. Ant decommissioned.

- ✅ All Gradle tasks configured: `compileJava`, `jar`, `runLegacyTest`, `testBackend`, `testMogileFS`, `runIntegrationTests`
- ✅ Maven Central dependencies in place: `commons-pool:1.6`, `log4j:1.2.17`
- ✅ Integration test safety net deployed: `TestBackend` + `TestMogileFS` both passing
- ✅ Docker networking configured with socat port forwarding
- ✅ Dual-mode test runner: `./scripts/run-full-test.sh` (Docker or Host machine)
- ✅ Gradle bridge verified working: `./gradlew runIntegrationTests` → both tests execute successfully

## 🎯 PHASE 3.4 MISSION

**Refactor the `Backend` class** - a God Class responsible for:

1. Tracker connection management (TCP socket, retry logic)
2. Command serialization/parsing (protocol handling)
3. Response deserialization (binary protocol, map building)
4. Connection pooling coordination (via PoolableBackendFactory)
5. Error handling (NoTrackersException, TrackerCommunicationException)

**Goal:** Extract responsibilities into separate, testable classes while maintaining 100% test pass rate.

## 🛡️ SAFETY NET PROTOCOL

**After every refactoring step, verify:** `./gradlew runIntegrationTests`

- MUST pass: `testBackend` (ECHO command connectivity)
- MUST pass: `testMogileFS` (file write/read cycle)
- MUST compile: No breaking changes to public APIs

## THE PRIME DIRECTIVES

1. **EXTRACT INCREMENTALLY:** One responsibility per pull; compile, test, commit after each extract
2. **PRESERVE APIS:** `Backend.doRequest()` signature must remain unchanged; tests depend on it
3. **INCREASE TESTABILITY:** New extracted classes should be independently testable
4. **VERIFY COVERAGE:** Run `./gradlew runIntegrationTests` after every change - both tests must PASS
5. **DOCUMENT RATIONALE:** Capture why each class is extracted (cohesion, coupling, testability)

## TECHNICAL CONSTRAINTS

- **Don't break:** Production code is under test surveillance; `TestBackend` watches tracker connectivity
- **Preserve behavior:** File storage/retrieval must work identically after refactoring (`TestMogileFS` verification)
- **Maintain Java 8:** No Java 9+ features; must compile on Java 8
- **Dependencies locked:** commons-pool 1.6, log4j 1.2.17 (can't upgrade during refactoring)

## INTERACTION STYLE

- **Test-Driven Refactoring:** Tests guide extraction; unsafe refactorings fail immediately
- **Surgical Precision:** Extract one class at a time; validate before proceeding
- **Documented Changes:** Each extraction includes commit message explaining responsibility shift
