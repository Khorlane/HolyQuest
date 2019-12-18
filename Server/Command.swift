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
    Command = "NOCOMMAND"
  }
  // Add code here to check for minimum number of words e.g. the TELL command must have at least 3 words (tell steve hi)
  MudCmd = Command.Word(1)
  pActor = pPlayer
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
  if MudCmd == "" {return}
  Command.DelFirstWord()
  MudCmd.Lower()
  Command.Strip()
  if ShortCommand[MudCmd] != nil
  {
    MudCmd = ShortCommand[MudCmd]!
  }
  switch MudCmd
  {
    case "afk"      : DoAfk()                 // Command.swift
    case "look"     : DoLook()                // Command.swift
    case "quit"     : DoQuit()                // Command.swift
    case "say"      : DoSay()                 // Command.swift
    case "shutdown" : DoShutdown()            // Command.swift
    case "status"   : DoStatus()              // Command.swift
    case "tell"     : DoTell()                // Command.swift
    case "who"      : DoWho()                 // Command.swift
    default         : BadCmdMsg()             // Command.swift
  }
}

// Get player to Playing state
func GetPlayerGoing()                         // Command.swift
{
  LogIt("DEBUG", 5)
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
    }
  }
}

// Afk
func DoAfk()                                  // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  if pActor.Afk == "Yes"
  {
    pActor.Afk = "No"
    pActor.Output += "You are no longer AFK"
    pActor.Output += "\r\n"
  }
  else
  {
    pActor.Afk = "Yes"
    pActor.Output += "You are now AFK"
    pActor.Output += "\r\n"
  }
  pActor.Output += "> "
}

// Look
func DoLook()                                 // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  pActor.Output += "You look around"
  pActor.Output += "\r\n"
  pActor.Output += "> "
}

// Quit
func DoQuit()                                 // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  DisconnectClient(pActor.SocketHandle)       // Socket.c
  Player.SetRemove()                          // Player.swift
}

// Say
func DoSay()                                  // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  TmpStr = Command
  pActor.Output += "You say: "
  pActor.Output += TmpStr
  pActor.Output += "\r\n"
  pActor.Output += "> "
  MsgTxt = ""
  MsgTxt += pActor.Name
  MsgTxt += " says: "
  MsgTxt += TmpStr
  MsgTxt += "\r\n"
  SendToRoom()                                // Command.swift
}

// Shutdown
func DoShutdown()                             // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  for p1 in PlayerSet
  {
    if p1.State == Player.States.Playing
    {
      DisconnectClient(p1.SocketHandle)       // Socket.c
    }
  }
  GameShutdown = true
}

// Status
func DoStatus()                               // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  pActor.Output += "\r\n"
  pActor.Output += "Name:        "
  pActor.Output += pActor.Name
  pActor.Output += "\r\n"
  pActor.Output += "Armor Class: "
  pActor.Output += String(pActor.ArmorClass)
  pActor.Output += "\r\n"
  pActor.Output += "> "
}

// Tell
func DoTell()                                 // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  PlayerTargetName = Command.Word(1)
  Command.DelFirstWord()
  Command.Strip()
  Player.TargetLookUp()                       // Player.swift
  if pTarget == nil
  {
    pActor.Output += "I don't see "
    pActor.Output += PlayerTargetName
    pActor.Output += "\r\n"
    pActor.Output += "> "
    return
  }
  if pActor.Name == pTarget.Name
  {
    pActor.Output += "Talking to youself?"
    pActor.Output += "\r\n"
    pActor.Output += "> "
    return
  }
  pActor.Output  += "You tell "
  pActor.Output  += pTarget.Name
  pActor.Output  += ": "
  pActor.Output  += Command
  pActor.Output  += "\r\n"
  pActor.Output  += "> "
  pTarget.Output  = ""
  pTarget.Output += "\r\n"
  pTarget.Output += Magenta
  pTarget.Output += pActor.Name
  pTarget.Output += " tells you: "
  pTarget.Output += Command
  pTarget.Output += Normal
  pTarget.Output += "\r\n"
  pTarget.Output += "> "
}

// Who
func DoWho()                                  // Command.swift ProcessCommand()
{
  LogIt("DEBUG", 5)
  pActor.Output += "\r\n"
  pActor.Output += "Players online"
  pActor.Output += "\r\n"
  pActor.Output += "--------------"
  pActor.Output += "\r\n"
  for p1 in PlayerSet
  {
    if p1.State == Player.States.Playing
    {
      pActor.Output += p1.Name
      pActor.Output += " "
      pActor.Output += p1.SocketAddr
      pActor.Output += " "
      pActor.Output += String(p1.SocketHandle)
      pActor.Output += " "
      if p1.Afk == "Yes"
      {
        pActor.Output += "(AFK)"
      }
      pActor.Output += "\r\n"
    }
  }
  pActor.Output += "> "
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
  pActor.Output += TmpStr
  pActor.Output += "\r\n"
  pActor.Output += "> "
}

// Get player name
func GetPlayerName()                          // Command.swift GetPlayerGoing()
{
  LogIt("DEBUG", 5)
  pPlayer.Name = MudCmd
  MudCmd = ""
  if pPlayer.LookUp()                    // Player.swift
  {
    pPlayer.State = Player.States.GetPassword
    pPlayer.Output += "Password?"
    pPlayer.Output += "\r\n"
    pPlayer.Output += "> "
    return
  }
  pPlayer.Name = "*"
  pPlayer.Output += "Didn't find that name."
  pPlayer.Output += "\r\n"
  pPlayer.Output += "> "
}

// Get player password
func GetPlayerPswd()                          // Command.swift GetPlayerGoing()
{
  LogIt("DEBUG", 5)
  if pPlayer.Password == MudCmd
  {
    pPlayer.State = Player.States.SendGreeting
    MudCmd = ""
    return
  }
  MudCmd = ""
  pPlayer.Output += "Password mis-match"
  pPlayer.Output += "\r\n"
  pPlayer.Output += "> "
}

// Send greetting
func SendGreeting()                           // Command.swift GetPlayerGoing()
{
  LogIt("DEBUG", 5)
  pPlayer.State = Player.States.Playing
  pPlayer.Output += "\r\n"
  pPlayer.Output += "May your travels be safe!"
  pPlayer.Output += "\r\n"
  pPlayer.Output += "\r\n"
  pPlayer.Output += "> "
}

// Send message to all players in the room
func SendToRoom()                             // Command.swift DoSay()
{
  LogIt("DEBUG", 5)
  for p1 in PlayerSet
  {
    if p1.Name == pActor.Name {continue}
    if p1.RoomNbr == pActor.RoomNbr
    {
      p1.Output += MsgTxt
      p1.Output += "> "
    }
  }
}
