// HolyQuest
// Player.swift
// Player class
// Created by Steve Bryant on 12/31/2018.
// Copyright 2019 CodePlain. All rights reserved.

import Foundation   // Not required at this time

class Player
{
  // Player variables
  var Output        : String
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
    self.RoomNbr      = START_ROOM
    self.SocketAddr   = SocketAddr
    self.SocketHandle = SocketHandle
    self.State        = States.GetName
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
    SqlStmt.Replace("$1", PlayerName)
    Db.OpenCursor()
    Found = Db.FetchCursor()
    if Found
    {
      pPlayer.Name         = Db.GetColTxt(ColNbrInSelect: Player_Name)
      pPlayer.Password     = Db.GetColTxt(ColNbrInSelect: Player_Password)
      pPlayer.Admin        = Db.GetColTxt(ColNbrInSelect: Player_Admin)
      pPlayer.Afk          = Db.GetColTxt(ColNbrInSelect: Player_Afk)
      pPlayer.AllowAssist  = Db.GetColTxt(ColNbrInSelect: Player_AllowAssist)
      pPlayer.AllowGroup   = Db.GetColTxt(ColNbrInSelect: Player_AllowGroup)
      pPlayer.ArmorClass   = Db.GetColInt(ColNbrInSelect: Player_ArmorClass)
      pPlayer.Born         = Db.GetColInt(ColNbrInSelect: Player_Born)
      pPlayer.Color        = Db.GetColTxt(ColNbrInSelect: Player_Color)
      pPlayer.Experience   = Db.GetColInt(ColNbrInSelect: Player_Experience)
      pPlayer.GoToArrive   = Db.GetColTxt(ColNbrInSelect: Player_GoToArrive)
      pPlayer.GoToDepart   = Db.GetColTxt(ColNbrInSelect: Player_GoToDepart)
      pPlayer.HitPoints    = Db.GetColInt(ColNbrInSelect: Player_HitPoints)
      pPlayer.Hunger       = Db.GetColInt(ColNbrInSelect: Player_Hunger)
      pPlayer.Invisible    = Db.GetColTxt(ColNbrInSelect: Player_Invisible)
      pPlayer.Level        = Db.GetColInt(ColNbrInSelect: Player_Level)
      pPlayer.MovePoints   = Db.GetColInt(ColNbrInSelect: Player_MovePoints)
      pPlayer.OneWhack     = Db.GetColTxt(ColNbrInSelect: Player_OneWhack)
      pPlayer.Online       = Db.GetColTxt(ColNbrInSelect: Player_Online)
      pPlayer.Position     = Db.GetColTxt(ColNbrInSelect: Player_Position)
      pPlayer.RoomInfo     = Db.GetColTxt(ColNbrInSelect: Player_RoomInfo)
      pPlayer.Sex          = Db.GetColTxt(ColNbrInSelect: Player_Sex)
      pPlayer.Silver       = Db.GetColInt(ColNbrInSelect: Player_Silver)
      pPlayer.SkillAxe     = Db.GetColInt(ColNbrInSelect: Player_SkillAxe)
      pPlayer.SkillClub    = Db.GetColInt(ColNbrInSelect: Player_SkillClub)
      pPlayer.SkillDagger  = Db.GetColInt(ColNbrInSelect: Player_SkillDagger)
      pPlayer.SkillHammer  = Db.GetColInt(ColNbrInSelect: Player_SkillHammer)
      pPlayer.SkillSpear   = Db.GetColInt(ColNbrInSelect: Player_SkillSpear)
      pPlayer.SkillStaff   = Db.GetColInt(ColNbrInSelect: Player_SkillStaff)
      pPlayer.SkillSword   = Db.GetColInt(ColNbrInSelect: Player_SkillSword)
      pPlayer.Thirst       = Db.GetColInt(ColNbrInSelect: Player_Thirst)
      pPlayer.TimePlayed   = Db.GetColInt(ColNbrInSelect: Player_TimePlayed)
      pPlayer.Title        = Db.GetColTxt(ColNbrInSelect: Player_Title)
      pPlayer.WeaponDamage = Db.GetColInt(ColNbrInSelect: Player_WeaponDamage)
      pPlayer.WeaponDesc1  = Db.GetColTxt(ColNbrInSelect: Player_WeaponDesc1)
      pPlayer.WeaponType   = Db.GetColTxt(ColNbrInSelect: Player_WeaponType)
      Db.CloseCursor()
      return true
    }
    else
    {
      Db.CloseCursor()                        // Db.swift
      return false
    }
  }

  // Insert new player into set of players
  static func SetInsert()                     // BigDog.swift PlayerNew()
  {
    LogIt("DEBUG", 5)
    let Good = PlayerSet.insert(pPlayer)
    if Good.inserted == false
    {
      LogIt("ERROR PlayerSetInsert failed", 0)
      exit(EXIT_FAILURE)
    }
  }

  // Remove leaving player from set of players
  static func SetRemove()                     // Command.swift DoQuit()
  {
    LogIt("DEBUG", 5)
    let Good = PlayerSet.remove(pPlayer)
    if Good == nil
    {
      LogIt("ERROR PlayerSetRemove failed", 0)
      exit(EXIT_FAILURE)
    }
  }

  // Send greeting to new player
  static func Greeting()                      // Player.swift PlayerNew()
  {
    LogIt("DEBUG", 5)
    let GreetingPath     = HOME_DIR + "/" + GREETING_DIR + "/"
    let GreetingFileName = GREETING_FILE_NAME
    let GreetingFile     = GreetingPath + GreetingFileName

    // Read the contents of the specified file
    let contents = try! String(contentsOfFile: GreetingFile)

    // Split the file into separate lines
    let lines = contents.split(separator:"\n")

    // Iterate over each line and print the line
    for line in lines {
      pPlayer.Output += line
    }
    pPlayer.Output += "\r\n"
  }

  //**********************
  //* Gameplay functions *
  //**********************

  static func CalcLevelExperience(_ Level : Int) -> Float
  {
    let BaseExp  = CalcLevelExperienceBase(Level)
    let AddExp   = CalcLevelExperienceAdd(Level, BaseExp)
    let TotalExp = BaseExp + AddExp
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

  // Lookup target player in player set
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
