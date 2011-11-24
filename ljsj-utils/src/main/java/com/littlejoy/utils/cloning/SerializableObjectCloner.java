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

package com.littlejoy.utils.cloning;

import java.io.*;

/**
 * Deep-copy of Serializable objects
 */
public class SerializableObjectCloner {

  public static Object clone(Object original) {
    Object clone = null;
    try {
      // Increased buffer size to speed up writing
      ByteArrayOutputStream bos = new ByteArrayOutputStream(5120);
      if (!writeObjectToStream(bos, original)) {
        return null;
      }

      ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
      clone = readObjectFromStream(bis);
      bos.close();
    } catch (Exception e) {
      e.printStackTrace();
    }
    return clone;
  }

  public static boolean writeObjectToStream(OutputStream os, Object original) {
    try {
      ObjectOutputStream out = new ObjectOutputStream(os);
      out.writeObject(original);
      out.flush();
      out.close();
      return true;
    } catch (IOException e) {
      e.printStackTrace();
    }
    return false;
  }


  public static Object readObjectFromStream(InputStream is) {
    try {
      ObjectInputStream in = new ObjectInputStream(is);
      Object clone = in.readObject();
      in.close();
      return clone;
    } catch (IOException e) {
      e.printStackTrace();
    } catch (ClassNotFoundException cnfe) {
      cnfe.printStackTrace();
    }

    return null;
  }
}

