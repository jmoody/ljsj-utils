package com.littlejoy.utils.io;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

/**
 *
 */
public class StreamGobblerTest {

  /**
   * a logger for this class
   */
  @SuppressWarnings("unused")
  private static Logger logger = LoggerFactory.getLogger(StreamGobblerTest.class);

  @Before
  public void setUp() {
    // Add your code here
  }

  @After
  public void tearDown() {
    // Add your code here
  }

  @Test
  public void testCaptureOutputString() throws IOException, InterruptedException {
    Runtime runtime = Runtime.getRuntime();
    Process process = runtime.exec("ls -al");
    StreamGobbler stdout = new StreamGobbler(process.getInputStream(),
      StreamGobbler.STDOUT);
    stdout.start();
    int exitValue = process.waitFor();
    Assert.assertEquals(0, exitValue);
  }

  @Test
  public void testCaptureErrorString() throws IOException, InterruptedException {
    logger.warn("Not working as expected.");
    Runtime runtime = Runtime.getRuntime();
    Process process = runtime.exec("echo $SOMEVAR");
    StreamGobbler stderr = new StreamGobbler(process.getErrorStream(),
      StreamGobbler.STDERR);
    stderr.start();
    int exitValue = process.waitFor();
    Assert.assertEquals(0, exitValue);
  }
}

