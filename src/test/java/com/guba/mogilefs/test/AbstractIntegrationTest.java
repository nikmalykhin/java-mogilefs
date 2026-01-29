/*
 * Abstract base class for MogileFS integration tests using TestContainers.
 * 
 * Manages the lifecycle of a MogileFS Docker container with automatic
 * startup and teardown, providing dynamic host and port configuration
 * for test subclasses.
 */
package com.guba.mogilefs.test;

import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.wait.strategy.Wait;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import java.time.Duration;
import org.junit.jupiter.api.BeforeAll;

/**
 * Abstract base class for all MogileFS integration tests.
 * 
 * Manages the lifecycle of the MogileFS Docker container. Subclasses
 * should call {@link #getTrackerConnectionString()} to get the dynamic
 * host:port connection string for the Tracker service.
 */
@Testcontainers
public abstract class AbstractIntegrationTest {

    static {
        // Disable Ryuk cleanup container for ARM compatibility
        System.setProperty("testcontainers.ryuk.disabled", "true");
    }

    /**
     * MogileFS container instance.
     * The @Container annotation ensures it's started before tests and stopped
     * after.
     */
    @Container
    public static final GenericContainer<?> mogilefs = new GenericContainer<>("hrchu/mogilefs-all-in-one:latest")
            .withExposedPorts(7001, 7500, 7501, 3306)
            .withEnv("MOGILE_ADMIN_PASSWORD", "admin")
            .withEnv("MOGILE_TRACKER_PORT", "7001")
            .withEnv("MOGILE_STORAGE_PORT", "7500")
            // Wait for any startup log output - the container script always outputs
            // something
            .waitingFor(Wait.forLogMessage(".*", 1).withStartupTimeout(Duration.ofSeconds(180)));

    /**
     * Gets the dynamic tracker connection string.
     * 
     * @return A string in the format "host:port" pointing to the running MogileFS
     *         Tracker
     */
    protected String getTrackerConnectionString() {
        return mogilefs.getHost() + ":" + mogilefs.getMappedPort(7001);
    }

    /**
     * Gets the mapped port for the Storage service (port 7500).
     * 
     * @return The mapped port number
     */
    protected int getStoragePort() {
        return mogilefs.getMappedPort(7500);
    }

    /**
     * Gets the host of the container.
     * 
     * @return The container host (usually "localhost" or "127.0.0.1")
     */
    protected String getContainerHost() {
        return mogilefs.getHost();
    }
}
