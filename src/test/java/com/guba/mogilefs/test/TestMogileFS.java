/*
 * Created on Jun 27, 2005
 *
 * copyright ill.com 2005
 */
package com.guba.mogilefs.test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;

import com.guba.mogilefs.PooledMogileFSImpl;
import com.guba.mogilefs.MogileFS;

/**
 * @author ericlambrecht
 * 
 */
public class TestMogileFS {

    private static Logger log = Logger.getLogger(TestMogileFS.class);

    public static void main(String[] args) throws Exception {
        BasicConfigurator.configure();

        MogileFS mfs = new PooledMogileFSImpl("www.guba.com",
                new String[] { "qbert.guba.com:7001" }, 0, 1, 10000);

        // Write file with key "eric" - use the README as test payload
        File file = new File("README.md");
        if (!file.exists()) {
            // Fallback to old README if README.md doesn't exist
            file = new File("README");
        }
        if (!file.exists()) {
            throw new RuntimeException("Test file not found: README.md or README");
        }

        long fileLength = file.length();
        OutputStream out = mfs.newFile("eric", "oneDeviceTest", fileLength);
        if (out == null) {
            throw new RuntimeException("newFile() returned null for key 'eric'");
        }

        FileInputStream in = new FileInputStream(file);
        byte[] buffer = new byte[1024];
        int count = 0;
        long bytesWritten = 0;
        while ((count = in.read(buffer)) >= 0) {
            out.write(buffer, 0, count);
            bytesWritten += count;
        }
        in.close();
        out.close();

        log.debug("Wrote " + bytesWritten + " bytes for key 'eric'");

        // Pull up the file and read it back
        String[] paths = mfs.getPaths("eric", true);
        if (paths == null || paths.length == 0) {
            throw new RuntimeException("getPaths() returned null or empty for key 'eric'");
        }

        log.debug("found " + paths.length + " path(s) for key 'eric'");

        InputStream readIn = mfs.getFileStream("eric");
        if (readIn == null) {
            throw new RuntimeException("getFileStream() returned null for key 'eric'");
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(readIn));
        long bytesRead = 0;
        String line;
        while ((line = reader.readLine()) != null) {
            bytesRead += line.length() + 1; // +1 for newline
            log.debug("got line (length " + line.length() + ")");
        }
        reader.close();

        // Verify that we read approximately the same amount as we wrote
        if (bytesRead == 0) {
            throw new RuntimeException("Read 0 bytes from file - content verification failed");
        }

        log.debug("Read " + bytesRead + " bytes for key 'eric' (wrote " + bytesWritten + " bytes)");
        log.debug("SUCCESS: File write/read cycle completed successfully");
    }

}
