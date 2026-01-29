/*
 * Created on Jun 27, 2005
 *
 * copyright ill.com 2005
 */
package com.guba.mogilefs.test;

import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Tag;

import com.guba.mogilefs.Backend;

/**
 * @author ericlambrecht
 * 
 */
public class TestBackend extends AbstractIntegrationTest {
    private static Logger log = Logger.getLogger(TestBackend.class);

    @Test
    @Tag("integration")
    void testBackendEcho() throws Exception {
        BasicConfigurator.configure();

        // Test 1: Constructor and connection
        String trackerConnectionString = getTrackerConnectionString();
        String[] hostPort = trackerConnectionString.split(":");
        List<InetSocketAddress> trackers = new ArrayList<InetSocketAddress>();
        trackers.add(new InetSocketAddress(hostPort[0], Integer.parseInt(hostPort[1])));
        Backend backend = new Backend(trackers, true);
        Assertions.assertNotNull(backend, "Backend should be successfully constructed and connected");

        // Test 2: ECHO command - verify Backend correctly handles error responses
        // Note: ECHO is NOT a valid MogileFS command - we expect an error response
        String trackerConnectionString2 = getTrackerConnectionString();
        String[] hostPort2 = trackerConnectionString2.split(":");
        List<InetSocketAddress> trackers2 = new ArrayList<InetSocketAddress>();
        trackers2.add(new InetSocketAddress(hostPort2[0], Integer.parseInt(hostPort2[1])));
        Backend backend2 = new Backend(trackers2, true);
        Map<?, ?> response = backend2.doRequest("ECHO", new String[] { "eric", "r00lez" });

        // Backend.doRequest() returns null when tracker sends error response
        // This is expected behavior for invalid commands
        Assertions.assertNull(response, "ECHO command should return null for invalid command");

        // Verify that lastErr and lastErrStr were populated by Backend
        String lastErr = backend2.getLastErr();
        String lastErrStr = backend2.getLastErrStr();

        Assertions.assertNotNull(lastErr, "Backend should set lastErr when command fails");
        Assertions.assertFalse(lastErr.isEmpty(), "Backend lastErr should not be empty");

        log.debug("ECHO correctly returned error: " + lastErr + " - " + lastErrStr);
        log.debug("Backend error handling verified successfully");
    }
}
