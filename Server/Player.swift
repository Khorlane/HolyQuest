// HolyQuest
// Player.swift
// Player class
// Created by Steve Bryant on 12/31/2018.
// Copyright 2021 CodePlain. All rights reserved.

import Foundation   // Not required at this time

class Player
{
  // Player variables
  var Output        : String
  var PosNbr        : Int
  var RoomNbr       : Int
  var SocketHandle  : Int32
  var SocketAddr    : String
  var State         = States.GetName
  // Player file variables
  var Name          : String
  var Password      : String
  var Admin         : String
  var Afk           : String
  var AllowAssist   : String
  var AllowGroup    : String
  var ArmorClass    : Int
  var Born          : Int
  var Color         : String
  var Experience    : Int
  var GoToArrive    : String
  var GoToDepart    : String
  var HitPoints     : Int
  var Hunger        : Int
  var Invisible     : String
  var Level         : Int
  var MovePoints    : Int
  var OneWhack      : String
  var Online        : String
  var Position      : String
  var RoomInfo      : String
  var Sex           : String
  var Silver        : Int
  var SkillAxe      : Int
  var SkillClub     : Int
  var SkillDagger   : Int
  var SkillHammer   : Int
  var SkillSpear    : Int
  var SkillStaff    : Int
  var SkillSword    : Int
  var Thirst        : Int
  var TimePlayed    : Int
  var Title         : String
  var WeaponDamage  : Int
  var WeaponDesc1   : String
  var WeaponType    : String
  
  enum States
  {
    case Connected
    case GetName
    case GetPassword
    case SendGreeting
    case Playing
    case Disconnect
  }

  //*********************************
  //* One-time per player functions *
  //*********************************

  // Initialize a new player                  // BigDog.swift NewPlayer()
  init(Name: String, SocketAddr: String, SocketHandle: Int32)
  {
    LogIt("DEBUG", 5)
    // Initialize variables
    self.Output       = ""
    self.PosNbr       = 0
    self.RoomNbr      = START_ROOM
    self.SocketAddr   = SocketAddr
    self.SocketHandle = SocketHandle
    self.State        = States.Connected
    // Initialize file variables
    self.Name         = Name
    self.Password     = ""
    self.Admin        = ""
    self.Afk          = ""
    self.AllowAssist  = ""
    self.AllowGroup   = ""
    self.ArmorClass   = 0
    self.Born         = 0
    self.Color        = ""
    self.Experience   = 0
    self.GoToArrive   = ""
    self.GoToDepart   = ""
    self.HitPoints    = 0
    self.Hunger       = 0
    self.Invisible    = ""
    self.Level        = 0
    self.MovePoints   = 0
    self.OneWhack     = ""
    self.Online       = ""
    self.Position     = ""
    self.RoomInfo     = ""
    self.Sex          = ""
    self.Silver       = 0
    self.SkillAxe     = 0
    self.SkillClub    = 0
    self.SkillDagger  = 0
    self.SkillHammer  = 0
    self.SkillSpear   = 0
    self.SkillStaff   = 0
    self.SkillSword   = 0
    self.Thirst       = 0
    self.TimePlayed   = 0
    self.Title        = ""
    self.WeaponDamage = 0
    self.WeaponDesc1  = ""
    self.WeaponType   = ""
  }

  // Get player
  func LookUp() -> Bool                       // Command.swift
  {
    LogIt("DEBUG", 5)
    SqlStmt = """
      Select
        Name,
        Password,
        Admin,
        Afk,
        AllowAssist,
        AllowGroup,
        ArmorClass,
        Born,
        Color,
        Experience,
        GoToArrive,
        GoToDepart,
        HitPoints,
        Hunger,
        Invisible,
        Level,
        MovePoints,
        OneWhack,
        Online,
        Position,
        RoomInfo,
        Sex,
        Silver,
        SkillAxe,
        SkillClub,
        SkillDagger,
        SkillHammer,
        SkillSpear,
        SkillStaff,
        SkillSword,
        Thirst,
        TimePlayed,
        Title,
        WeaponDamage,
        WeaponDesc1,
        WeaponType
      From Player
      Where Name = '$1'
    """
    SqlStmt.Squeeze()
    SqlStmt.Replace("$1", tbPlayer.Name)
    Db.OpenCursor()
    Found = Db.FetchCursor()
    ColNbr = 0
    if !Found
    {
      Db.CloseCursor()
      return false
    }
    ColNbr = 0
    pPlayer.Name         = Db.GetColTxt()
    pPlayer.Password     = Db.GetColTxt()
    pPlayer.Admin        = Db.GetColTxt()
    pPlayer.Afk          = Db.GetColTxt()
    pPlayer.AllowAssist  = Db.GetColTxt()
    pPlayer.AllowGroup   = Db.GetColTxt()
    pPlayer.ArmorClass   = Db.GetColInt()
    pPlayer.Born         = Db.GetColInt()
    pPlayer.Color        = Db.GetColTxt()
    pPlayer.Experience   = Db.GetColInt()
    pPlayer.GoToArrive   = Db.GetColTxt()
    pPlayer.GoToDepart   = Db.GetColTxt()
    pPlayer.HitPoints    = Db.GetColInt()
    pPlayer.Hunger       = Db.GetColInt()
    pPlayer.Invisible    = Db.GetColTxt()
    pPlayer.Level        = Db.GetColInt()
    pPlayer.MovePoints   = Db.GetColInt()
    pPlayer.OneWhack     = Db.GetColTxt()
    pPlayer.Online       = Db.GetColTxt()
    pPlayer.Position     = Db.GetColTxt()
    pPlayer.RoomInfo     = Db.GetColTxt()
    pPlayer.Sex          = Db.GetColTxt()
    pPlayer.Silver       = Db.GetColInt()
    pPlayer.SkillAxe     = Db.GetColInt()
    pPlayer.SkillClub    = Db.GetColInt()
    pPlayer.SkillDagger  = Db.GetColInt()
    pPlayer.SkillHammer  = Db.GetColInt()
    pPlayer.SkillSpear   = Db.GetColInt()
    pPlayer.SkillStaff   = Db.GetColInt()
    pPlayer.SkillSword   = Db.GetColInt()
    pPlayer.Thirst       = Db.GetColInt()
    pPlayer.TimePlayed   = Db.GetColInt()
    pPlayer.Title        = Db.GetColTxt()
    pPlayer.WeaponDamage = Db.GetColInt()
    pPlayer.WeaponDesc1  = Db.GetColTxt()
    pPlayer.WeaponType   = Db.GetColTxt()
    Db.CloseCursor()
    return true
  }

