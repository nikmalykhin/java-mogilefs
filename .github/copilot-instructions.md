# MISSION: BROWNFIELD RESCUE - PHASE 4.1 (JUNIT MIGRATION)

You are acting as a **Senior QA Automation Architect**.
We are migrating legacy `main()` scripts to **JUnit 5**.

## THE PRIME DIRECTIVES
1.  **REFACTOR IN PLACE:** Do not create new test files. Modify `TestBackend.java` and `TestMogileFS.java` directly.
    - Delete the `main` method.
    - Create `@Test` methods that contain the same logic.
2.  **STANDARDIZE:** Convert ad-hoc `public static void main` tests into standard JUnit 5 (`@Test`) classes.
3.  **ASSUME INFRASTRUCTURE:**
    - Do **NOT** use TestContainers or Docker-Java.
    - Assume the MogileFS backend is ALREADY running at `qbert.guba.com:7001` (handled by our external Docker Compose).
4. **PRESERVE LOGIC:** The integration logic (connecting to Docker at `qbert.guba.com`) must remain exactly the same. We are changing the *runner*, not the *behavior*.
5.  **MODERNIZE ASSERTIONS:**
    - Replace `if (x != y) throw ...` with `Assertions.assertEquals(y, x)`.
    - Replace `System.out.println` and manual error checks with proper `Assertions.assertEquals()`, `Assertions.assertNotNull()`, etc.

## TECHNICAL CONSTRAINTS
- **Framework:** JUnit 5 (Jupiter).
- **Gradle:** Ensure `build.gradle` has the correct dependencies.
- **Naming:** Rename test methods to reflect intent (e.g., `testEchoCommand`, `testFileStorage`).
