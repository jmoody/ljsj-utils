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

package com.littlejoy.utils.string;

import java.util.ArrayList;
import java.util.List;

public class StringUtils {

  /**
   * an OS agnostic newline
   */
  public static final String LINE_SEPARATOR = System.getProperty("line.separator");

  /**
   * an OS agnostic file (path) separator
   */
  public static final String FILE_SEPARATOR = System.getProperty("file.separator");

  /**
   * just a space
   */
  public static final String SPACE = " ";

  /**
   * the empty string
   */
  public static final String EMPTY_STRING = "";

  /**
   * the empty string
   *
   * @deprecated Use EMPTY_STRING instead.
   */
  public static final String emptyString = "";

  /**
   * checks to see if string is parsable to number
   *
   * @param input the string to check
   *
   * @return true iif input is parseable to an integer
   */
  public static boolean stringCanParseToInteger(String input) {
    boolean result;
    try {
      Integer.parseInt(input);
      return true;
    } catch (NumberFormatException e) {
      result = false;
    }
    return result;
  }

  public static boolean stringCanParseToFloat(String input) {
    boolean result;
    try {
      Float.parseFloat(input);
      return true;
    } catch (NumberFormatException e) {
      result = false;
    }
    return result;
  }

  public static boolean stringCanParseToDouble(String input) {
    boolean result;
    try {
      Double.parseDouble(input);
      return true;
    } catch (NumberFormatException e) {
      result = false;
    }
    return result;
  }

  public static boolean stringCanParseToNumber(String input) {
    return stringCanParseToInteger(input) || stringCanParseToFloat(input) ||
      stringCanParseToDouble(input);
  }

  /**
   * Returns the part of string before the first appearance of character. (If
   * FROM-END is T, we count from the end.)  If character does not appear in
   * STRING, then we return the whole string.
   *
   * @param string a string
   * @param character a charcater (as a string)
   * @param fromEnd should we start search from the end of string for
   * character
   *
   * @return the part of the string before the first apparance of character
   */
  public static String stringBefore(String string, String character, boolean fromEnd) {
    return stringBefore(string, character, fromEnd, 0);
  }

  /**
   * Returns the part of string before the first appearance of character. (If
   * FROM-END is T, we count from the end.) If character does not appear in
   * STRING, then we return the whole string.
   *
   * @param string a string
   * @param character a charcater (as a string)
   *
   * @return the part of the string before the first apparance of character
   */
  public static String stringBefore(String string, String character) {
    return stringBefore(string, character, false, 0);
  }


  /**
   * Returns the part of string before the first appearance of character. (If
   * FROM-END is T, we count from the end.)  If character does not appear in
   * STRING, then we return the whole string.
   *
   * @param string a string
   * @param character a charcater (as a string)
   * @param start where to start collecting the substring
   *
   * @return the part of the string before the first apparance of character
   */
  public static String stringBefore(String string, String character, int start) {
    return stringBefore(string, character, false, start);
  }

  /**
   * Returns the part of string before the first appearance of character. (If
   * FROM-END is T, we count from the end.)  If character does not appear in
   * STRING, then we return the whole string.
   *
   * @param string a string
   * @param character a charcater (as a string)
   * @param fromEnd should we start search from the end of string for
   * character
   * @param start where to start collecting the substring
   *
   * @return the part of the string before the first appearance of character
   */
  public static String stringBefore(String string, String character, boolean fromEnd, int start) {
    if (string == null) {
      return string;
    }

    int position;
    if (fromEnd) {
      position = string.lastIndexOf(character);
    } else {
      position = string.indexOf(character);
    }

    String result;
    if (position == -1) {
      result = string;
    } else {
      result = string.substring(start, position);
    }
    return result;
  }


  /**
   * Returns the part of string before the first appearance of character. (If
   * FROM-END is T, we count from the end.)  If character does not appear in
   * STRING, then we return the whole string.
   *
   * @param string a string
   * @param character a character as a string
   *
   * @return the part of the string after the character
   */
  public static String stringAfter(String string, String character) {
    return stringAfter(string, character, false, string.length());
  }

  /**
   * Returns the part of string before the first appearance of character. (If
   * FROM-END is T, we count from the end.)  If character does not appear in
   * STRING, then we return the whole string.
   *
   * @param string a string
   * @param character a character as a string
   * @param end where to stop collecting the substring
   *
   * @return the part of the string after the character
   */
  public static String stringAfter(String string, String character, int end) {
    return stringAfter(string, character, false, end);
  }


  /**
   * Returns the part of string before the first appearance of character. (If
   * FROM-END is T, we count from the end.)  If character does not appear in
   * STRING, then we return the whole string.
   *
   * @param string a string
   * @param character a character as a string
   * @param fromEnd should we start search from the end of string for
   * character
   *
   * @return the part of the string after the character
   */
  public static String stringAfter(String string, String character, boolean fromEnd) {
    return stringAfter(string, character, fromEnd, string.length());
  }

  /**
   * Returns the part of string before the first appearance of character. (If
   * FROM-END is T, we count from the end.)  If character does not appear in
   * STRING, then we return the whole string.
   *
   * @param string a string
   * @param character a character as a string
   * @param fromEnd should we start search from the end of string for
   * character
   * @param end where to stop collecting the substring
   *
   * @return the part of the string after the character
   */
  public static String stringAfter(String string, String character, boolean fromEnd, int end) {
    if (string == null) {
      return string;
    }

    int position;
    if (fromEnd) {
      position = string.lastIndexOf(character);
    } else {
      position = string.indexOf(character);
    }

    String result;
    if (position == -1) {
      result = string;
    } else {
      ++position;
      result = string.substring(position, end);
    }
    return result;
  }

  /**
   * creates a string of spaces 2x the size of the length argument
   * <p/>
   * for example:  if length == 2, then indent string will be "    " (four spaces)
   *
   * @param length the indent depth
   *
   * @return a string of spaces 2x the size of the length argument
   */
  public static String makeIndentString(int length) {
    StringBuilder builder = new StringBuilder();
    for (int i = 0; i < length; i++) {
      builder.append("  ");
    }
    return builder.toString();
  }

  /**
   * creates a delimited string from an array list of strings
   * <p/>
   * for example, if the array is ["foo" "bar" "baz"] and the delimiter is
   * "," - the result is "foo,bar,baz"
   *
   * @param strings an array list of strings
   * @param delimiter the delimiter
   *
   * @return returns a delimited string from a list of strings
   *
   * @deprecated use arrayListOfStringToBeDelimitedString(List<String>, String)
   */
  public static String arrayListOfStringsToDelimitedString(ArrayList<String> strings, String delimiter) {
    StringBuilder builder = new StringBuilder(256);
    int counter = 0;
    int length = strings.size();
    for (String string : strings) {
      builder.append(string);
      if (++counter != length) {
        builder.append(delimiter);
      }
    }
    return builder.toString();
  }

  /**
   * creates a delimited string from an list of strings
   * <p/>
   * for example, if the array is ["foo" "bar" "baz"] and the delimiter is
   * "," - the result is "foo,bar,baz"
   *
   * @param strings an list of strings
   * @param delimiter the delimiter
   *
   * @return returns a delimited string from a list of strings
   */
  public static String arrayListOfStringsToDelimitedString(List<String> strings, String delimiter) {
    StringBuilder builder = new StringBuilder(256);
    int counter = 0;
    int length = strings.size();
    for (String string : strings) {
      builder.append(string);
      if (++counter != length) {
        builder.append(delimiter);
      }
    }
    return builder.toString();
  }
}
