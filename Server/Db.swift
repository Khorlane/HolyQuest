//
//  Db.swift
//  HolyQuest
//
//  Created by Stephen Bryant on 6/3/19.
//  Copyright © 2019 CodePlain. All rights reserved.
//

import Foundation
import SQLite3

class Db
{
  //**********************************************************
  // Db open                                                 *
  //**********************************************************

  static func Open()
  {
    SqlCode = sqlite3_open("/Users/stephenbryant/Projects/HolyQuest/Library/World.db3", &pWorldDb)
    if SqlCode != SQLITE_OK
    {
      print("Open Failed")
      return
    }
    print("Database open worked!")
  }

  //**********************************************************
  // Db close                                                *
  //**********************************************************

  static func Close()
  {
    SqlCode = sqlite3_close(pWorldDb)
    if SqlCode == SQLITE_OK
    {
      print("Database close worked!")
    }
  }

  //**********************************************************
  // Handles insert, update, delete statements               *
  //**********************************************************

  static func DoSqlStmt()
  {
    SqlCode = sqlite3_exec(pWorldDb, SqlStmt, nil, nil, nil)
    if SqlCode == SQLITE_OK
    {
      print("Database select worked!")
    }
    print("Result: ", SqlCode)
  }

  //**********************************************************
  // Open cursor                                             *
  //**********************************************************

  static func OpenCursor()
  {
    SqlStmtLen = Int32(SqlStmt.count)
    SqlCode = sqlite3_prepare(pWorldDb, SqlStmt, SqlStmtLen, &pSqlResultSet, nil)
    if SqlCode != SQLITE_OK
    {
      print("Prepare Failed")
      return
    }
  }

  //**********************************************************
  // Fetch cursor                                            *
  //**********************************************************

  static func FetchCursor() -> Bool
  {
    SqlCode = sqlite3_step(pSqlResultSet)
    if (SqlCode == SQLITE_ROW)
    {
      return true
    }
    else
    {
      return false
    }
  }

  //**********************************************************
  // Close cursor                                            *
  //**********************************************************

  static func CloseCursor()
  {
    SqlCode = sqlite3_finalize(pSqlResultSet)
    if SqlCode != SQLITE_OK
    {
      print("Close Failed")
      return
    }
  }

  /***********************************************************
   * Get a column from a result set - Integer                 *
   ***********************************************************/

  static func GetOneColValInt(ColNbrInSelect: Int32) -> Int
  {
    let x = ColNbrInSelect - 1  // SQLite uses index 0 for 1st column
    let Value = Int(sqlite3_column_int(pSqlResultSet, x))
    return Value
  }

  /***********************************************************
   * Get a column from a result set - String                  *
   ***********************************************************/

  static func GetOneColValStr(ColNbrInSelect: Int32) -> String
  {
    let x = ColNbrInSelect - 1  // SQLite uses index 0 for 1st column
    let pTmpStr = sqlite3_column_text(pSqlResultSet, x)
    let TmpStr = String(cString: pTmpStr!)
    return TmpStr
  }
}
