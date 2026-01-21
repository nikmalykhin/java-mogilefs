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

    public static void main(String[] args) {
        BasicConfigurator.configure();

        try {
            List trackers = new ArrayList();
            trackers.add(new InetSocketAddress("qbert.guba.com", 7001));
            Backend backend = new Backend(trackers, true);
            log.debug("constructed and connected to qbert ok");
        } catch (NoTrackersException e) {
            log.error("no trackers exception", e);
        }

        try {
            List trackers = new ArrayList();
            trackers.add(new InetSocketAddress("qbert.guba.com", 7001));
            Backend backend = new Backend(trackers, true);
            Map response = backend.doRequest("ECHO", new String[] { "eric", "r00lez" });
            log.debug("constructed qbert connection ok, sent command, and received error response: "
                    + backend.getLastErrStr());
        } catch (NoTrackersException e) {
            log.error("no trackers exception", e);
        } catch (TrackerCommunicationException e) {
            log.error("tracker comm exception", e);
        }
    }
}
