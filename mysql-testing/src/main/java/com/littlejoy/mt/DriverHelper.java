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

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;


public class DriverHelper {

  /**
   * a logger for this class
   */
  @SuppressWarnings("unused")
  private final static Logger logger = LoggerFactory.getLogger(DriverHelper.class);

  protected static final String MYSQL_USER = "moody";
  protected static final String MYSQL_PASS = "2dulaher";
  protected static final String BOOKING_DATABASE = "booking";
  protected static final String MYSQL_HOST = "localhost";
  protected static final int MYSQL_PORT = 3306;
  private static final String MYSQL_PROTOCOL = "jdbc:mysql://";

  protected static final String PERFORMER_TABLE = "performer";
  protected static final String GENRE_TABLE = "genre";
  protected static final String VENUE_TABLE = "venue";
  protected static final String ADDRESS_TABLE = "address";
  protected static final String PERFORMANCES_TABLE = "performance";

  protected static final boolean PRINT_STACK_TRACE = true;
  protected static final boolean PRINT_NO_STACK_TRACE = false;

  protected static String makeConnectionString(String host, int port, String dbName, String username, String password) {
    Object[] logObjects = {host, port, dbName, username, password};
    logger.debug("called with:  {host = {}} {port = {}} {dbName = {}} {username = {} {password = {}}", logObjects);
    final StringBuilder builder = new StringBuilder(128);
    builder.append(MYSQL_PROTOCOL).append(host).append(":").append(port).append("/");
    builder.append(dbName).append("?").append("user=").append(username).append("&");
    builder.append("password=").append(password);
    return builder.toString();
  }

  protected static void logSQLExceptionDetails(SQLException exception) {
    logSQLExceptionDetails(exception, PRINT_NO_STACK_TRACE);
  }


  protected static void logSQLExceptionDetails(SQLException exception, boolean printStackTrace) {
    logger.debug("SQLException: " + exception.getMessage());
    logger.debug("SQLState: " + exception.getSQLState());
    logger.debug("VendorError: " + exception.getErrorCode());
    if (printStackTrace) {
      exception.printStackTrace();
    }
  }

  protected static Connection closeConnection(Connection connection) {
    logger.debug("called with: connection = {}", connection);
    if (connection != null) {
      try {
        connection.close();
      } catch (SQLException e) {
        logSQLExceptionDetails(e);
        logger.debug("ignoreable exception");
      } finally {
        connection = null;
      }
    }
    logger.debug("is returning {}", connection);
    return connection;
  }

  protected static Statement closeStatement(Statement statement) {
    logger.debug("called with: statement = {}", statement);
    if (statement != null) {
      try {
        statement.close();
      } catch (SQLException e) {
        logSQLExceptionDetails(e);
        logger.debug("ignoreable exception");
      } finally {
        statement = null;
      }
    }
    logger.debug("is returning {}", statement);
    return statement;
  }

  protected static ResultSet closeResultSet(ResultSet resultSet) {
    logger.debug("called with: resultSet = {}", resultSet);
    if (resultSet != null) {
      try {
        resultSet.close();
      } catch (SQLException e) {
        logSQLExceptionDetails(e);
        logger.debug("ignoreable exception");
      } finally {
        resultSet = null;
      }
    }
    logger.debug("is returning {}", resultSet);
    return resultSet;
  }

  protected static String quoteString(String string) {
    return "'" + string + "'";
  }
}
