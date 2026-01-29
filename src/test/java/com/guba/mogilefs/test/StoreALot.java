package com.guba.mogilefs.test;

import java.io.File;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Tag;

import com.guba.mogilefs.MogileFS;
import com.guba.mogilefs.PooledMogileFSImpl;

public class StoreALot {

    private static Logger log = Logger.getLogger(StoreALot.class);

    @Test
    @Tag("integration")
    void testConcurrentFileStorage() throws Exception {
        BasicConfigurator.configure();

        // Configuration
        File testFile = new File("README.md");
        if (!testFile.exists()) {
            testFile = new File("README");
        }
        Assertions.assertTrue(testFile.exists(), "Test file not found: README.md or README");

        int threadCount = 5; // Number of concurrent storage operations

        MogileFS mfs = new PooledMogileFSImpl("www.guba.com",
                new String[] { "qbert.guba.com:7001" }, 0, 2, 10000);

        CountDownLatch latch = new CountDownLatch(threadCount);
        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger errorCount = new AtomicInteger(0);

        log.info("Starting concurrent storage test with " + threadCount + " threads");

        for (int i = 0; i < threadCount; i++) {
            Thread thread = new Thread(new StoreSomething(mfs, testFile, latch, successCount, errorCount));
            thread.start();
        }

        // Wait for all threads to complete (max 60 seconds)
        boolean completed = latch.await(60, java.util.concurrent.TimeUnit.SECONDS);

        Assertions.assertTrue(completed, "All threads should complete within timeout");
        Assertions.assertEquals(threadCount, successCount.get(), "All storage operations should succeed");
        Assertions.assertEquals(0, errorCount.get(), "No errors should occur");

        log.info("Concurrent storage test completed: " + successCount.get() + " successful, " + errorCount.get()
                + " errors");
    }
}

class StoreSomething implements Runnable {

    private static Logger log = Logger.getLogger(StoreSomething.class);

    private MogileFS mfs;
    private File file;
    private CountDownLatch latch;
    private AtomicInteger successCount;
    private AtomicInteger errorCount;

    public StoreSomething(MogileFS mfs, File file, CountDownLatch latch,
            AtomicInteger successCount, AtomicInteger errorCount) {
        this.mfs = mfs;
        this.file = file;
        this.latch = latch;
        this.successCount = successCount;
        this.errorCount = errorCount;
    }

    public void run() {
        try {
            String key = "test-" + Thread.currentThread().threadId() + "-" + System.currentTimeMillis();

            log.info("Starting store of " + key);
            mfs.storeFile(key, "oneDeviceTest", file);
            log.info("Ending store of " + key);

            successCount.incrementAndGet();

            // Optional: delete after storing (currently commented for verification)
            // log.info("Starting delete of " + key);
            // mfs.delete(key);
            // log.info("Ending delete of " + key);

        } catch (Exception e) {
            log.error("Error storing file: " + e.getMessage(), e);
            errorCount.incrementAndGet();
        } finally {
            latch.countDown();
        }
    }

}
