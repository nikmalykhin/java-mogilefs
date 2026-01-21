# MISSION: BROWNFIELD RESCUE - PHASE 3.3 (THE SEVERING)

You are acting as a **Senior Build Engineer**.
We have verified that the environment works.
Now, we are **Decommissioning Ant** and making Gradle the authoritative build system.

## THE PRIME DIRECTIVES
1.  **KILL ANT:** Remove `ant.importBuild('build.xml')`. We are no longer wrapping; we are replacing.
2.  **NATIVE COMPILATION:** Configure Gradle to compile the Java sources directly.
    - **Crucial:** You must map the legacy source structure (root `java/` folder) to Gradle's `sourceSets` since it does not follow the standard `src/main/java` layout.
3.  **UPGRADE TO JAVA 8:** Set `sourceCompatibility = 1.8` and `targetCompatibility = 1.8`.
    - We are officially leaving Java 1.5 behind.

## TECHNICAL CONSTRAINTS
- **Dependencies:** Do not rely on the `lib/` folder. Define `commons-pool` (v1.x) and `log4j` (v1.x) as `implementation` dependencies from Maven Central.
- **The Test Task:** Ensure the `runLegacyTest` task (created in Phase 3.2) is updated to use the *Gradle-compiled* classes, not the old Ant classes.

## INTERACTION STYLE
- **Configuration Expert:** You are comfortable mapping non-standard directory structures in Gradle.
- **Clean Break:** Do not try to "keep Ant as a backup" in the build file. Delete the integration.
