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
  if tbCommand.Social == "y"
  {
    Socialize()
    return
  }
  switch MudCmd
  {
    case "advance"  : DoAdvance()
    case "afk"      : DoAfk()
    case "color"    : DoColor()
    case "help"     : DoHelp()
    case "look"     : DoLook()
    case "quit"     : DoQuit()
    case "say"      : DoSay()
    case "show"     : DoShow()
    case "shutdown" : DoShutdown()
    case "sit"      : DoSit()
    case "sleep"    : DoSleep()
    case "stand"    : DoStand()
    case "status"   : DoStatus()
    case "tell"     : DoTell()
    case "title"    : DoTitle()
    case "wake"     : DoWake()
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
  TmpInt = Int(Command)!
  Player.TargetLookUp()
  if pTarget == nil
  {
    pPlayer.Output += "I don't see "
    pPlayer.Output += PlayerTargetName
    Prompt()
    return
  }
  if TmpInt == pTarget.Level
  {
    pPlayer.Output += pTarget.Name
    pPlayer.Output += " is at level "
    pPlayer.Output += String(TmpInt)
    pPlayer.Output += " already."
    Prompt()
    return
  }
  pTarget.Level = TmpInt
  // Message to player
  pPlayer.Output += "You advance "
  pPlayer.Output += pTarget.Name
  pPlayer.Output += " to level "
  pPlayer.Output += String(pTarget.Level)
  Prompt()
  // Message to target
  pTarget.Output += "\r\n"
  pTarget.Output += pPlayer.Name

  pTarget.Output += " advances you to level "
  pTarget.Output += String(pTarget.Level)
  pTarget.Output += "!"
  Prompt(pTarget)
  // Update target's variables
  pTarget.Experience = Int(Player.CalcLevelExperience(pTarget.Level))
  pTarget.HitPoints  = pTarget.Level * HIT_POINTS_PER_LEVEL
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
    pPlayer.Color = "Yes"
    pPlayer.Output += "You will now see &RP&Gr&Ye&Bt&Mt&Cy&N &RC&Go&Yl&Bo&Mr&Cs&N.";
  }
  // Turn color off
  if TmpStr == "off"
  {
    pPlayer.Color = "No"
    pPlayer.Output += "Color is off.";
  }
  // Update player's color setting
  SqlSetPart = "Color = '$1'"
  SqlSetPart.Replace("$1", pPlayer.Color)
  Player.Update()
  Prompt()
}

