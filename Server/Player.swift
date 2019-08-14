// HolyQuest
// Player.swift
// Player class
// Created by Steve Bryant on 12/31/2018.
// Copyright 2019 Steve Bryant. All rights reserved.

import Foundation   // Not required at this time

class Player
{
  // Player variables
  var Output        : String
  var SocketHandle  : Int32
  var SocketAddr    : String
  var State         = States.GetName
  // Player file variables
  var Name          : String
  var Password      : String
  var Admin         : Bool
  var Afk           : Bool
  var ArmorClass    : Int
  var RoomNbr       : Int

  enum States
  {
    case GetName
    case GetPassword
    case SendGreeting
    case Playing
  }

  init(Name: String, SocketAddr: String, SocketHandle: Int32)
  {
    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    // Initialize variables
    self.Output       = ""
    self.SocketAddr   = SocketAddr
    self.SocketHandle = SocketHandle
    self.State        = States.GetName
    // Initialize file variables
    self.Name         = ""
    self.Password     = ""
    self.Admin        = false
    self.Afk          = false
    self.ArmorClass   = 0
    self.RoomNbr      = START_ROOM
  }

  func IsValidName() -> Bool
  {
    LogIt(LogMsg: "DEBUG", LogLvl: 5)
    SqlStmt = """
      Select
        Name,
        Password,
        ArmorClass
      From Player
      Where Name = '$1'
    """
    SqlStmt.Squeeze()
    SqlStmt = SqlStmt.replacingOccurrences(of: "$1", with: pPlayer.Name)
    Db.OpenCursor()
    Found = Db.FetchCursor()
    if Found
    {
      pPlayer.Password   = Db.GetColStr(ColNbrInSelect: 2)
      pPlayer.ArmorClass = Db.GetColInt(ColNbrInSelect: 3)
      Db.CloseCursor()
      return true
    }
    else
    {
      Db.CloseCursor()
      return false
    }
  }
}

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

func PlayerAdd()
{
  LogIt(LogMsg: "DEBUG", LogLvl: 5)
  pPlayer = Player.init(Name: "*", SocketAddr: SocketAddr, SocketHandle: SocketHandle1)
  LogonGreeting()
  pPlayer.Output += "Name?"
  pPlayer.Output += "\r\n"
  pPlayer.Output += "> "
  PlayerSetInsert()
}

func PlayerDel()
{
  LogIt(LogMsg: "DEBUG", LogLvl: 5)
  PlayerSetRemove()
}

func PlayerSetTargetLookUp()
{
  LogIt(LogMsg: "DEBUG", LogLvl: 5)
  pTarget = nil
  for p1 in PlayerSet
  {
    if p1.Name == PlayerTargetName
    {
      pTarget = p1
      break
    }
  }
}

func PlayerSetInsert()
{
  LogIt(LogMsg: "DEBUG", LogLvl: 5)
  let Good = PlayerSet.insert(pPlayer)
  if Good.inserted == false
  {
    LogIt(LogMsg: "ERROR PlayerSetInsert failed", LogLvl: 0)
    exit(EXIT_FAILURE)
  }
}

func PlayerSetRemove()
{
  LogIt(LogMsg: "DEBUG", LogLvl: 5)
  let Good = PlayerSet.remove(pPlayer)
  if Good == nil
  {
    LogIt(LogMsg: "ERROR PlayerSetRemove failed", LogLvl: 0)
    exit(EXIT_FAILURE)
  }
}

func LogonGreeting()
{
  LogIt(LogMsg: "DEBUG", LogLvl: 5)
  let GreetingPath     = HOME_DIR + "/" + GREETING_DIR + "/"
  let GreetingFileName = GREETING_FILE_NAME
  let GreetingFile   = GreetingPath + GreetingFileName

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
