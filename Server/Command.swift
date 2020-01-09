// HolyQuest
// Command.swift
// Process commands
// Created by Steve Bryant on 12/25/2018.
// Copyright 2019 CodePlain. All rights reserved.

import Foundation   // Not required at this time

// Process commands
func ProcessCommand()                         // BigDog.swift
{
  LogIt("DEBUG", 5)
  Command.Strip()
  LogIt(Command, 1)
  CommandWordCount = Command.Words
  if CommandWordCount == 0
  {
    Prompt()
    return
  }
  if pPlayer.State == Player.States.Disconnect
  {
    DoQuit()
    return
  }
  if pPlayer.State != Player.States.Playing
  {
    GetPlayerGoing()                          // Command.swift
    return
  }
  if Command == "" {return}
  MudCmd = Command.Word(1)
  MudCmd.Lower()
  if CmdOk() {} else {return}
  Command.DelFirstWord()
  Command.Strip()
  switch MudCmd
  {
    case "advance"  : DoAdvance()
    case "afk"      : DoAfk()
    case "color"    : DoColor()
    case "look"     : DoLook()
    case "quit"     : DoQuit()
    case "say"      : DoSay()
    case "shutdown" : DoShutdown()
    case "status"   : DoStatus()
    case "tell"     : DoTell()
    case "title"    : DoTitle()
    case "who"      : DoWho()
    default         : ShouldNeverGetHere()
  }
}

//****************
//* Mud commands *
//****************

// Advance
func DoAdvance()
{
  LogIt("DEBUG", 5)
  PlayerTargetName = Command.Word(1)
  Command.DelFirstWord()
  Command.Strip()
  PlayerLevel = Int(Command)!
  Player.TargetLookUp()
  if pTarget == nil
  {
    pPlayer.Output += "I don't see "
    pPlayer.Output += PlayerTargetName
    Prompt()
    return
  }
  if PlayerLevel == pTarget.Level
  {
    pPlayer.Output += pTarget.Name
    pPlayer.Output += " is at level "
    pPlayer.Output += String(PlayerLevel)
    pPlayer.Output += " already."
    Prompt()
    return
  }
  // Message to player
  pPlayer.Output += "You advance "
  pPlayer.Output += pTarget.Name
  pPlayer.Output += " to level "
  pPlayer.Output += String(PlayerLevel)
  Prompt()
  // Message to target
  pTarget.Output += "\r\n"
  pTarget.Output += pPlayer.Name

  pTarget.Output += " advances you to level "
  pTarget.Output += String(PlayerLevel)
  pTarget.Output += "!"
  Prompt(pTarget)
  // Update target's variables
  pTarget.Level      = PlayerLevel
  pTarget.Experience = Int(Player.CalcLevelExperience(PlayerLevel))
  pTarget.HitPoints  = PlayerLevel * HIT_POINTS_PER_LEVEL
  // Update db
  SqlSetPart  = "Level      = $1,"
  SqlSetPart += "Experience = $2,"
  SqlSetPart += "HitPoints  = $3"
  SqlSetPart.Replace("$1", String(pTarget.Level))
  SqlSetPart.Replace("$2", String(pTarget.Experience))
  SqlSetPart.Replace("$3", String(pTarget.HitPoints))
  Player.Update(pTarget)
}

// Afk
func DoAfk()                                  // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  if pPlayer.Afk == "Yes"
  {
    pPlayer.Afk = "No"
    pPlayer.Output += "You are no longer AFK"
  }
  else
  {
    pPlayer.Afk = "Yes"
    pPlayer.Output += "You are now AFK"
  }
  SqlSetPart = "Afk = '$1'"
  SqlSetPart.Replace("$1", pPlayer.Afk)
  Player.Update()
  Prompt()
}

// Color
func DoColor()
{
  LogIt("DEBUG", 5)
  TmpStr = Command
  TmpStr.Lower()
  // Report color status
  if TmpStr == ""
  {
    if pPlayer.Color == "Yes"
    {
      pPlayer.Output += "&CColor&N is &Mon&N."
    }
    else
    {
      pPlayer.Output += "Color is off."
    }
    Prompt()
    return
  }
  // Something other than 'on' or 'off' was given
  if TmpStr != "on" && TmpStr != "off"
  {
    pPlayer.Output += "Color {on|off}"
    Prompt()
    return
  }
  // Color already on
  if TmpStr == "on" && pPlayer.Color == "Yes"
  {
    pPlayer.Output += "&CColor&N is ALREADY &Mon&N."
    Prompt()
    return
  }
  // Color already off
  if TmpStr == "off" && pPlayer.Color == "No"
  {
    pPlayer.Output += "Color is ALREADY off"
    Prompt()
    return
  }
  // Turn color on
  if TmpStr == "on"
  {
    PlayerColor = "Yes"
    pPlayer.Output += "You will now see &RP&Gr&Ye&Bt&Mt&Cy&N &RC&Go&Yl&Bo&Mr&Cs&N.";
  }
  // Turn color off
  if TmpStr == "off"
  {
    PlayerColor = "No"
    pPlayer.Output += "Color is off.";
  }
  // Update player's color setting
  pPlayer.Color = PlayerColor
  SqlSetPart = "Color = '$1'"
  SqlSetPart.Replace("$1", pPlayer.Color)
  Player.Update()
  Prompt()
}

