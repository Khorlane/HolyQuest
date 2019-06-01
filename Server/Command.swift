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
  MudCmd = Command.components(separatedBy: " ").first!
  PlayerSetLookUp()
  pActor = pPlayer
  GetPlayerGoing()
  if pPlayer.State != Player.States.Playing {return}
  if MudCmd == "" {return}
  MudCmd.Lower()
  Command = Command.DeletePrefix(MudCmd)
  Command.Strip()
  switch MudCmd
  {
    case "afk"      : DoAfk()
    case "say"      : DoSay()
    case "shutdown" : DoShutdown()
    case "tell"     : DoTell()
    case "who"      : DoWho()
    default         : DoZitsBroken()
    pActor.Output += "Invalid command"
    pActor.Output += "\r\n"
    pActor.Output += "> "
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

func DoSay()
{
  TmpStr1 = Command
  pActor.Output = ""
  pActor.Output += "You say: "
  pActor.Output += TmpStr1
  pActor.Output += "\r\n"
  pActor.Output += "> "
  MsgTxt = ""
  MsgTxt += pActor.Name
  MsgTxt += " says: "
  MsgTxt += TmpStr1
  MsgTxt += "\r\n"
  SendToRoom()
}

func DoShutdown()
{
  print("*** DoShutdown ***")
  GameShutdown = true
}

func DoTell()
{
  print("*** DoTell ***")
  PlayerTargetName = Command.components(separatedBy: " ").first!
  TmpStr = Command.DeletePrefix(PlayerTargetName)
  TmpStr.Strip()
  PlayerSetTargetLookUp()
  if pActor.Name == pTarget.Name
  {
    pActor.Output = ""
    pActor.Output += "Talking to youself?"
    pActor.Output += "\r\n"
    pActor.Output += "> "
    return
  }
  pActor.Output = ""
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

func DoZitsBroken()
{
  print("*** DoZitsBroken ***")
  print("She's a pumping mud, shut 'er down!")
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
  pPlayer.Password = MudCmd
  MudCmd = ""
  if ValidNamesPswd[pPlayer.Name]! == pPlayer.Password
  {
    pPlayer.State = Player.States.SendGreeting
    return
  }
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
