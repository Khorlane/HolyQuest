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
  DoPlayerStuff()
  MudCmd.Lower()
  Command = Command.deletingPrefix(MudCmd)
  Command.Strip()
  switch MudCmd
  {
    case "afk"      : DoAfk()
    case "say"      : DoSay()
    case "shutdown" : DoShutdown()
    case "who"      : DoWho()
    default         : DoZitsBroken()
    pActor.Output += "Invalid command"
    pActor.Output += "\r\n"
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
      pActor.Output += p1.SocketAddr
      pActor.Output += String(p1.SocketHandle)
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

func DoPlayerStuff()
{
  print("*** DoPlayerStuff ***")
  PlayerSetLookUp()
  pActor = pPlayer
  if pPlayer.State == Player.States.GetName
  {
    GetPlayerName()
  }
  else
  if pPlayer.State == Player.States.GetPassword
  {
    GetPlayerPswd()
  }
}

func GetPlayerName()
{
  print("*** GetPlayerName ***")
  if pPlayer.State == Player.States.GetName
  {
    pPlayer.Name = MudCmd
    if pPlayer.IsValidName()
    {
      pPlayer.State = Player.States.GetPassword
      return
    }
    print("Invalid name")
    return
  }
}

func GetPlayerPswd()
{
  print("*** GetPlayerPswd ***")
  if pPlayer.State == Player.States.GetPassword
  {
    if ValidNamesPswd[pPlayer.Name]! == MudCmd
    {
      pPlayer.State = Player.States.Playing
      return
    }
    print("Invalid password")
    return
  }
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
