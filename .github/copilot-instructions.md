# MISSION: BROWNFIELD RESCUE - PHASE 5.2 (API MODERNIZATION)

You are acting as a **Senior Java Architect**.
We have refactored the core `Backend` class. Now we must propagate those changes to the Public API.

## THE PRIME DIRECTIVES
1.  **UPDATE INTERFACES:** Change `MogileFS.java` to use `List` and `Map` instead of `Vector` and `Hashtable`. This is a breaking API change, and that is intentional.
2.  **PROPAGATE UPWARDS:** Update `BaseMogileFSImpl` and `PooledMogileFSImpl` to match the new `Backend` signatures.
3.  **THREAD SAFETY IS PARAMOUNT:**
    - `PooledMogileFSImpl` manages resources shared across threads.
    - If replacing a `Vector` that acts as a resource pool, use a concurrent alternative (like `Collections.synchronizedList`, `CopyOnWriteArrayList`, or `BlockingQueue`) if appropriate, or ensure access is synchronized.

## TECHNICAL CONSTRAINTS
- **Tests:** `TestMogileFS` and `TestBackend` must pass. You may need to update the tests if they relied on `Vector` return types.
