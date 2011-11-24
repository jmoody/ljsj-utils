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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import sun.awt.image.ImageWatched;

import java.util.*;

public class Variates {

  public final int LJS_VARIATES_BAD_INTEGER_RANGE = 0;

  public final double LJS_VARIATES_BAD_DOUBLE_RANGE = 0.0;


  
  /**
   * a logger for this class
   */
  @SuppressWarnings("unused")
  private final static Logger logger = LoggerFactory.getLogger(Variates.class);

  private Random randgen;

  public Variates() {
    this.randgen = new Random();
  }

  public Variates(long seed) {
    this.randgen = new Random(seed);
  }

  public Variates(Random random) {
    this.randgen = random;
  }

  public boolean flip() {
    return this.randgen.nextBoolean();
  }

  public int integerInRange(int low, int high) {
    logger.debug("called with:  {low = {}} {high = {}}", low, high);
    int result;
    if (high >= low) {
      result = this.randgen.nextInt(high - low + 1) + low;
    } else {
      Object[] logObjects = {low, high, this.LJS_VARIATES_BAD_INTEGER_RANGE};
      logger.error("low ({}) must be <= high ({}) - returning LJS_VARIATES_BAD_INTEGER_RANGE ({})",
                   logObjects);
      result = LJS_VARIATES_BAD_INTEGER_RANGE;
    }
    logger.debug("is returning {}", result);
    return result;
  }

  public double doubleInRange(double low, double high) {
    logger.debug("called with:  {low = {}} {high = {}}", low, high);
    double result;
    if (high >= low) {
      result = this.randgen.nextDouble() * (high - low) + low;
    } else {
      Object[] logObjects = {low, high, this.LJS_VARIATES_BAD_DOUBLE_RANGE};
      logger.error("low ({}) must be <= high ({}) - returning LJS_VARIATES_BAD_DOUBLE_RANGE ({})",
                   logObjects);
      result = this.LJS_VARIATES_BAD_DOUBLE_RANGE;
    }
    logger.debug("is returning {}", result);
    return result;
  }

  public double truncateDoubleTo(double x, int places) {
    // how should i ensure that places is > 0?
    logger.debug("called with:  {x = {}} {places = {}}", x, places);
    int divisor = places * 10;
    long y = (long) (x * divisor);
    double result = (double) y / divisor;
    if (places == 0) {
      logger.error("places was = to 0 - which resulted in Double.NaN");
    }
    logger.debug("is returning {}", result);
    return result;
  }

  public <T> List<T> sampleWithReplacement(List<T> input, int subsetSize) {
    int[] indexes = new int[subsetSize];
    List<T> sampled = new ArrayList<T>();
    int maxIndex = input.size() - 1;
    for (int i = 0; i < subsetSize; i++) {
      int index = this.integerInRange(0, maxIndex);
      indexes[i] = index;
    }

    for (int index : indexes) {
      sampled.add(input.get(index));
    }

    logger.debug("is returning {}", sampled);
    return sampled;
  }

  public <T> List<T> sampleWithoutReplacement(List<T> input, int subsetSize) {
    // make sure that subsetSize is not > input.size();
    input.get(subsetSize - 1);


    Set<Integer> set = new LinkedHashSet<Integer>(subsetSize);
    int maxIndex = input.size() - 1;
    while (set.size() < subsetSize) {
      int index = this.integerInRange(0, maxIndex);
      set.add(index);
    }

    List<T> sampled = new ArrayList<T>();
    for (Integer integer : set) {
      sampled.add(input.get(integer));
    }
    
    logger.debug("is returning {}", sampled);
    return sampled;
  }
}
