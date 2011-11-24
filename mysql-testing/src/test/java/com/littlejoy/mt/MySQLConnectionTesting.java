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

import java.sql.*;

public class MySQLConnectionTesting {

  public static void main(String args[]) {
    Connection connection = null;

    try {
      connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/booking?" +
                                               "user=root&password=wonderstanding");
      Statement statement = null;
      ResultSet resultSet = null;

      try {
        statement = connection.createStatement();


        resultSet = statement.executeQuery("select * from performer");

        if (resultSet != null) {
          while(resultSet.next()) {
            String performer_id = resultSet.getString(1);
            String performer_name = resultSet.getString("name");
            String genre_id = resultSet.getString("genre");
            System.out.println("performer_id = " + performer_id);
            System.out.println("performer_name = " + performer_name);
            System.out.println("genre_id = " + genre_id);
          }
        }
      } catch (SQLException inner) {
        System.out.println("SQLException: " + inner.getMessage());
        System.out.println("SQLState: " + inner.getSQLState());
        System.out.println("VendorError: " + inner.getErrorCode());
      } finally {
        if (resultSet != null) {
          try {
            resultSet.close();
          } catch (SQLException sqlEx) {
            System.out.println("ignoreable expection: " + sqlEx);
          }
          resultSet = null;
        }

        if (statement != null) {
          try {
            statement.close();
          } catch (SQLException sqlEx) {
            System.out.println("ignoreable exception:" + sqlEx);
          }

          statement = null;
        }
      }
      

    } catch (SQLException ex) {
      System.out.println("SQLException: " + ex.getMessage());
      System.out.println("SQLState: " + ex.getSQLState());
      System.out.println("VendorError: " + ex.getErrorCode());
    }
  }
}
