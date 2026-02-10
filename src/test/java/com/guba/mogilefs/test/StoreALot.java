package com.guba.mogilefs.test;

import java.io.File;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;

import com.guba.mogilefs.BadHostFormatException;
import com.guba.mogilefs.MogileFS;
import com.guba.mogilefs.NoTrackersException;
import com.guba.mogilefs.PooledMogileFSImpl;

/**
 * Load test tool for stress testing concurrent MogileFS operations.
 * Demonstrates thread-safe connection pooling with the ArrayList-based pool.
 */
public class StoreALot {

    private static final Logger log = Logger.getLogger(StoreALot.class);
    private static final String DOCKER_TRACKER = "qbert.guba.com:7001";
    private static final String DOMAIN = "www.guba.com";
    private static final String STORAGE_CLASS = "oneDeviceTest";

    public static void main(String[] args) throws Exception {
        BasicConfigurator.configure();

        int iterations = 100;
        int threadCount = 10;

        // Parse command-line arguments if provided
        if (args.length >= 1) {
            try {
                iterations = Integer.parseInt(args[0]);
            } catch (NumberFormatException e) {
                log.warn("Invalid iterations argument, using default: " + iterations);
            }
        }

        if (args.length >= 2) {
            try {
                threadCount = Integer.parseInt(args[1]);
            } catch (NumberFormatException e) {
                log.warn("Invalid threadCount argument, using default: " + threadCount);
            }
        }

        runConcurrentLoadTest(iterations, threadCount);
    }

    private static void runConcurrentLoadTest(int iterations, int threadCount) {
        log.info("═══════════════════════════════════════════════════════════════");
        log.info("Starting Concurrent Load Test");
        log.info("  Iterations per thread: " + iterations);
        log.info("  Thread count: " + threadCount);
        log.info("  Total operations: " + (iterations * threadCount));
        log.info("  Tracker endpoint: " + DOCKER_TRACKER);
        log.info("  Domain: " + DOMAIN);
        log.info("═══════════════════════════════════════════════════════════════");

        File testFile = resolveTestFile();
        if (testFile == null) {
            log.error("Test file not found. Aborting.");
            System.exit(1);
        }

        MogileFS mfs;
        try {
            // Connect to Docker container via connection pool
            mfs = new PooledMogileFSImpl(
                    DOMAIN,
                    new String[] { DOCKER_TRACKER },
                    10, // maxTrackerConnections
                    5, // maxIdleConnections
                    10000 // maxIdleTimeMillis
            );
            log.info("Connected to MogileFS pool at " + DOCKER_TRACKER);
        } catch (NoTrackersException | BadHostFormatException e) {
            log.error("Failed to connect to MogileFS tracker: " + e.getMessage(), e);
            System.exit(1);
            return;
        }

        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger errorCount = new AtomicInteger(0);
        ExecutorService executor = Executors.newFixedThreadPool(threadCount);
        CountDownLatch latch = new CountDownLatch(threadCount);

        long startTime = System.currentTimeMillis();

        // Submit tasks to executor
        for (int i = 0; i < threadCount; i++) {
            executor.submit(new StoreSomething(mfs, testFile, iterations, latch, successCount, errorCount));
        }

        // Wait for all tasks to complete
        try {
            boolean completed = latch.await(5, TimeUnit.MINUTES);
            long elapsedTime = System.currentTimeMillis() - startTime;

            log.info("═══════════════════════════════════════════════════════════════");
            log.info("Test Results:");
            log.info("  Completed: " + completed);
            log.info("  Elapsed time: " + elapsedTime + " ms");
            log.info("  Successful operations: " + successCount.get());
            log.info("  Failed operations: " + errorCount.get());
            log.info(
                    "  Throughput: " + String.format("%.2f", (successCount.get() * 1000.0 / elapsedTime)) + " ops/sec");
            log.info("═══════════════════════════════════════════════════════════════");

            if (!completed || errorCount.get() > 0) {
                log.error("Test FAILED: Not all operations completed successfully");
                System.exit(1);
            } else {
                log.info("Test PASSED: All concurrent operations completed successfully");
            }
        } catch (InterruptedException e) {
            log.error("Test interrupted: " + e.getMessage(), e);
            System.exit(1);
        } finally {
            executor.shutdown();
            try {
                if (!executor.awaitTermination(10, TimeUnit.SECONDS)) {
                    executor.shutdownNow();
                }
            } catch (InterruptedException e) {
                executor.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
    }

    private static File resolveTestFile() {
        String[] candidates = { "README.md", "README", "build.gradle" };
        for (String candidate : candidates) {
            File f = new File(candidate);
            if (f.exists()) {
                log.info("Using test file: " + f.getAbsolutePath());
                return f;
            }
        }
        return null;
    }
}

class StoreSomething implements Runnable {

    private static final Logger log = Logger.getLogger(StoreSomething.class);

    private final MogileFS mfs;
    private final File file;
    private final int iterations;
    private final CountDownLatch latch;
    private final AtomicInteger successCount;
    private final AtomicInteger errorCount;

    public StoreSomething(MogileFS mfs, File file, int iterations,
            CountDownLatch latch, AtomicInteger successCount, AtomicInteger errorCount) {
        this.mfs = mfs;
        this.file = file;
        this.iterations = iterations;
        this.latch = latch;
        this.successCount = successCount;
        this.errorCount = errorCount;
    }

    @Override
    public void run() {
        Thread currentThread = Thread.currentThread();
        log.info("[" + currentThread.getName() + "] Starting " + iterations + " storage operations");

        try {
            for (int i = 0; i < iterations; i++) {
                String key = "loadtest-" + System.identityHashCode(currentThread) + "-" + System.nanoTime();
                try {
                    mfs.storeFile(key, "oneDeviceTest", file);
                    successCount.incrementAndGet();
                    if ((i + 1) % 10 == 0) {
                        log.debug("[" + currentThread.getName() + "] Progress: " + (i + 1) + "/" + iterations);
                    }
                } catch (Exception e) {
                    log.error("[" + currentThread.getName() + "] Error storing file " + key + ": " + e.getMessage());
                    errorCount.incrementAndGet();
                }
            }
            log.info("[" + currentThread.getName() + "] Completed " + iterations + " operations");
        } finally {
            latch.countDown();
        }
    }
}
