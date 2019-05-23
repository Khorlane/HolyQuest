// HolyQuest
// Player.swift
// Player class
// Created by Steve Bryant on 12/31/2018.
// Copyright 2019 Steve Bryant. All rights reserved.

import Foundation   // Not required at this time

class Player
{
  var Name          : String
  var Afk           : Bool
  var Output        : String
  var SocketHandle  : Int32
  var SocketAddr    : String
  var State         = States.GetName

  enum States
  {
    case GetName
    case GetPassword
    case Playing
  }

  init(Name: String, SocketAddr: String, SocketHandle: Int32)
  {
    self.Name         = Name
    self.Afk          = false
    self.Output       = ""
    self.SocketAddr   = SocketAddr
    self.SocketHandle = SocketHandle
    self.State        = States.GetName
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

extension Player: Hashable
{
  static func == (lhs: Player, rhs: Player) -> Bool
  {
    return lhs.Name == rhs.Name
  }
  func hash(into hasher: inout Hasher)
  {
    hasher.combine(Name)
  }
}

func PlayerAdd()
{
  print("PlayerAdd", SocketAddr)
  pPlayer = Player.init(Name: SocketAddr, SocketAddr: SocketAddr, SocketHandle: SocketHandle1)
  PlayerSetInsert()
}

func PlayerDel()
{
  PlayerSetRemove()
}

func PlayerSetLookUp()
{
  for p in PlayerSet
  {
    if p.SocketAddr == SocketAddr
    {
      pPlayer = p
      break
    }
  }
}

func PlayerSetInsert()
{
  let Good = PlayerSet.insert(pPlayer)
  if Good.inserted == false
  {
    print("PlayerSetInsert failed")
  }
}

func PlayerSetRemove()
{
  let Good = PlayerSet.remove(pPlayer)
  if Good == nil
  {
    print("PlayerSetRemove failed")
  }
  print("Player Removed!")
}
