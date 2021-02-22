// HolyQuest
// Db.swift
// SQLite database
// Created by Steve Bryant on 06/03/2019.
// Copyright 2021 CodePlain. All rights reserved.

import Foundation
import SQLite3

class Db
{
  // Open database
  static func Open()                          // BigDog.swift StartItUp()
  {
    LogIt("DEBUG", 5)
    WorldPath     = HOME_DIR + "/" + WORLD_DIR + "/"
    WorldFileName = WORLD_FILE_NAME
    WorldFile     = WorldPath + WorldFileName
    SqlCode       = sqlite3_open(WorldFile, &pWorldDb)
    if SqlCode != SQLITE_OK
    {
      LogIt("ERROR Database Open Failed", 0)
      exit(EXIT_FAILURE)
    }
    LogIt("INFOx Database open worked!", 0)
  }

  // Close database
  static func Close()                         // BigDog.swift ShutItDown()
  {
    LogIt("DEBUG", 5)
    SqlCode = sqlite3_close(pWorldDb)
    if SqlCode != SQLITE_OK
    {
      LogIt("ERROR Database Open Failed", 0)
      exit(EXIT_FAILURE)
    }
    LogIt("INFOx Database close worked!", 0)
  }

  // Execute insert, update, delete SQL statements
  static func DoSqlStmt()                     // No callers, yet
  {
    LogIt("DEBUG", 5)
    SqlCode = sqlite3_exec(pWorldDb, SqlStmt, nil, nil, nil)
    if SqlCode != SQLITE_OK
    {
      LogIt("ERROR Database exec SQL failed", 0)
      exit(EXIT_FAILURE)
    }
  }

  // Open a cursor
  static func OpenCursor()
  {
    LogIt("DEBUG", 5)
    SqlStmtLen = Int32(SqlStmt.count)
    SqlCode    = sqlite3_prepare(pWorldDb, SqlStmt, SqlStmtLen, &pSqlResultSet, nil)
    if SqlCode != SQLITE_OK
    {
      LogIt("ERROR Database prepare SQL failed", 0)
      exit(EXIT_FAILURE)
    }
  }

