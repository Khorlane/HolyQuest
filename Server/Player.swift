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
  var RoomNbr       : Int

  enum States
  {
    case GetName
    case GetPassword
    case Playing
  }

  init(Name: String, SocketAddr: String, SocketHandle: Int32)
  {
    print("*** Player Class init ***")
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
    self.RoomNbr      = START_ROOM
  }

  func IsValidName() -> Bool
  {
    print("*** IsValidName ***")
    if ValidNamesPswd[pPlayer.Name] != nil
    {
      return true
    }
    return false
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
  print("*** PlayerAdd ***")
  print("PlayerAdd", SocketAddr)
  pPlayer = Player.init(Name: "*", SocketAddr: SocketAddr, SocketHandle: SocketHandle1)
  PlayerSetInsert()
}

func PlayerDel()
{
  print("*** PlayerDel ***")
  PlayerSetRemove()
}

func PlayerSetLookUp()
{
  print("*** PlayerSetLookUp ***")
  for p1 in PlayerSet
  {
    if p1.Name == PlayerName
    {
      pPlayer = p1
      break
    }
  }
}

func PlayerSetInsert()
{
  print("*** PlayerSetInsert ***")
  let Good = PlayerSet.insert(pPlayer)
  if Good.inserted == false
  {
    print("PlayerSetInsert failed")
  }
}

func PlayerSetRemove()
{
  print("*** PlayerSetRemove ***")
  let Good = PlayerSet.remove(pPlayer)
  if Good == nil
  {
    print("PlayerSetRemove failed")
  }
  print("Player Removed!")
}
