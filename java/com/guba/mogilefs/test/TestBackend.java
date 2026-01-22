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

import com.guba.mogilefs.Backend;
import com.guba.mogilefs.NoTrackersException;
import com.guba.mogilefs.TrackerCommunicationException;

/**
 * @author ericlambrecht
 * 
 */
public class TestBackend {
    private static Logger log = Logger.getLogger(TestBackend.class);

    public static void main(String[] args) throws Exception {
        BasicConfigurator.configure();

        // Test 1: Constructor and connection
        List trackers = new ArrayList();
        trackers.add(new InetSocketAddress("qbert.guba.com", 7001));
        Backend backend = new Backend(trackers, true);
        log.debug("constructed and connected to qbert ok");

        // Test 2: ECHO command - verify Backend correctly handles error responses
        // Note: ECHO is NOT a valid MogileFS command - we expect an error response
        List trackers2 = new ArrayList();
        trackers2.add(new InetSocketAddress("qbert.guba.com", 7001));
        Backend backend2 = new Backend(trackers2, true);
        Map response = backend2.doRequest("ECHO", new String[] { "eric", "r00lez" });

        // Backend.doRequest() returns null when tracker sends error response
        // This is expected behavior for invalid commands
        if (response == null) {
            // Verify that lastErr and lastErrStr were populated by Backend
            String lastErr = backend2.getLastErr();
            String lastErrStr = backend2.getLastErrStr();

            if (lastErr == null || lastErr.isEmpty()) {
                throw new RuntimeException("Backend returned null but did not set lastErr");
            }

            log.debug("ECHO correctly returned error: " + lastErr + " - " + lastErrStr);
            log.debug("Backend error handling verified successfully");
        } else {
            // If response is not null, ECHO somehow succeeded (unexpected!)
            throw new RuntimeException("ECHO command unexpectedly succeeded - tracker may have changed");
        }
    }
}
