// HolyQuest
// Command.swift
// Process commands
// Created by Steve Bryant on 12/25/2018.
// Copyright 2019 Steve Bryant. All rights reserved.

import Foundation   // Not required at this time

func ProcessCommand()
{
  Command.Strip()
  LogIt(Message: Command)
  //DoPlayerStuff()

  // Process Command
  Command.Lower()
  switch Command
  {
  case "afk"      : DoAfk()
  case "shutdown" : DoShutdown()
  case "who"      : DoWho()
  default         : DoZitsBroken()
  //pActor.Output += "Invalid command"
  //pActor.Output += "\r\n"
  }
  // chatHandler.SendToPlayers()
}

func DoAfk()
{
  if pActor.Afk == true
  {
    pActor.Afk = false
    pActor.Output += "Your are no longer AFK"
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
  GameShutdown = true
}

func DoWho()
{
  pActor.Output += "\r\n"
  pActor.Output += "Players online"
  pActor.Output += "\r\n"
  pActor.Output += "--------------"
  pActor.Output += "\r\n"
  for p in PlayerSet
  {
    if p.State == Player.States.Playing
    {
      print(p.Name, p.SocketAddr)
      pActor.Output += p.Name
      if p.Afk == true
      {
        pActor.Output += "(AFK)"
      }
      pActor.Output += "\r\n"
    }
  }
}

func DoZitsBroken()
{
  print("She's a pumping mud, shut 'er down!")
}

func DoPlayerStuff()
{
  PlayerSetLookUp()
  pActor = pPlayer
  GetPlayerName()
  GetPlayerPswd()
}

func GetPlayerName()

// Player Name
{
  if pPlayer.State == Player.States.GetName
  {
    pPlayer.Name = Command
    if pPlayer.IsValidName()
    {
      pPlayer.State = Player.States.GetPassword
      return
    }
    print("Invalid name")
    pPlayer.Name = "*"
    return
  }
}

func GetPlayerPswd()
{
  // Player Password
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