// Look
func DoLook()                                 // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  pPlayer.Output += "You look around"
  Prompt()
}

// Quit
func DoQuit()                                 // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  DisconnectClient(pPlayer.SocketHandle)      // Socket.c
  Player.SetRemove()
  SqlSetPart  = "Afk    = 'No',"
  SqlSetPart += "Online = 'No'"
  Player.Update()
}

// Say
func DoSay()                                  // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  TmpStr = Command
  pPlayer.Output += "You say: "
  pPlayer.Output += TmpStr
  Prompt()
  MsgTxt = ""
  MsgTxt += "\r\n"
  MsgTxt += pPlayer.Name
  MsgTxt += " says: "
  MsgTxt += TmpStr
  SendToRoom()                                // Command.swift
}

// Shutdown
func DoShutdown()                             // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  GameShutdown = true
  MsgTxt = "HolyQuest is shutting down!"
  SendToAll()
  SqlSetPart  = "Afk    = 'No',"
  SqlSetPart += "Online = 'No'"
  for p1 in PlayerSet
  {
    Player.Update(p1)
  }
}

// Status
func DoStatus()                               // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  pPlayer.Output += "\r\n"
  // Name
  pPlayer.Output += "Name:         "
  pPlayer.Output += pPlayer.Name
  pPlayer.Output += "\r\n"
  // Level
  pPlayer.Output += "Level:        "
  pPlayer.Output += String(pPlayer.Level)
  pPlayer.Output += "\r\n"
  // Hit points
  pPlayer.Output += "Hit Points:   "
  pPlayer.Output += String(pPlayer.HitPoints)
  pPlayer.Output += "/"
  pPlayer.Output += String(pPlayer.Level * HIT_POINTS_PER_LEVEL)
  pPlayer.Output += "\r\n"
  // Experience
  TmpStr1 = FormatCommas(pPlayer.Experience)
  x = pPlayer.Level + 1
  y = Int(Player.CalcLevelExperience(x))
  TmpStr2 = FormatCommas(y)
  TmpStr1.Pad(TmpStr2.count,"L")
  pPlayer.Output += "Experience:   "
  pPlayer.Output += TmpStr1
  pPlayer.Output += "\r\n"
  pPlayer.Output += "Next Level:   "
  pPlayer.Output += String(TmpStr2)
  pPlayer.Output += "\r\n"
  // Armor class
  pPlayer.Output += "Armor Class:  "
  pPlayer.Output += String(pPlayer.ArmorClass)
  pPlayer.Output += "\r\n"
  // Color
  pPlayer.Output += "Color:        "
  pPlayer.Output += String(pPlayer.Color)
  pPlayer.Output += "\r\n"
  // Allow Group
  pPlayer.Output += "Allow Group:  "
  pPlayer.Output += String(pPlayer.AllowGroup)
  pPlayer.Output += "\r\n"
  // Allow assist
  pPlayer.Output += "Allow Assist: "
  pPlayer.Output += String(pPlayer.AllowAssist)
  pPlayer.Output += "\r\n"
  // Position
  pPlayer.Output += "Position:     "
  pPlayer.Output += String(pPlayer.Position)
  pPlayer.Output += "\r\n"
  // Silver
  pPlayer.Output += "Silver:       "
  pPlayer.Output += String(pPlayer.Silver)
  pPlayer.Output += "\r\n"
  // Hunger
  pPlayer.Output += "Hunger:       "
  pPlayer.Output += String(pPlayer.Hunger)
  pPlayer.Output += "\r\n"
  // Thirst
  pPlayer.Output += "Thirst:       "
  pPlayer.Output += String(pPlayer.Thirst)
  pPlayer.Output += "\r\n"
  Prompt()
}