  // Fetch a row
  static func FetchCursor() -> Bool
  {
    LogIt("DEBUG", 5)
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

  // Close cursor
  static func CloseCursor()
  {
    LogIt("DEBUG", 5)
    SqlCode = sqlite3_finalize(pSqlResultSet)
    if SqlCode != SQLITE_OK
    {
      LogIt("ERROR Database finalize SQL failed", 0)
      exit(EXIT_FAILURE)
    }
  }

  // Get an integer column
  static func GetColInt() -> Int
  {
    LogIt("DEBUG", 5)
    ColInt = Int(sqlite3_column_int(pSqlResultSet, ColNbr))
    ColNbr += 1
    return ColInt
  }

  // Get a text column
  static func GetColTxt() -> String
  {
    LogIt("DEBUG", 5)
    pColTxt = sqlite3_column_text(pSqlResultSet, ColNbr)
    ColTxt = String(cString: pColTxt!)
    ColNbr += 1
    return ColTxt
  }
}

// Calendar
struct stbCalendar
{
  var `Type`            : String = ""
  var `SeqNbr`          : Int    = 0
  var `Desc`            : String = ""
}
var tbCalendar = stbCalendar()

// Command
struct stbCommand
{
  var `Name`            : String = ""
  var `Admin`           : String = ""
  var `Level`           : Int    = 0
  var `MinPosition`     : String = ""
  var `Social`          : String = ""
  var `Fight`           : String = ""
  var `MinWords`        : Int    = 0
  var `Parts`           : Int    = 0
  var `Message`         : String = ""
}
var tbCommand = stbCommand()

// Explored
struct stbExplored
{
  var `Name`            : String = ""
  var `RoomTrack`       : String = ""
}
var tbExplored = stbExplored()

// Loot
struct stbLoot
{
  var `LootId`          : String = ""
}
var tbLoot = stbLoot()

// LootObject
struct stbLootObject
{
  var `LootId`          : String = ""
  var `ObjectId`        : String = ""
  var `Count`           : Int    = 0
  var `Percent`         : Int    = 0
}
var tbLootObject = stbLootObject()

// Mob
struct stbMob
{
  var `MobNbr`          : Int    = 0
  var `MobileId`        : String = ""
  var `HitPoints`       : Int    = 0
}
var tbMob = stbMob()

// Mobile
struct stbMobile
{
  var `MobileId`        : String = ""
  var `Sex`             : String = ""
  var `Desc1`           : String = ""
  var `Desc2`           : String = ""
  var `Desc3`           : String = ""
  var `Action`          : String = ""
  var `Faction`         : String = ""
  var `Level`           : Int    = 0
  var `HitPoints`       : Int    = 0
  var `Armor`           : Int    = 0
  var `Attack`          : String = ""
  var `Damage`          : Int    = 0
  var `ExpPoints`       : Int    = 0
  var `LootId`          : String = ""
  var `TalkId`          : String = ""
  var `InWorld`         : Int    = 0
}
var tbMobile = stbMobile()

// NextMobNbr
struct stbNextMobNbr
{
  var `MobNbr`          : Int    = 0
}
var tbNextMobNbr = stbNextMobNbr()

// NextObjNbr
struct stbNextObjNbr
{
  var `ObjNbr`          : Int    = 0
}
var tbNextObjNbr = stbNextObjNbr()

// Obj
struct stbObj
{
  var `ObjNbr`          : Int    = 0
  var `ObjectId`        : String = ""
}
var tbObj = stbObj()

// Object
struct stbObject
{
  var `ObjectId`        : String = ""
  var `Desc1`           : String = ""
  var `Desc2`           : String = ""
  var `Desc3`           : String = ""
  var `Weight`          : Int    = 0
  var `Cost`            : Int    = 0
  var `Type`            : String = ""
  var `SubType`         : String = ""
  var `Value`           : Int    = 0
}
var tbObject = stbObject()

// Player
struct stbPlayer
{
  var `Name`              : String = ""
  var `Password`          : String = ""
  var `Admin`             : String = ""
  var `Afk`               : String = ""
  var `AllowAssist`       : String = ""
  var `AllowGroup`        : String = ""
  var `ArmorClass`        : Int    = 0
  var `Born`              : Int    = 0
  var `Color`             : String = ""
  var `Experience`        : Int    = 0
  var `GoToArrive`        : String = ""
  var `GoToDepart`        : String = ""
  var `HitPoints`         : Int    = 0
  var `Hunger`            : Int    = 0
  var `Invisible`         : String = ""
  var `Level`             : Int    = 0
  var `MovePoints`        : Int    = 0
  var `OneWhack`          : String = ""
  var `Online`            : String = ""
  var `Position`          : String = ""
  var `RoomInfo`          : String = ""
  var `Sex`               : String = ""
  var `Silver`            : Int    = 0
  var `SkillAxe`          : Int    = 0
  var `SkillClub`         : Int    = 0
  var `SkillDagger`       : Int    = 0
  var `SkillHammer`       : Int    = 0
  var `SkillSpear`        : Int    = 0
  var `SkillStaff`        : Int    = 0
  var `SkillSword`        : Int    = 0
  var `Thirst`            : Int    = 0
  var `TimePlayed`        : Int    = 0
  var `Title`             : String = ""
  var `WeaponDamage`      : Int    = 0
  var `WeaponDesc1`       : String = ""
  var `WeaponType`        : String = ""
}
var tbPlayer = stbPlayer()

// PlayerMob
struct stbPlayerMob
{
  var `Name`              : String = ""
  var `MobNbr`            : Int    = 0
  var `Action`            : String = ""
}
var tbPlayerMob = stbPlayerMob()

// PlayerObj
struct stbPlayerObj
{
  var `Name`              : String = ""
  var `ObjNbr`            : Int    = 0
  var `Position`          : String = ""
}
var tbPlayerObj = stbPlayerObj()

// PlayerRoom
struct stbPlayerRoom
{
  var Name                : String = ""
  var RoomNbr             : Int    = 0
}
var tbPlayerRoom = stbPlayerRoom()

// Room
struct stbRoom
{
  var `RoomNbr`           : Int    = 0
  var `Terrain`           : String = ""
  var `Type`              : String = ""
  var `Name`              : String = ""
  var `Desc`              : String = ""
}
var tbRoom = stbRoom()

// RoomExit
struct stbRoomExit
{
  var `RoomNbr`           : Int    = 0
  var `Direction`         : Int    = 0
  var `ToRoomNbr`         : Int    = 0
  var `Desc`              : String = ""
}
var tbRoomExit = stbRoomExit()

// RoomList
struct stbRoomList
{
  var `ListNbr`           : Int    = 0
  var `RoomNbr`           : Int    = 0
}
var tbRoomList = stbRoomList()

// RoomMob
struct stbRoomMob
{
  var `RoomNbr`           : Int    = 0
  var `MobNbr`            : Int    = 0
}
var tbRoomMob = stbRoomMob()

// RoomObj
struct stbRoomObj
{
  var `RoomNbr`           : Int    = 0
  var `ObjNbr`            : Int    = 0
}
var tbRoomObj = stbRoomObj()

// Shop
struct stbShop
{
  var `RoomNbr`           : Int    = 0
  var `Name`              : String = ""
  var `Desc`              : String = ""
}
var tbShop = stbShop()

// ShopObject
struct stbShopObject
{
  var `RoomNbr`           : Int    = 0
  var `ObjectId`          : String = ""
}
var tbShopObject = stbShopObject()

// Social
struct stbSocial
{
  var `Name`              : String = ""
  var `MessageNbr`        : Int    = 0
  var `Message`           : String = ""
}
var tbSocial = stbSocial()

// Spawn
struct stbSpawn
{
  var `MobileId`          : String = ""
  var `ListNbr`           : Int    = 0
  var `Maximum`           : Int    = 0
  var `Seconds`           : Int    = 0
  var `Minutes`           : Int    = 0
  var `Hours`             : Int    = 0
  var `Days`              : Int    = 0
  var `Weeks`             : Int    = 0
  var `Months`            : Int    = 0
  var `Years`             : Int    = 0
}
var tbSpawn = stbSpawn()

// Synonym
struct stbSynonym
{
  var `Name`              : String = ""
  var `Command`           : String = ""
  var `Info`              : String = ""
}
var tbSynonym = stbSynonym()

// Talk
struct stbTalk
{
  var `TalkId`            : String = ""
}
var tbTalk = stbTalk()

// TalkMsg
struct stbTalkMsg
{
  var `TalkId`            : String = ""
  var `MessageNbr`        : Int    = 0
  var `Message`           : String = ""
}
var tbTalkMsg = stbTalkMsg()

// ValidName
struct stbValidName
{
  var `Name`              : String = ""
  var `Sex`               : String = ""
}
var tbValidName = stbValidName()
