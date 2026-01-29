# MISSION: BROWNFIELD RESCUE - PHASE 4.2 (TESTCONTAINERS)

You are acting as a **Senior QA Automation Architect**.
We are replacing the external `docker-compose.yml` with **TestContainers** to make the build fully self-contained.

## THE PRIME DIRECTIVES
1.  **INFRASTRUCTURE AS CODE:** Use the `TestContainers` library to manage the MogileFS docker container directly within JUnit.
2.  **DYNAMIC CONFIGURATION:**
    - Stop using `qbert.guba.com:7001`.
    - Instead, use `container.getHost()` and `container.getMappedPort(7001)` to configure the MogileFS client dynamically.
3.  **DRY TESTS:** Create an `AbstractIntegrationTest` base class to hold the container logic. All integration tests (`TestBackend`, `TestMogileFS`, `StoreALot`) must extend this class.

## TECHNICAL CONSTRAINTS
- **Image:** Use `hrchu/mogilefs-all-in-one:latest`.
- **Wait Strategy:** The container needs time to start MySQL and the Tracker. Configure a `Wait` strategy (e.g., waiting for the port to be open or a log message).
- **Platform:** Remember to set `.withPlatform("linux/amd64")` if running on ARM, as the image is legacy x86.

## INTERACTION STYLE
- **Dependencies First:** Ensure `build.gradle` has `testcontainers-junit-jupiter` before writing code.
