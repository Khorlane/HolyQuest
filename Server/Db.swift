// HolyQuest
// Db.swift
// SQLite database
// Created by Steve Bryant on 06/03/2019.
// Copyright 2019 CodePlain. All rights reserved.

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

  static func GetColTxt(ColNbrInSelect: Int) -> String
  {
    var pTxt : UnsafePointer<UInt8>? = nil
    var Txt  : String                = ""
    var x    : Int32                 = 0

    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    x = Int32(ColNbrInSelect - 1)  // SQLite uses index 0 for 1st column
    pTxt = sqlite3_column_text(pSqlResultSet, x)
    Txt = String(cString: pTxt!)
    return Txt
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

// NextMobNbr
let NextMobNbr_MobNbr   = 1

// NextObjNbr
let NextObjNbr_ObjNbr   = 1

// Obj
let Obj_ObjNbr          = 1
let Obj_ObjectId        = 2

// Object
let Object_ObjectId     = 1
let Object_Desc1        = 2
let Object_Desc2        = 3
let Object_Desc3        = 4
let Object_Weight       = 5
let Object_Cost         = 6
let Object_Type         = 7
let Object_SubType      = 8
let Object_Value        = 9

// Player
let Player_Name         = 1
let Player_Password     = 2
let Player_Admin        = 3
let Player_Afk          = 4
let Player_AllowAssist  = 5
let Player_AllowGroup   = 6
let Player_ArmorClass   = 7
let Player_Born         = 8
let Player_Color        = 9
let Player_Experience   = 10
let Player_GoToArrive   = 11
let Player_GoToDepart   = 12
let Player_HitPoints    = 13
let Player_Hunger       = 14
let Player_Invisible    = 15
let Player_Level        = 16
let Player_MovePoints   = 17
let Player_OneWhack     = 18
let Player_Online       = 19
let Player_Position     = 20
let Player_RoomInfo     = 21
let Player_Sex          = 22
let Player_Silver       = 23
let Player_SkillAxe     = 24
let Player_SkillClub    = 25
let Player_SkillDagger  = 26
let Player_SkillHammer  = 27
let Player_SkillSpear   = 28
let Player_SkillStaff   = 29
let Player_SkillSword   = 30
let Player_Thirst       = 31
let Player_TimePlayed   = 32
let Player_Title        = 33
let Player_WeaponDamage = 34
let Player_WeaponDesc1  = 35
let Player_WeaponType   = 36

// PlayerMob
let PlayerMob_Name      = 1
let PlayerMob_MobNbr    = 2
let PlayerMob_Action    = 3

// PlayerObj
let PlayerObj_Name      = 1
let PlayerObj_ObjNbr    = 2
let PlayerObj_Position  = 3

// PlayerRoom
let PlayerRoom_Name     = 1
let PlayerRoom_RoomNbr  = 2

// Room
let Room_RoomNbr        = 1
let Room_Terrain        = 2
let Room_Type           = 3
let Room_Name           = 4
let Room_Desc           = 5

// RoomExit
let RoomExit_RoomNbr    = 1
let RoomExit_Direction  = 2
let RoomExit_ToRoomNbr  = 3
let RoomExit_Desc       = 4

// RoomList
let RoomList_ListNbr    = 1
let RoomList_RoomNbr    = 2

// RoomMob
let RoomMob_RoomNbr     = 1
let RoomMob_MobNbr      = 2

// RoomObj
let RoomObj_RoomNbr     = 1
let RoomObj_ObjNbr      = 2

// Shop
let Shop_RoomNbr        = 1
let Shop_Name           = 2
let Shop_Desc           = 3

// ShopObject
let ShopObject_RoomNbr  = 1
let ShopObject_ObjectId = 2

// Social
let Social_Name         = 1
let Social_MessageNbr   = 2
let Social_Message      = 3

// Spawn
let Spawn_MobileId      = 1
let Spawn_ListNbr       = 2
let Spawn_Maximum       = 3
let Spawn_Seconds       = 4
let Spawn_Minutes       = 5
let Spawn_Hours         = 6
let Spawn_Days          = 7
let Spawn_Weeks         = 8
let Spawn_Months        = 9
let Spawn_Years         = 10

// Synonym
let Synonym_Name        = 1
let Synonym_Command     = 2
let Synonym_Info        = 3

// Talk
let Talk_TalkId         = 1

// TalkMsg
let TalkMsg_TalkId      = 1
let TalkMsg_MessageNbr  = 2
let TalkMsg_Message     = 3

// ValidName
let ValidName_Name      = 1
let ValidName_Sex       = 2
