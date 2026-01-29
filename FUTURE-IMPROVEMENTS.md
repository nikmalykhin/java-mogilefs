# Future Improvements

### 1. Backend Error Handling

**Current:** `Backend.doRequest()` returns `null` on tracker errors

**Location:** `Backend.java` line 249

```java
if (err.matches()) {
    lastErr = err.group(ERR_PART);
    lastErrStr = err.group(ERRSTR_PART);
    return null;  // ← Callers must check for null
}
```

**Recommendation:** Throw typed exceptions instead

```java
if (err.matches()) {
    String errCode = err.group(ERR_PART);
    String errMsg = err.group(ERRSTR_PART);
    throw new MogileTrackerException(errCode, errMsg);
}
```

**Benefits:**

- Explicit error handling
- No silent null checks
- Better stack traces

**Impact:** Breaking API change - requires updating all callers

---

### 2. TestBackend Uses Invalid Command

**Current:** Tests error handling using `ECHO` command (not valid MogileFS command)

**Recommendation:** Use `noop` (official no-op command) for connectivity testing

```java
Map<?, ?> response = backend.doRequest("noop", new String[] {});
Assertions.assertNotNull(response, "noop should succeed");
```

**Benefits:**

- Tests real MogileFS command
- Better represents actual usage
- More reliable connectivity check

**Priority:** Low (current ECHO test validates error handling correctly)

---

### 3. Code Modernization

**Current State:** Java 8 compatibility, 2008-era patterns

**Potential Improvements:**

- Upgrade to Java 11+ (LTS)
- Replace raw threads with `ExecutorService` in StoreALot
- Use try-with-resources for all `InputStream`/`OutputStream`
- Add `@Nullable`/`@NonNull` annotations
- Consider replacing commons-pool with modern connection pooling

**Priority:** Low (code works, no pressing need)

---

### 4. Test Infrastructure

**Potential Enhancements:**

- Add code coverage reporting (JaCoCo)
- Parameterized tests (different file sizes, concurrent thread counts)
- Performance benchmarks for throughput
- CI/CD integration (GitHub Actions)
- Test file cleanup (delete uploaded files after tests)

**Priority:** Medium (nice-to-have, not critical)

---

### 5. TestContainers Migration

**Current:** External Docker Compose infrastructure

**Alternative:** TestContainers for self-contained tests

**Benefits:**

- Tests manage their own containers
- No external setup required
- Better isolation between test runs
- Easier CI/CD integration

**Drawbacks:**

- More complex setup
- Longer test startup time
- Requires Docker-in-Docker for some CI systems

**Priority:** Low (current approach works well)
