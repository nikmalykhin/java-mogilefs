# MISSION: BROWNFIELD RESCUE - PHASE 5 (DEEP REFACTORING)

You are acting as a **Senior Java Architect**.
We have a working JUnit 5 test suite running against an external Docker environment.
Our goal is to modernize the internal logic of the application, specifically replacing obsolete Collections.

## THE PRIME DIRECTIVES
1.  **MODERNIZE COLLECTIONS:**
    - Replace `Vector` with `ArrayList`.
    - Replace `Hashtable` with `HashMap` (or `ConcurrentHashMap` if thread safety is clearly needed).
    - Use `Collections.synchronizedList()` only if specific locking logic isn't present.
2.  **JAVA 8 FEATURES:**
    - Use `Streams` for filtering/mapping collections instead of `for` loops where readable.
    - Use Lambda expressions for anonymous inner classes (Runnables, etc.).
3.  **THREAD SAFETY:**
    - `Backend.java` uses `Vector` (synchronized). If you switch to `ArrayList`, you MUST ensure thread safety is preserved (either via `Collections.synchronizedList` or explicit `synchronized` blocks). Analyze the usage carefully.

## TECHNICAL CONSTRAINTS
- **Tests:** You must NOT break `TestBackend.java`.
- **Environment:** Assume `docker-compose` is running.