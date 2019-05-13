// HolyQuest
// Player.swift
// Player class
// Created by Steve Bryant on 12/31/2018.
// Copyright © 2019 Steve Bryant. All rights reserved.

import Foundation   // Not required at this time

class Player
{
  var Name        : String
  var Afk         : Bool
  var Output      : String
  var SockRmtAdr  : String
  var State       = States.GetName

  enum States
  {
    case GetName
    case GetPassword
    case Playing
  }

  init(Name: String, SockRmtAdr: String)
  {
    self.Name       = Name
    self.Afk        = false
    self.Output     = ""
    self.SockRmtAdr = SockRmtAdr
    self.State      = States.GetName
  }

  func IsValidName() -> Bool
  {
    if ValidNamesPswd[pPlayer.Name] != nil
    {
      return true
    }
    return false
  }
}

func SetPlayerPtr()
{
  Index = -1
  for p in PlayerList
  {
    Index = Index + 1
    if p.SockRmtAdr == SockRmtAdr
    {
      pPlayer = p
      break
    }
  }
}

func PlayerAdd()
{
  pPlayer = Player.init(Name: "*", SockRmtAdr: SockRmtAdr)
  PlayerList.append(pPlayer!)
}

func PlayerDel()
{
  PlayerList.remove(at: Index)
  pPlayer = nil
}
