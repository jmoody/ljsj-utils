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

import java.sql.*;

import static com.littlejoy.mt.DriverHelper.*;

public class DriverHelperTest {

  /**
   * a logger for this class
   */
  @SuppressWarnings("unused")
  private final static Logger logger = LoggerFactory.getLogger(DriverHelperTest.class);

  @Before
  public void setUp() throws Exception {
  }

  @After
  public void tearDown() throws Exception {
  }

  @Test
  public void testMakeConnectionString () {
    String result = makeConnectionString("somehost",
                                                      1400,
                                                      "sometable",
                                                      "someuser",
                                                      "somepass");
    String expected = "jdbc:mysql://somehost:1400/sometable?user=someuser&password=somepass";
    Assert.assertEquals(expected, result);

  }

  @Test
  public void testPrintSQlExceptionDetails () {
    Connection connection = null;
    try {
      connection = DriverManager.getConnection("");
    } catch (SQLException e) {
      logSQLExceptionDetails(e, PRINT_STACK_TRACE);
    } finally {
      connection = null;
    }

    try {
      connection = DriverManager.getConnection("");
    } catch (SQLException e) {
      logSQLExceptionDetails(e, PRINT_NO_STACK_TRACE);
    } finally {
      connection = null;
    }
  }

  @Test
  public void testCloseConnection() {
    Connection connection = null;
    String url = DriverHelper.makeConnectionString(MYSQL_HOST,
                                                   MYSQL_PORT,
                                                   BOOKING_DATABASE,
                                                   MYSQL_USER,
                                                   MYSQL_PASS);
    try {
      connection = DriverManager.getConnection(url);
    } catch (SQLException e) {
      logSQLExceptionDetails(e);
    } finally {
      Assert.assertNull(DriverHelper.closeConnection(connection));
    }

    
    try {
      connection = DriverManager.getConnection(url);
      connection = null;
    } catch (SQLException e) {
      logSQLExceptionDetails(e);
    } finally {
      Assert.assertNull(DriverHelper.closeConnection(connection));
    }

    // Connection.close() is considered a nop if the connection is
    // already closed.
    // I would like a test to see what will happen if there is problem
    // closing a connection.
  }

  protected String createSelectAllStatement(String dbName, String tableName) {
    logger.debug("called with:  {dbName = {}} {tableName = {}}", dbName, tableName);
    final StringBuilder builder = new StringBuilder(128);
    builder.append("select * from ").append(dbName).append(".").append(tableName);
    return builder.toString();
  }


  @Test
  public void testCloseStatement() {
    Connection connection = null;
    String url = DriverHelper.makeConnectionString(MYSQL_HOST,
                                                   MYSQL_PORT,
                                                   BOOKING_DATABASE,
                                                   MYSQL_USER,
                                                   MYSQL_PASS);
    try {
      connection = DriverManager.getConnection(url);
      Statement statement = null;
      try {
        statement = connection.createStatement();
        String query = createSelectAllStatement(BOOKING_DATABASE, GENRE_TABLE);
        statement.executeQuery(query);
      } catch (SQLException e) {
        logSQLExceptionDetails(e);
      } finally {
        Assert.assertNull(DriverHelper.closeStatement(statement));
      }
    } catch (SQLException e) {
      logSQLExceptionDetails(e);
    } finally {
      DriverHelper.closeConnection(connection);
    }
  }

  @Test
  public void testCloseResultSet() {
    Connection connection = null;
    String url = DriverHelper.makeConnectionString(MYSQL_HOST,
                                                   MYSQL_PORT,
                                                   BOOKING_DATABASE,
                                                   MYSQL_USER,
                                                   MYSQL_PASS);
    try {
      connection = DriverManager.getConnection(url);
      Statement statement = null;
      ResultSet resultSet = null;
      try {
        statement = connection.createStatement();
        String query = createSelectAllStatement(BOOKING_DATABASE, GENRE_TABLE);
        resultSet = statement.executeQuery(query);
      } catch (SQLException e) {
        logSQLExceptionDetails(e);
      } finally {
        Assert.assertNull(DriverHelper.closeResultSet(resultSet));
        DriverHelper.closeStatement(statement);
      }
    } catch (SQLException e) {
      logSQLExceptionDetails(e);
    } finally {
      DriverHelper.closeConnection(connection);
    }
  }
}