// Tell
func DoTell()                                 // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  PlayerTargetName = Command.Word(1)
  Command.DelFirstWord()
  Command.Strip()
  MsgTxt = Command
  Player.TargetLookUp()
  if pTarget == nil
  {
    pPlayer.Output += "I don't see "
    pPlayer.Output += PlayerTargetName
    Prompt()
    return
  }
  if pPlayer.Name == pTarget.Name
  {
    pPlayer.Output += "Talking to youself?"
    Prompt()
    return
  }
  pPlayer.Output  += "You tell "
  pPlayer.Output  += pTarget.Name
  pPlayer.Output  += ": "
  pPlayer.Output  += MsgTxt
  Prompt()
  pTarget.Output  = ""
  pTarget.Output += "\r\n"
  pTarget.Output += "&M"
  pTarget.Output += pPlayer.Name
  pTarget.Output += " tells you: "
  pTarget.Output += MsgTxt
  pTarget.Output += "&N"
  Prompt(pTarget)
}

// Title
func DoTitle()
{
  PlayerTitle = Command
  if CommandWordCount == 1
  {
    if pPlayer.Title == ""
    {
      pPlayer.Output += "You don't have a title."
      Prompt()
      return
    }
    pPlayer.Output += "Your title is: "
    pPlayer.Output += pPlayer.Title
    Prompt()
    return
  }
  pPlayer.Output += "Your title is set to: "
  pPlayer.Output += PlayerTitle
  Prompt()
  pPlayer.Title = PlayerTitle
  SqlSetPart = "Title = '$1'"
  SqlSetPart.Replace("$1", PlayerTitle)
  Player.Update()
}

// Who
func DoWho()                                  // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  pPlayer.Output += "\r\n"
  pPlayer.Output += "Players online"
  pPlayer.Output += "\r\n"
  pPlayer.Output += "--------------"
  pPlayer.Output += "\r\n"
  for p1 in PlayerSet
  {
    if p1.State == Player.States.Playing
    {
      TmpStr = p1.Name
      TmpStr.Pad(8)
      pPlayer.Output += TmpStr
      TmpStr = String(p1.Level)
      TmpStr.Pad(3, "L")
      TmpStr.Pad(4)
      pPlayer.Output += TmpStr
      TmpStr = ""
      if p1.Afk == "Yes"
      {
        TmpStr = "(AFK)"
      }
      TmpStr.Pad(6)
      pPlayer.Output += TmpStr
      if !p1.Title.isEmpty
      {
        pPlayer.Output += p1.Title
      }
      pPlayer.Output += "\r\n"
    }
  }
  Prompt()
}

//********************
//* Helper functions *
//********************

// Validate the command
func CmdOk() -> Bool
{
  LogIt("DEBUG", 5)
  IsSynonym()
  SqlStmt = """
    Select
      Name,
      Admin,
      Level,
      MinPosition,
      Social,
      Fight,
      MinWords,
      Parts,
      Message
    From Command
    Where Name = '$1'
  """
  SqlStmt.Squeeze()
  SqlStmt = SqlStmt.replacingOccurrences(of: "$1", with: MudCmd)
  Db.OpenCursor()
  Found = Db.FetchCursor()
  if !Found
  {
    Db.CloseCursor()
    BadCmdMsg()
    return false
  }
  // We have a valid command
  CommandName          = Db.GetColTxt(ColNbrInSelect: Command_Name)
  CommandAdmin         = Db.GetColTxt(ColNbrInSelect: Command_Admin)
  CommandLevel         = Db.GetColInt(ColNbrInSelect: Command_Level)
  CommandMinPosition   = Db.GetColTxt(ColNbrInSelect: Command_MinPosition)
  CommandSocial        = Db.GetColTxt(ColNbrInSelect: Command_Social)
  CommandFight         = Db.GetColTxt(ColNbrInSelect: Command_Fight)
  CommandMinWords      = Db.GetColInt(ColNbrInSelect: Command_MinWords)
  CommandParts         = Db.GetColInt(ColNbrInSelect: Command_Parts)
  CommandMessage       = Db.GetColTxt(ColNbrInSelect: Command_Message)
  Db.CloseCursor()
  // Does the command require Admin Rights?
  if CommandAdmin == "y"
  {
    if pPlayer.Admin == "No"
    {
      BadCmdMsg()
      return false
    }
  }
  // Is there a level restriction for this command?
  if pPlayer.Level < CommandLevel
  {
    pPlayer.Output += "You must attain a higher level before using this command"
    Prompt()
    return false
  }
  // Does the command have the minimum number of words?
  if CommandWordCount < CommandMinWords
  {
    pPlayer.Output += CommandMessage
    Prompt()
    return false
  }
  return true
}

