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

  //**********************************************************
  // Get a column from a result set - Integer                *
  //**********************************************************

  static func GetColInt(ColNbrInSelect: Int) -> Int
  {
    var x     : Int32 = 0
    var Value : Int   = 0

    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    x = Int32(ColNbrInSelect - 1)  // SQLite uses index 0 for 1st column
    Value = Int(sqlite3_column_int(pSqlResultSet, x))
    return Value
  }

  //**********************************************************
  // Get a column from a result set - String                 *
  //**********************************************************

  static func GetColStr(ColNbrInSelect: Int) -> String
  {
    var pStr : UnsafePointer<UInt8>? = nil
    var Str  : String                = ""
    var x    : Int32                 = 0

    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    x = Int32(ColNbrInSelect - 1)  // SQLite uses index 0 for 1st column
    pStr = sqlite3_column_text(pSqlResultSet, x)
    Str = String(cString: pStr!)
    return Str
  }
}

//**********************************************************
// Table definitions                                       *
//**********************************************************

// Calendar
let Calendar_Type       = 1
let Calendar_SeqNbr     = 2
let Calendar_Desc       = 3

// Command
let Command_Name        = 1
let Command_Admin       = 2
let Command_Level       = 3
let Command_MinPosition = 4
let Command_Social      = 5
let Command_Fight       = 6
let Command_MinWords    = 7
let Command_Parts       = 8
let Command_Message     = 9

// Explored
let Explored_Name       = 1
let Explored_RoomTrack  = 2

// Loot
let Loot_Loot_Id        = 1

// LootObject
let LootObject_Loot_Id  = 1
let LootObject_ObjectId = 2
let LootObject_Count    = 3
let LootObject_Percent  = 4

// Mob
let Mob_MobNbr          = 1
let Mob_MobileId        = 2
let Mob_HitPoints       = 3

// Mobile
let Mobile_MobileId     = 1
let Mobile_Sex          = 2
let Mobile_Desc1        = 3
let Mobile_Desc2        = 4
let Mobile_Desc3        = 5
let Mobile_Action       = 6
let Mobile_Faction      = 7
let Mobile_Level        = 8
let Mobile_HitPoints    = 9
let Mobile_Armor        = 10
let Mobile_Attack       = 11
let Mobile_Damage       = 12
let Mobile_ExpPoints    = 13
let Mobile_LootId       = 14
let Mobile_TalkId       = 15
let Mobile_InWorld      = 16

// Player
let Player_Name         = 1
let Player_Password     = 2
let Player_ArmorClass   = 3
