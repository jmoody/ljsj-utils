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
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

import static com.littlejoy.mt.DriverHelper.*;

public class ClearTables {

  /**
   * a logger for this class
   */
  @SuppressWarnings("unused")
  private final static Logger logger = LoggerFactory.getLogger(ClearTables.class);

  private static Connection connection;

  protected static void clearTables() {

    String connectionUrl = makeConnectionString(MYSQL_HOST,
                                                MYSQL_PORT,
                                                BOOKING_DATABASE,
                                                MYSQL_USER,
                                                MYSQL_PASS);
    try {
      connection = DriverManager.getConnection(connectionUrl);
      clearTableWithConnection(BOOKING_DATABASE, PERFORMANCES_TABLE, connection);
      clearTableWithConnection(BOOKING_DATABASE, PERFORMER_TABLE, connection);
      clearTableWithConnection(BOOKING_DATABASE, VENUE_TABLE, connection);
      clearTableWithConnection(BOOKING_DATABASE, ADDRESS_TABLE, connection);
      clearTableWithConnection(BOOKING_DATABASE, GENRE_TABLE, connection);
    } catch (SQLException e) {
      logSQLExceptionDetails(e, PRINT_NO_STACK_TRACE);
      // must do some handling here
    } finally {
      DriverHelper.closeConnection(connection);
    }
  }

  protected static boolean clearTableWithConnection(String dbName, String table, Connection connection) {
    logger.debug("called with:  {dbName = {}} {table = {}}", dbName, table);
    Statement statement = null;
    String query = makeDeleteQuery(dbName, table);
    boolean success;
    try {
      statement = connection.createStatement();
      statement.execute(query);
      success = true;
    } catch (SQLException e) {
      logSQLExceptionDetails(e);
      success = false;
    } finally {
      DriverHelper.closeStatement(statement);
    }
    logger.debug("is returning {}", success);
    return success;
  }

  protected static String makeDeleteQuery(String dbName, String table) {
    logger.debug("called with:  {dbName = {}} {table = {}}", dbName, table);
    final StringBuilder builder = new StringBuilder(128);
    builder.append("delete from ").append(dbName).append(".").append(table);
    return builder.toString();
  }
}