func IsSynonym()
{
  SqlStmt = """
    Select
      Name,
      Command,
      Info
    From Synonym
    Where Name = '$1'
  """
  SqlStmt.Squeeze()
  SqlStmt = SqlStmt.replacingOccurrences(of: "$1", with: MudCmd)
  Db.OpenCursor()
  Found = Db.FetchCursor()
  if !Found
  {
    Db.CloseCursor()
    return
  }
  // We have a valid synonym
  SynonymName          = Db.GetColTxt(ColNbrInSelect: Synonym_Name)
  SynonymCommand       = Db.GetColTxt(ColNbrInSelect: Synonym_Command)
  SynonymInfo          = Db.GetColTxt(ColNbrInSelect: Synonym_Info)
  Db.CloseCursor()
  MudCmd = SynonymCommand
}

// Bad command
func BadCmdMsg()                              // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  let x = Int.random(in: 1 ... 5)
  switch x
  {
  case 1:
    TmpStr = "How's that?"
    break;
  case 2:
    TmpStr = "You try to give a command, but fail."
    break;
  case 3:
    TmpStr = "Hmmm, making up commands?"
    break;
  case 4:
    TmpStr = "Ehh, what's that again?"
    break;
  case 5:
    TmpStr = "Feeling creative?"
    break;
  default :
    TmpStr = "Your command is not clear."
  }
  pPlayer.Output += TmpStr
  Prompt()
}

// Get player to Playing state
func GetPlayerGoing()                         // Command.swift
{
  LogIt("DEBUG", 5)
  if pPlayer.State == Player.States.IsNew
  {
    IsPlayerNew()
    return
  }
  if pPlayer.State == Player.States.GetName
  {
    GetPlayerName()                           // Command.swift
    return
  }
  if pPlayer.State == Player.States.GetPassword
  {
    GetPlayerPswd()                           // Command.swift
    if pPlayer.State == Player.States.SendGreeting
    {
      SendGreeting()                          // Command.swift
      SqlSetPart  = "Afk    = 'No',"
      SqlSetPart += "Online = 'Yes'"
      Player.Update()
    }
  }
}

// Is Player a new player?
func IsPlayerNew()
{
  TmpStr = Command
  TmpStr.Lower()
  if TmpStr != "y" && TmpStr != "n"
  {
    pPlayer.Output += "You must give Y or N."
    Prompt()
    return
  }
  if TmpStr == "y"
  {
    pPlayer.Output += "No new players accepted at this time."
    Prompt()
    return
  }
  // TmpStr must be "n"
  pPlayer.State = Player.States.GetName
  pPlayer.Output += "\r\n"
  pPlayer.Output += "Name?"
  Prompt()
}

// Get player name
func GetPlayerName()                          // Command.swift GetPlayerGoing()
{
  LogIt("DEBUG", 5)
  PlayerName = Command
  PlayerName.CapFirst()
  Command = ""
  if pPlayer.LookUp()                         // Player.swift
  {
    pPlayer.State = Player.States.GetPassword
    pPlayer.Output += "Password?"
    Prompt()
    return
  }
  pPlayer.Name = "*"
  pPlayer.Output += "Didn't find that name."
  Prompt()
}

// Get player password
func GetPlayerPswd()                          // Command.swift GetPlayerGoing()
{
  LogIt("DEBUG", 5)
  if pPlayer.Password == Command
  {
    pPlayer.State = Player.States.SendGreeting
    MudCmd = ""
    return
  }
  Command = ""
  pPlayer.Output += "Password mis-match"
  Prompt()
}

// Create player prompt
func Prompt(_ p1: Player! = pPlayer)
{
  p1.Output += "\r\n"
  p1.Output += "> "
}

// Send greetting
func SendGreeting()                           // Command.swift GetPlayerGoing()
{
  LogIt("DEBUG", 5)
  pPlayer.State = Player.States.Playing
  pPlayer.Output += "\r\n"
  pPlayer.Output += "May your travels be safe!"
  pPlayer.Output += "\r\n"
  Prompt()
}

// Send message to all players
func SendToAll()
{
  for p1 in PlayerSet
  {
    if p1.Name != pPlayer.Name
    {
      p1.Output += "\r\n"
    }
    if p1.State == Player.States.Playing
    {
      p1.Output += MsgTxt
      p1.Output += "\r\n"
    }
  }
}

// Send message to all players in the room
func SendToRoom()                             // Command.swift DoSay()
{
  LogIt("DEBUG", 5)
  for p1 in PlayerSet
  {
    if p1.Name == pPlayer.Name {continue}
    if p1.RoomNbr == pPlayer.RoomNbr
    {
      p1.Output += MsgTxt
      Prompt(p1)
    }
  }
}

func ShouldNeverGetHere()
{
  LogIt("Bad MudCmd, but you should never see this message", 1)
}
