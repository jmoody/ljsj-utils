package com.littlejoy.utils.io;

import org.junit.Assert;
import org.junit.Test;

import java.io.File;
import java.io.IOException;

/**
 *
 */
public class CompressTest {

  private static final String FILE_TO_GZIP = "src/test/resources/file-to-gzip.txt";

  private static final String TARGET_OF_GZIP = "src/test/resources/file-to-gzip.txt.gz";
  private static final String DIRECTORY_TO_ZIP = "src/test/resources/directory-to-zip";
  private static final String TARGET_OF_ZIP = "src/test/resources/directory-to-zip.zip";

  @Test
  public void testGzipFile() throws IOException {
    Compress.gzipFile(FILE_TO_GZIP, TARGET_OF_GZIP);
    File result = new File(TARGET_OF_GZIP);
    Assert.assertTrue(result.exists());
    result.deleteOnExit();
  }

  @Test
  public void testZipDirectory() throws IOException {
    Compress.zipDirectory(DIRECTORY_TO_ZIP, TARGET_OF_ZIP);
    File result = new File(TARGET_OF_ZIP);
    Assert.assertTrue(result.exists());
    result.deleteOnExit();
  }
}
