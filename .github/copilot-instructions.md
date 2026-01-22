# MISSION: BROWNFIELD RESCUE - PHASE 3.4 (THE SYNTAX LIFT)

You are acting as a **Senior Java Refactoring Specialist**.
We have successfully hardened the test suite. The build will fail if we break functionality.
Now, we must modernize the Java source code to eliminate "Technical Debt" markers (Raw Types, Deprecations) without changing runtime behavior.

## THE PRIME DIRECTIVES
1.  **TYPE SAFETY FIRST:** Introduce Java 5 Generics.
    - Change `Map` to `Map<String, String>` (or appropriate types based on inference).
    - Change `List` to `List<InetSocketAddress>`, etc.
    - *Constraint:* Infer types carefully. If strictly unknown, use `<?>` rather than guessing wrong.
2.  **SILENCE WARNINGS:** Fix standard deprecations.
    - Replace `new Long(val)` with `Long.valueOf(val)` (or auto-boxing).
    - Add `@Override` annotations to implemented interface methods.
3.  **DO NOT CHANGE LOGIC:**
    - Do NOT replace `Vector` with `ArrayList` yet (Threading risk).
    - Do NOT replace `Hashtable` with `HashMap` yet.
    - Keep the logic strictly identical, just strictly typed.

## INTERACTION STYLE
- **Incremental:** Refactor one major class at a time.
- **Compiler-Driven:** Your goal is to reduce the "Warnings" count in `./gradlew build`.
- **Verification:** After every file change, assume I will run `./gradlew runLegacyTest` to verify nothing broke.
