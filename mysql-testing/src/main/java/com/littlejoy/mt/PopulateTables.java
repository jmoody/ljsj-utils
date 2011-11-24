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
import java.util.UUID;

import static com.littlejoy.mt.DriverHelper.*;

public class PopulateTables {

  /**
   * a logger for this class
   */
  @SuppressWarnings("unused")
  private final static Logger logger = LoggerFactory.getLogger(PopulateTables.class);

  private Variates variates;

  private Connection connection;

  private BookingData bookingData;

  public PopulateTables(Variates variates, Connection connection, BookingData bookingData) {
    this.variates = variates;
    this.connection = connection;
    this.bookingData = bookingData;
  }

  protected String makeGenreRow(UUID uuid, String name) {
    final StringBuilder builder = new StringBuilder(128);
    builder.append("insert into booking.genre (genre_id, name) values ");
    builder.append("(").append(quoteString(uuid.toString())).append(",");
    builder.append(quoteString(name)).append(")");
    return builder.toString();
  }
  protected void populateGenre() {
    Statement statement = null;
    try {
      statement = this.connection.createStatement();

      statement.execute(this.makeGenreRow(UUID.randomUUID(), bookingData.solo));
      statement.execute(this.makeGenreRow(UUID.randomUUID(), bookingData.band));
      statement.execute(this.makeGenreRow(UUID.randomUUID(), bookingData.monologist));
      statement.execute(this.makeGenreRow(UUID.randomUUID(), bookingData.standup));

    } catch (SQLException e) {
      logSQLExceptionDetails(e);
    } finally {
      closeStatement(statement);
    }
  }
}
