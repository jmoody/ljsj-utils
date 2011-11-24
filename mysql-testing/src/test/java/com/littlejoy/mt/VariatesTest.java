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

package com.littlejoy.mt;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

public class VariatesTest {

  /**
   * a logger for this class
   */
  @SuppressWarnings("unused")
  private final static Logger logger = LoggerFactory.getLogger(VariatesTest.class);

  protected Variates variates;

  protected List<Number> numbers;

  @Before
  public void setUp() throws Exception {
    variates = new Variates();
    this.numbers = new ArrayList<Number>();
    for (int i = 1; i < 10; i++) {
      this.numbers.add(i);
    }
  }

  @After
  public void tearDown() throws Exception {
    variates = null;
    this.numbers.clear();
    this.numbers = null;
  }

  @Test
  public void testFlip() throws Exception {
    boolean result = this.variates.flip();
    logger.debug("flip returned {}", result);

  }

  @Test
  public void testIntegerInRange() {

    int low = 1;
    int high = 1;

    int result = variates.integerInRange(low, high);
    Assert.assertEquals(1, result);
    Assert.assertEquals(-1, variates.integerInRange(-1,-1));
    Assert.assertEquals(0, variates.integerInRange(0,0));

    result = variates.integerInRange(1,2);
    Assert.assertTrue(result >= 1 && result <= 2);

    Assert.assertEquals(variates.LJS_VARIATES_BAD_INTEGER_RANGE,
                        variates.integerInRange(2,1));

  }

  @Test
  public void testDoubleInRange() {
    Assert.assertEquals(variates.LJS_VARIATES_BAD_DOUBLE_RANGE,
                        variates.doubleInRange(2.0,1.0), 0.0);

    Assert.assertEquals(2.0, variates.doubleInRange(2.0,2.0), 0.0);
    Assert.assertEquals(-2.0, variates.doubleInRange(-2.0,-2.0), 0.0);
    double result = variates.doubleInRange(1.0, 2.0);
    Assert.assertTrue(result >= 1.0 && result <= 2.0);
  }

  @Test
  public void testTruncateDoubleTo() {
    double number = 1.75432425225;
    // will return number
    variates.truncateDoubleTo(number, 0);
    
    double truncated = variates.truncateDoubleTo(number, 1);
    Assert.assertEquals(3, ("" + truncated).length());
    Assert.assertEquals(4, ("" + variates.truncateDoubleTo(number, 2)).length());
  }

  @Test(expected = NegativeArraySizeException.class)
  public void testSampleWithReplacementNegativeRange() {
    // throws NegativeArraySizeException
    variates.sampleWithReplacement(numbers, -1);
  }

  @Test(expected = IndexOutOfBoundsException.class)
  public void testSampleWithReplacementWithEmptyArray() {
    variates.sampleWithReplacement(new ArrayList<Number>(), 11);
  }

  @Test
  public void testSampleWithReplacement() {

    Assert.assertEquals(1, variates.sampleWithReplacement(this.numbers, 1).size());
    Assert.assertEquals(0, variates.sampleWithReplacement(this.numbers, 0).size());
    Assert.assertEquals(5, variates.sampleWithReplacement(this.numbers, 5).size());
    Assert.assertEquals(11, variates.sampleWithReplacement(this.numbers, 11).size());
  }

  @Test(expected = IndexOutOfBoundsException.class)
  public void testSampleWithoutReplacementSubsetToLarge() {
    variates.sampleWithoutReplacement(this.numbers, 11);
  }

  @Test(expected = ArrayIndexOutOfBoundsException.class)
  public void testSampleWithReplaceSubsetIsNegative() {
    variates.sampleWithoutReplacement(this.numbers, -1);
  }

  @Test(expected = IndexOutOfBoundsException.class)
  public void testSampleWithReplacementEmptyArray() {
    variates.sampleWithoutReplacement(new ArrayList<Number>(), 11);
  }

  @Test(expected = NullPointerException.class)
  public void testSampleWithReplacementNullArray() {
    variates.sampleWithoutReplacement(null, 11);
  }

  @Test
  public void testSampleWithoutReplacement() {
    Assert.assertEquals(this.numbers.size(), variates.sampleWithoutReplacement(this.numbers, 9).size());
    Assert.assertEquals(3, variates.sampleWithoutReplacement(this.numbers, 3).size());

    
  }
}
