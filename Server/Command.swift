// HolyQuest
// Command.swift
// Process commands
// Created by Steve Bryant on 12/25/2018.
// Copyright 2019 Steve Bryant. All rights reserved.

import Foundation   // Not required at this time

func ProcessCommand()
{
  print ("*** ProcessCommand ***")
  Command.Strip()
  LogIt(Message: Command)
  CommandWordCount = Command.Words
  MudCmd = Command.Word(1)
  pActor = pPlayer
  GetPlayerGoing()
  if pPlayer.State != Player.States.Playing {return}
  if MudCmd == "" {return}
  Command = Command.DeletePrefix(MudCmd)
  MudCmd.Lower()
  Command.Strip()
  if ShortCommand[MudCmd] != nil
  {
    MudCmd = ShortCommand[MudCmd]!
  }
  switch MudCmd
  {
    case "afk"      : DoAfk()
    case "look"     : DoLook()
    case "say"      : DoSay()
    case "shutdown" : DoShutdown()
    case "status"   : DoStatus()
    case "tell"     : DoTell()
    case "who"      : DoWho()
    default         : BadCmdMsg()
  }
}

func GetPlayerGoing()
{
  if pPlayer.State == Player.States.GetName
  {
    GetPlayerName()
    return
  }
  if pPlayer.State == Player.States.GetPassword
  {
    GetPlayerPswd()
    if pPlayer.State == Player.States.SendGreeting
    {
      SendGreeting()
    }
  }
}

func DoAfk()
{
  print("*** DoAfk ***")
  if pActor.Afk == true
  {
    pActor.Afk = false
    pActor.Output += "You are no longer AFK"
    pActor.Output += "\r\n"
  }
  else
  {
    pActor.Afk = true
    pActor.Output += "You are now AFK"
    pActor.Output += "\r\n"
  }
  pActor.Output += "> "
}

func DoLook()
{
  pActor.Output += "You look around"
  pActor.Output += "\r\n"
  pActor.Output += "> "
}

func DoSay()
{
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
  SendToRoom()
}

func DoShutdown()
{
  print("*** DoShutdown ***")
  GameShutdown = true
}

func DoStatus()
{
  pActor.Output += "\r\n"
  pActor.Output += "Name:        "
  pActor.Output += pActor.Name
  pActor.Output += "\r\n"
  pActor.Output += "Armor Class: "
  pActor.Output += String(pActor.ArmorClass)
  pActor.Output += "\r\n"
  pActor.Output += "> "
}

func DoTell()
{
  print("*** DoTell ***")
  //PlayerTargetName = Command.components(separatedBy: " ").first!
  PlayerTargetName = Command.Word(1)
  TmpStr = Command.DeletePrefix(PlayerTargetName)
  TmpStr.Strip()
  PlayerSetTargetLookUp()
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
  pActor.Output += "You tell "
  pActor.Output += PlayerTargetName
  pActor.Output += ": "
  pActor.Output += TmpStr
  pActor.Output += "\r\n"
  pActor.Output += "> "
  pTarget.Output = ""
  pTarget.Output += "\r\n"
  pTarget.Output += pActor.Name
  pTarget.Output += " tells you: "
  pTarget.Output += TmpStr
  pTarget.Output += "\r\n"
  pTarget.Output += "> "
}

func DoWho()
{
  print("*** DoWho ***")
  pActor.Output += "\r\n"
  pActor.Output += "Players online"
  pActor.Output += "\r\n"
  pActor.Output += "--------------"
  pActor.Output += "\r\n"
  for p1 in PlayerSet
  {
    if p1.State == Player.States.Playing
    {
      print(p1.Name, p1.SocketAddr)
      pActor.Output += p1.Name
      pActor.Output += " "
      pActor.Output += p1.SocketAddr
      pActor.Output += " "
      pActor.Output += String(p1.SocketHandle)
      pActor.Output += " "
      if p1.Afk == true
      {
        pActor.Output += "(AFK)"
      }
      pActor.Output += "\r\n"
    }
  }
  pActor.Output += "> "
}

func BadCmdMsg()
{
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
  pActor.Output += TmpStr
  pActor.Output += "\r\n"
  pActor.Output += "> "
}

func GetPlayerName()
{
  print("*** GetPlayerName ***")
  pPlayer.Name = MudCmd
  MudCmd = ""
  if pPlayer.IsValidName()
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

func GetPlayerPswd()
{
  print("*** GetPlayerPswd ***")
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

func SendGreeting()
{
  print("*** SendGreeting ***")
  pPlayer.State = Player.States.Playing
  pPlayer.Output += "\r\n"
  pPlayer.Output += "May your travels be safe!"
  pPlayer.Output += "\r\n"
  pPlayer.Output += "\r\n"
  pPlayer.Output += "> "
}

func SendToRoom()
{
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
