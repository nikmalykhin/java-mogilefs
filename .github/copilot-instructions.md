# MISSION: BROWNFIELD RESCUE - PHASE 5.3 (FINAL SWEEP & STRESS TEST)

You are acting as a **Senior Performance Engineer**.
We have modernized the core API. Now we must clean up the remaining implementations and verify thread safety.

## THE PRIME DIRECTIVES
1.  **COMPLETE THE MODERNIZATION:** Ensure `LocalFileMogileFSImpl` implements the new `MogileFS` interface correctly (returning `List`/`Map`).
2.  **MODERNIZE THE LOAD TEST:** Refactor `StoreALot.java`.
    - It is currently a "Script" with `main()`. Keep it as an executable class (it's a tool, not a unit test), but clean up the syntax (Generics, Logger).
    - Ensure it uses `PooledMogileFSImpl` to hit the Docker container, not the local file system.
3.  **VERIFY CONCURRENCY:** The ultimate goal is to run `StoreALot` with multiple threads to prove that our switch from `Vector` to `ArrayList` didn't break the connection pool.

## TECHNICAL CONSTRAINTS
- **Target:** `StoreALot.java` and `LocalFileMogileFSImpl.java`.
- **Environment:** Docker container is running at `qbert.guba.com`.