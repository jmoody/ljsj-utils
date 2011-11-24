package com.littlejoy.utils.string;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;

/**
 *
 */
public class StringUtilsTest {
  @Before
  public void setUp() {
    // Add your code here
  }

  @After
  public void tearDown() {
    // Add your code here
  }

  @Test
  public void testStringBefore() {
    String testString = "foo,bar";
    String foo = "foo";
    String findFoo = StringUtils.stringBefore(testString, ",", false, 0);
    Assert.assertEquals(foo, findFoo);
    findFoo = StringUtils.stringBefore(testString, ",", 0);
    Assert.assertEquals(foo, findFoo);
    findFoo = StringUtils.stringBefore(testString, ",");
    Assert.assertEquals(foo, findFoo);
  }


  @Test
  public void testStringAfter() {
    String testString = "foo,bar";
    String bar = "bar";
    String findBar = StringUtils.stringAfter(testString, ",", false);
    Assert.assertEquals(bar, findBar);
    findBar = StringUtils.stringAfter(testString, ",");
    Assert.assertEquals(bar, findBar);
    // need a test for StringUtils.stringAfter(testString, ",", false, 0)

  }

  @Test
  public void testMakeIndentString() {
    String indentString = "    ";
    String testString = StringUtils.makeIndentString(2);
    Assert.assertEquals(indentString, testString);
  }

  @Test
  public void testArrayListOfStringsToDelimitedString() {
    String[] listOfStrings = {"foo", "bar", "baz"};
    ArrayList<String> arrayList = new ArrayList<String>();
    arrayList.addAll(Arrays.asList(listOfStrings));
    String delimited = "foo,bar,baz";
    String result = StringUtils.arrayListOfStringsToDelimitedString(arrayList, ",");
    Assert.assertEquals(delimited, result);
  }
}
