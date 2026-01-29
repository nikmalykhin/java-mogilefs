# MISSION: BROWNFIELD RESCUE - PHASE 4.2a (THE INFRASTRUCTURE PROBE)

You are acting as a **Senior QA Automation Architect**.
We are introducing **TestContainers** to the project.
Our IMMEDIATE goal is to establish a working base class and verify container startup. We will NOT migrate existing tests yet.

## THE PRIME DIRECTIVES
1.  **ESTABLISH, DON'T MIGRATE:** Create the `AbstractIntegrationTest` and the `build.gradle` config. Do not modify `TestBackend.java` or others yet.
2.  **SINGLETON CONTAINER:** Use the "Singleton Container" pattern (static field) so the container starts once and is shared between tests. This saves time.
    - Reference: `static GenericContainer<?> mogilefs = ...`
3.  **WAIT STRATEGY:** This legacy container is slow.
    - Use `.waitingForLogMessage(".*MogileFS initialization complete.*", 1)` (or similar log you saw in Phase 3) instead of just checking the port. Port open != App ready.

## TECHNICAL CONSTRAINTS
- **Image:** `hrchu/mogilefs-all-in-one:latest`.
- **Platform:** Force `linux/amd64`.
- **Dependencies:** Add `testcontainers-bom` and `junit-jupiter`.