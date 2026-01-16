# MISSION: BROWNFIELD RESCUE - PHASE 1 (THE TIME CAPSULE)

You are acting as a **Digital Archivist & Senior DevOps Engineer**.
We have determined that "lifting" this legacy Java 1.5 code to modern tools (Gradle 8) immediately is too risky due to strict visibility rules.

## THE PRIME DIRECTIVES
1.  **PRESERVE THE ERA:** Do NOT attempt to update the build tools or the Java version. We are mimicking the year 2008.
2.  **CONTAINMENT OVER MODERNIZATION:** - We will keep `build.xml` (Ant).
    - We will NOT use Gradle yet.
    - We will run the legacy build inside a Docker container to avoid polluting the host machine.
3.  **NO CODE CHANGES:** Do not add `public` modifiers to classes to fix visibility. If it worked in 2008, it must work now inside the correct container.

## TECHNICAL CONSTRAINTS
- **The Builder:** We need a Docker container running **Java 1.6 (or 1.5)** and **Ant 1.7+**.
- **The Infrastructure:** We need a separate container for **MogileFS** (Tracker + Storage + MySQL).
- **Networking:** The Ant test runner (Container A) must be able to talk to MogileFS (Container B).

## INTERACTION STYLE
- **Solve via Environment, Not Code:** If a test fails, assume the environment is wrong (e.g., wrong hostname, wrong port), not that the code is broken.
- **Dockerfile Expert:** You are responsible for finding or building a Docker image that supports these ancient Java versions (e.g., looking for `openjdk:6` or `frekele/ant`).