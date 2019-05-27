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
  DoPlayerStuff()

  // Process Command
  Command.Lower()
  switch Command
  {
  case "afk"      : DoAfk()
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
      if p1.Afk == true
      {
        pActor.Output += "(AFK)"
      }
      pActor.Output += "\r\n"
    }
  }
}

func DoZitsBroken()
{
  print("*** DoZitsBroken ***")
  print("She's a pumping mud, shut 'er down!")
}

func DoPlayerStuff()
{
  print("*** DoPlayerStuff ***")
  //PlayerSetLookUp()
  pActor = pPlayer
  GetPlayerName()
  GetPlayerPswd()
}

func GetPlayerName()
{
  if PlayerName != "abc" {return}
  print("*** GetPlayerName ***")
  if pPlayer.State == Player.States.GetName
  {
    pPlayer.Name = Command
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
  if PlayerName != "abc" {return}
  print("*** GetPlayerPswd ***")
  if pPlayer.State == Player.States.GetPassword
  {
    if ValidNamesPswd[pPlayer.Name]! == Command
    {
      pPlayer.State = Player.States.Playing
      return
    }
    print("Invalid password")
    return
  }
}