// Help
func DoHelp()
{
  var HelpFound : Bool = false

  LogIt("DEBUG", 5)
  func GetHelp()
  {
    for line in Lines
    {
      TmpStr1 = String(line)
      TmpStr1.Lower()
      if !HelpFound
      {
        if TmpStr1.Word(1) != "help:"+TmpStr {continue}
        HelpFound = true
        pPlayer.Output += line
        pPlayer.Output += "\r\n"
        continue
      }
      // Help topic found
      pPlayer.Output += line
      pPlayer.Output += "\r\n"
      if TmpStr1.Word(1) == "related" {break}
    }
  }
  // Open and read help file
  HelpPath     = HOME_DIR + "/" + HELP_DIR + "/"
  HelpFileName = HELP_FILE_NAME
  HelpFile     = HelpPath + HelpFileName
  // Read the contents of the specified file
  Contents = try! String(contentsOfFile: HelpFile)
  // Split the file into separate lines
  Lines = Contents.split(separator: "\r\n", omittingEmptySubsequences: false)
  // Process help command
  TmpStr = Command
  TmpStr.Lower()
  if TmpStr == "helptopicsonly"
  {
    pPlayer.Output += "Help Topics\r\n"
    pPlayer.Output += "-----------"
    for line in Lines
    {
      if line.prefix(5) == "Help:"
      {
        pPlayer.Output += line.suffix(line.count - 5)
        pPlayer.Output += "\r\n"
      }
    }
    return
  }
  // General help
  if TmpStr == ""
  {
    x = 0
    for line in Lines
    {
      pPlayer.Output += line
      x = x + 1
      if x > 23 {break}
      pPlayer.Output += "\r\n"
    }
    Prompt()
    return
  }
  // Look for specific help topic
  GetHelp()
  if HelpFound
  {
    Prompt()
    return
  }
  // That help topic was not found
  TmpStr = "notfound"
  GetHelp()
  if !HelpFound
  { // There really is NO help!
    pPlayer.Output += "There is no help!!"
    pPlayer.Output += "\r\n"
  }
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

// Show
func DoShow()
{
  LogIt("DEBUG", 5)
  func GetRows()
  {
    SqlStmt.Squeeze()
    Db.OpenCursor()
    Found = Db.FetchCursor()
    while Found
    {
      ColNbr = 0
      tbCommand.Name = Db.GetColTxt()
      pPlayer.Output += tbCommand.Name
      pPlayer.Output += "\r\n"
      Found = Db.FetchCursor()
    }
    Db.CloseCursor()
  }
  func ShowCommands()
  {
    SqlStmt = """
      Select
        Name
      From Command
      Where Admin in ("$1","$2")
        And Social = "n"
      Order By Name
    """
    pPlayer.Output += "Commands\r\n"
    pPlayer.Output += "--------\r\n"
    if pPlayer.Admin == "Yes"
    {
      SqlStmt.Replace("$1", "y")
      SqlStmt.Replace("$2", "n")
    }
    else
    {
      SqlStmt.Replace("$1", "n")
      SqlStmt.Replace("$2", "n")
    }
    GetRows()
  }
  func ShowSocials()
  {
    SqlStmt = """
      Select
        Name
      From Command
      Where Social = "y"
      Order By Name
    """
    pPlayer.Output += "Socials\r\n"
    pPlayer.Output += "-------\r\n"
    if pPlayer.Admin == "Yes"
    {
      SqlStmt.Replace("$1", "y")
    }
    else
    {
      SqlStmt.Replace("$1", "n")
    }
    GetRows()
  }
  TmpStr = Command
  TmpStr.Lower()
  if TmpStr == "commands"
  {
    ShowCommands()
    Prompt()
    return
  }
  if TmpStr == "socials"
  {
    ShowSocials()
    Prompt()
    return
  }
  if TmpStr == "help"
  {
    Command = "HelpTopicsOnly"
    DoHelp()
    Prompt()
    return
  }
  // Valid options: commands, socials, help ONLY
  pPlayer.Output += "Show what?"
  Prompt()
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

// Sit
func DoSit()
{
  LogIt("DEBUG", 5)
  pPlayer.Position = "sit"
  pPlayer.Output += "You sit down."
  MsgTxt = ""
  MsgTxt += "\r\n"
  MsgTxt += pPlayer.Name
  MsgTxt += " sits down."
  SendToRoom()
  // Update player's position
  SqlSetPart = "Position = 'sit'"
  Player.Update()
  Prompt()
}

// Sleep
func DoSleep()
{
  LogIt("DEBUG", 5)
  pPlayer.Position = "sleep"
  pPlayer.Output += "You fall asleep."
  MsgTxt = ""
  MsgTxt += "\r\n"
  MsgTxt += pPlayer.Name
  MsgTxt += " falls asleep."
  SendToRoom()
  // Update player's position
  SqlSetPart = "Position = 'sleep'"
  Player.Update()
  Prompt()
}

// Stand
func DoStand()
{
  LogIt("DEBUG", 5)
  pPlayer.Position = "stand"
  pPlayer.Output += "You stand up."
  MsgTxt = ""
  MsgTxt += "\r\n"
  MsgTxt += pPlayer.Name
  MsgTxt += " stands up."
  SendToRoom()
  // Update player's position
  SqlSetPart = "Position = 'stand'"
  Player.Update()
  Prompt()
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
  LogIt("DEBUG", 5)
  TmpStr = Command
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
  pPlayer.Title = TmpStr
  pPlayer.Output += "Your title is set to: "
  pPlayer.Output += pPlayer.Title
  Prompt()
  SqlSetPart = "Title = '$1'"
  SqlSetPart.Replace("$1", pPlayer.Title)
  Player.Update()
}

// Wake
func DoWake()
{
  LogIt("DEBUG", 5)
  pPlayer.Position = "sit"
  pPlayer.Output += "You awake and sit up."
  MsgTxt = ""
  MsgTxt += "\r\n"
  MsgTxt += pPlayer.Name
  MsgTxt += " wakes up."
  SendToRoom()
  // Update player's position
  SqlSetPart = "Position = 'sit'"
  Player.Update()
  Prompt()
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

// Process social commands
func Socialize()
{
  LogIt("DEBUG", 5)
  PlayerTargetName = Command.Word(1)
  if PlayerTargetName.isEmpty
  {
    SocializeGetMsg(1)
    tbSocial.Message.SubPronoun()
    pPlayer.Output += tbSocial.Message
    Prompt()
    SocializeGetMsg(2)
    tbSocial.Message.SubPronoun()
    MsgTxt = tbSocial.Message
    SendToRoom()
    return
  }
}

// Get social message
func SocializeGetMsg(_ MsgNbr : Int)
{
  LogIt("DEBUG", 5)
  SqlStmt = """
    Select
      Name,
      MessageNbr,
      Message
    From Social
    Where Name = '$1'
      And MessageNbr = $2
  """
  SqlStmt.Squeeze()
  SqlStmt = SqlStmt.replacingOccurrences(of: "$1", with: MudCmd)
  Db.OpenCursor()
  Found = Db.FetchCursor()
  if !Found
  {
    Db.CloseCursor()
    TmpStr  = "ERROR reading Social table"
    TmpStr += MudCmd
    TmpStr += String(MsgNbr)
    LogIt(TmpStr, 0)
    return
  }
  // We have a social message
  ColNbr = 0
  tbSocial.Name          = Db.GetColTxt()
  tbSocial.MessageNbr    = Db.GetColInt()
  tbSocial.Message       = Db.GetColTxt()
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
  ColNbr = 0
  tbCommand.Name          = Db.GetColTxt()
  tbCommand.Admin         = Db.GetColTxt()
  tbCommand.Level         = Db.GetColInt()
  tbCommand.MinPosition   = Db.GetColTxt()
  tbCommand.Social        = Db.GetColTxt()
  tbCommand.Fight         = Db.GetColTxt()
  tbCommand.MinWords      = Db.GetColInt()
  tbCommand.Parts         = Db.GetColInt()
  tbCommand.Message       = Db.GetColTxt()
  Db.CloseCursor()
  // Does the command require Admin Rights?
  if tbCommand.Admin == "y"
  {
    if pPlayer.Admin == "No"
    {
      BadCmdMsg()
      return false
    }
  }
  // Is there a level restriction for this command?
  if pPlayer.Level < tbCommand.Level
  {
    pPlayer.Output += "You must attain a higher level before using this command"
    Prompt()
    return false
  }
  // Does the command have the minimum number of words?
  if CommandWordCount < tbCommand.MinWords
  {
    pPlayer.Output += tbCommand.Message
    Prompt()
    return false
  }
  // Player is sleeping and command OK while sleeping?
  if pPlayer.Position == "sleep" && tbCommand.MinPosition == "sleep"
  {
    return true
  }
  // Player is sleeping
  if pPlayer.Position == "sleep"
  {
    SleepMsg()
    return false
  }
  PosNbr1 = GetPosNbr(MudCmd)
  PosNbr2 = GetPosNbr(pPlayer.Position)
  PosNbr3 = GetPosNbr(tbCommand.MinPosition)
  // Is player already in that position?
  if PosNbr1 == PosNbr2
  {
    pPlayer.Output += "You are already "
    pPlayer.Output += pPlayer.Position
    pPlayer.Output += "ing."
    Prompt()
    return false
  }
  // Is player in a valid position for the command given?
  if PosNbr2 < PosNbr3
  {
    pPlayer.Output += "You must be "
    pPlayer.Output += tbCommand.MinPosition
    pPlayer.Output += "ing to do that."
    Prompt()
    return false
  }
  return true
}

func IsSynonym()
{
  LogIt("DEBUG", 5)
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
  ColNbr = 0
  tbSynonym.Name          = Db.GetColTxt()
  tbSynonym.Command       = Db.GetColTxt()
  tbSynonym.Info          = Db.GetColTxt()
  Db.CloseCursor()
  MudCmd = tbSynonym.Command
}

// Bad command
func BadCmdMsg()                              // Command.swift CmdOk()
{
  LogIt("DEBUG", 5)
  x = Int.random(in: 1 ... 5)
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

// Sleep message
func SleepMsg()                               // Command.swift CmdOk()
{
  LogIt("DEBUG", 5)
  x = Int.random(in: 1 ... 5)
  switch x
  {
  case 1:
    TmpStr = "You must be dreaming."
    break;
  case 2:
    TmpStr = "You dream about doing something."
    break;
  case 3:
    TmpStr = "It's such a nice dream, please don't wake me."
    break;
  case 4:
    TmpStr = "Your snoring almost wakes you up."
    break;
  case 5:
    TmpStr = "Dream, dream, dreeeeaaaammmm, all I do is dream."
    break;
  default :
    TmpStr = "You must be dreaming."
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
  LogIt("DEBUG", 5)
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
  tbPlayer.Name = Command
  tbPlayer.Name.CapFirst()
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
  LogIt("DEBUG", 5)
  for p1 in PlayerSet
  {
    if p1.Name == pPlayer.Name            {continue}
    if p1.State != Player.States.Playing  {continue}
    p1.Output += MsgTxt
    Prompt(p1)
  }
}

// Send message to all players in the room
func SendToRoom()                             // Command.swift DoSay()
{
  LogIt("DEBUG", 5)
  for p1 in PlayerSet
  {
    if p1.Name == pPlayer.Name            {continue}
    if p1.State != Player.States.Playing  {continue}
    if p1.RoomNbr != pPlayer.RoomNbr      {continue}
    p1.Output += MsgTxt
    Prompt(p1)
  }
}

func ShouldNeverGetHere()
{
  LogIt("Bad MudCmd, but you should never see this message", 1)
}
