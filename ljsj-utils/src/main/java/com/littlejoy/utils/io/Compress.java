/*
 * Copyright (c) 2010, Little Joy Software
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in
 *       the documentation and/or other materials provided with the
 *       distribution.
 *     * Neither the name of the Little Joy Software nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY LITTLE JOY SOFTWARE ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LITTLE JOY SOFTWARE BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.littlejoy.utils.io;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.GZIPOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * cribbed from:
 * <p/>
 * http://www.java2s.com/Code/Java/File-Input-Output/CompressfilesusingtheJavaZIPAPI.htm
 */
public class Compress {

  /**
   * gzips a file
   *
   * @param from the source
   * @param to the target
   *
   * @throws IOException if there is a problem reading or writing the files
   */
  public static void gzipFile(String from, String to) throws IOException {
    FileInputStream in = new FileInputStream(from);
    GZIPOutputStream out = new GZIPOutputStream(new FileOutputStream(to));
    byte[] buffer = new byte[4096];
    int bytesRead;
    while ((bytesRead = in.read(buffer)) != -1) {
      out.write(buffer, 0, bytesRead);
    }
    in.close();
    out.close();
  }

  /**
   * Zip the contents of the directory, and save it in the zipfile
   *
   * @param dir the directory to compress
   * @param zipfile the target file
   *
   * @throws IOException if there is problem reading or writing the files
   * @throws IllegalArgumentException if dir does not refer to a directory
   */
  public static void zipDirectory(String dir, String zipfile)
    throws IOException, IllegalArgumentException {
    // Check that the directory is a directory, and get its contents
    File d = new File(dir);
    if (!d.isDirectory()) {
      throw new IllegalArgumentException("Not a directory:  "
        + dir);
    }
    String[] entries = d.list();
    byte[] buffer = new byte[4096]; // Create a buffer for copying
    int bytesRead;

    ZipOutputStream out = new ZipOutputStream(new FileOutputStream(zipfile));

    for (String entry1 : entries) {
      File f = new File(d, entry1);
      if (f.isDirectory()) {
        continue;//Ignore directory
      }
      FileInputStream in = new FileInputStream(f); // Stream to read file
      ZipEntry entry = new ZipEntry(f.getPath()); // Make a ZipEntry
      out.putNextEntry(entry); // Store entry
      while ((bytesRead = in.read(buffer)) != -1) {
        out.write(buffer, 0, bytesRead);
      }
      in.close();
    }
    out.close();
  }
}