  // Insert new player into set of players
  static func SetInsert()                     // BigDog.swift PlayerNew()
  {
    LogIt("DEBUG", 5)
    (SetInsertOk, pInsert) = PlayerSet.insert(pPlayer)
    if SetInsertOk == false
    {
      LogIt("ERROR PlayerSetInsert failed - AddOk is false", 0)
      exit(EXIT_FAILURE)
    }
    if pPlayer != pInsert
    {
      LogIt("ERROR PlayerSetInsert failed - pPlayer != pInsert", 0)
      exit(EXIT_FAILURE)
    }
  }

  // Remove leaving player from set of players
  static func SetRemove()                     // Command.swift DoQuit()
  {
    LogIt("DEBUG", 5)
    pRemove = PlayerSet.remove(pPlayer)
    if pRemove == nil
    {
      LogIt("ERROR PlayerSetRemove failed - nil pointer", 0)
      exit(EXIT_FAILURE)
    }
    if pRemove != pPlayer
    {
      LogIt("ERROR PlayerSetRemove failed - pRemove != pPlayer", 0)
      exit(EXIT_FAILURE)
    }
  }

  // Send greeting to new player
  static func Greeting()                      // Player.swift PlayerNew()
  {
    LogIt("DEBUG", 5)
    GreetingPath     = HOME_DIR + "/" + GREETING_DIR + "/"
    GreetingFileName = GREETING_FILE_NAME
    GreetingFile     = GreetingPath + GreetingFileName

    // Read the contents of the specified file
    Contents = try! String(contentsOfFile: GreetingFile)

    // Split the file into separate lines
    Lines = Contents.split(separator: "\r\n", omittingEmptySubsequences: false)
    // Iterate over each line, sending each to the player
    for line in Lines
    {
      pPlayer.Output += line
      pPlayer.Output += "\r\n"
    }
  }

  //**********************
  //* Gameplay functions *
  //**********************

  static func CalcLevelExperience(_ Level : Int) -> Float
  {
    BaseExp  = CalcLevelExperienceBase(Level)
    AddExp   = CalcLevelExperienceAdd(Level, BaseExp)
    TotalExp = BaseExp + AddExp
    return TotalExp
  }

  static func CalcLevelExperienceAdd(_ Level: Int, _ BaseExp: Float) -> Float
  {
    var LogLevel: Double
    var AddExp  : Float

    LogLevel = log10(Double(Level)+20.0)
    AddExp   = Float(pow(Double(BaseExp),Double(LogLevel)) * Double(Double(Level)/10000.0))
    return AddExp
  }

  static func CalcLevelExperienceBase(_ Level: Int) -> Float
  {
    if Level < 2 {return 0}
    return Float((Level * 1000)) + CalcLevelExperienceBase(Level-1)
  }

  // Look up target player in player set
  static func TargetLookUp()                  // Command.swift
  {
    LogIt("DEBUG", 5)
    pTarget = nil
    for p1 in PlayerSet
    {
      TmpStr1 = p1.Name
      TmpStr2 = PlayerTargetName
      TmpStr1.Lower()
      TmpStr2.Lower()
      if TmpStr1 == TmpStr2
      {
        pTarget = p1
        break
      }
    }
  }

  // Update player in db
  static func Update(_ p1: Player = pPlayer)
  {
    LogIt("DEBUG", 5)
    SqlStmt = """
      Update Player
        Set $1
      Where Name = '$2'
    """
    SqlStmt.Squeeze()
    SqlStmt.Replace("$1", SqlSetPart)
    SqlStmt.Replace("$2", p1.Name)
    Db.DoSqlStmt()
  }
}

// Required in order to have a 'set of players'
extension Player: Hashable
{
  static func == (lhs: Player, rhs: Player) -> Bool
  {
    return lhs.SocketHandle == rhs.SocketHandle
  }
  func hash(into hasher: inout Hasher)
  {
    hasher.combine(SocketHandle)
  }
}
