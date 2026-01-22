package com.guba.mogilefs;

import java.net.InetSocketAddress;
import java.util.List;

import org.apache.commons.pool.PoolableObjectFactory;
import org.apache.log4j.Logger;

public class PoolableBackendFactory implements PoolableObjectFactory<Backend> {

    private Logger log = Logger.getLogger(PoolableBackendFactory.class);

    private List<InetSocketAddress> trackers;

    public PoolableBackendFactory(List<InetSocketAddress> trackers) {
        log.debug("new backend factory created");

        this.trackers = trackers;
    }

    public Backend makeObject() throws Exception {
        try {
            Backend backend = new Backend(trackers, true);

            if (log.isDebugEnabled())
                log.debug("making object " + backend.toString());

            return backend;
        } catch (Exception e) {
            log.debug("problem making backend", e);

            throw e;
        }
    }

    public void destroyObject(Backend backend) throws Exception {
        if (log.isDebugEnabled())
            log.debug("destroying object '" + backend.toString() + "'");

        backend.destroy();
    }

    public boolean validateObject(Backend backend) {
        boolean connected = backend.isConnected();

        if (log.isDebugEnabled()) {
            if (!connected) {
                log.debug("validating " + backend.toString() + ". Not valid! Last err was: " + backend.getLastErr());
            } else {
                log.debug("validating " + backend.toString() + ". validated");
            }
        }

        return connected;
    }

    public void activateObject(Backend backend) throws Exception {
        // nothing to do
        if (log.isDebugEnabled())
            log.debug("activating object " + backend.toString());
    }

    public void passivateObject(Backend backend) throws Exception {
        // nothing to do
        if (log.isDebugEnabled())
            log.debug("passivating object" + backend.toString());
    }

}
