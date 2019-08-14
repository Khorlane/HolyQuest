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
    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    SqlCode = sqlite3_open("/Users/stephenbryant/Projects/HolyQuest/Library/World.db3", &pWorldDb)
    if SqlCode != SQLITE_OK
    {
      LogIt(LogMsg: "ERROR Database Open Failed", LogLvl: 0)
      exit(EXIT_FAILURE)
    }
    LogIt(LogMsg: "INFOx Database open worked!", LogLvl: 0)
  }

  //**********************************************************
  // Db close                                                *
  //**********************************************************

  static func Close()
  {
    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    SqlCode = sqlite3_close(pWorldDb)
    if SqlCode != SQLITE_OK
    {
      LogIt(LogMsg: "ERROR Database Open Failed", LogLvl: 0)
      exit(EXIT_FAILURE)
    }
    LogIt(LogMsg: "INFOx Database close worked!", LogLvl: 0)
  }

  //**********************************************************
  // Handles insert, update, delete statements               *
  //**********************************************************

  static func DoSqlStmt()
  {
    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    SqlCode = sqlite3_exec(pWorldDb, SqlStmt, nil, nil, nil)
    if SqlCode != SQLITE_OK
    {
      LogIt(LogMsg: "ERROR Database exec SQL failed", LogLvl: 0)
      exit(EXIT_FAILURE)
    }
  }

  //**********************************************************
  // Open cursor                                             *
  //**********************************************************

  static func OpenCursor()
  {
    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    SqlStmtLen = Int32(SqlStmt.count)
    SqlCode = sqlite3_prepare(pWorldDb, SqlStmt, SqlStmtLen, &pSqlResultSet, nil)
    if SqlCode != SQLITE_OK
    {
      LogIt(LogMsg: "ERROR Database prepare SQL failed", LogLvl: 0)
      exit(EXIT_FAILURE)
    }
  }

  //**********************************************************
  // Fetch cursor                                            *
  //**********************************************************

  static func FetchCursor() -> Bool
  {
    LogIt(LogMsg: "DEBUG", LogLvl: 5)
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
    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    SqlCode = sqlite3_finalize(pSqlResultSet)
    if SqlCode != SQLITE_OK
    {
      LogIt(LogMsg: "ERROR Database finalize SQL failed", LogLvl: 0)
      exit(EXIT_FAILURE)
    }
  }

  /***********************************************************
   * Get a column from a result set - Integer                 *
   ***********************************************************/

  static func GetColInt(ColNbrInSelect: Int32) -> Int
  {
    var x     : Int32 = 0
    var Value : Int   = 0

    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    x = ColNbrInSelect - 1  // SQLite uses index 0 for 1st column
    Value = Int(sqlite3_column_int(pSqlResultSet, x))
    return Value
  }

  /***********************************************************
   * Get a column from a result set - String                  *
   ***********************************************************/

  static func GetColStr(ColNbrInSelect: Int32) -> String
  {
    var pStr : UnsafePointer<UInt8>? = nil
    var Str  : String                = ""
    var x    : Int32                 = 0

    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    x = ColNbrInSelect - 1  // SQLite uses index 0 for 1st column
    pStr = sqlite3_column_text(pSqlResultSet, x)
    Str = String(cString: pStr!)
    return Str
  }
}
