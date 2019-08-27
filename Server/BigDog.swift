//
//  BigDog.swift
//  HolyQuest
//
//  Created by Stephen Bryant on 8/23/19.
//  Copyright © 2019 CodePlain. All rights reserved.
//

import Foundation

func BigDog()
{
  StartItUp()

  while !GameShutdown
  {
    CheckSocketActivity()
    CheckForNewPlayers()
    if PlayerSet.isEmpty
    {
      LogIt(LogMsg: "INFOx No Connections: Going to sleep", LogLvl: 0)
      while PlayerSet.isEmpty
      {
        usleep(0100000)
        CheckSocketActivity()
        CheckForNewPlayers()
      }
      LogIt(LogMsg: "INFOx Waking up", LogLvl: 0)
    }
    GetPlayerInput()
    SendPlayerOutput()
    usleep(0100000)
  }
  ShutItDown()
}

func CheckSocketActivity()
{
  PrepForSelectMaster()
  MaxSocketHandle = ListenSocket
  for p in PlayerSet
  {
    PrepForSelectPlayer(p.SocketHandle)
    if p.SocketHandle > MaxSocketHandle
    {
      MaxSocketHandle = p.SocketHandle
    }
  }
  SocketSelect(MaxSocketHandle)
}

func CheckForNewPlayers()
{
  NewConnection = IsNewConnection()
  if NewConnection == 1
  {
    SocketHandle1 = AcceptNewConnection();
    PlayerNew()
  }
}

func GetPlayerInput()
{
  for p in PlayerSet
  {
    pPlayer = p
    GotInput = CheckClient(p.SocketHandle)
    if GotInput == 1
    {
      ReadBytes = ReadClient(p.SocketHandle)
      pTmpStr = GetBuffer()
      Command = String(cString: pTmpStr!)
      ProcessCommand()
    }
  }
}

func SendPlayerOutput()
{
  for p in PlayerSet
  {
    if p.Output.count > 0
    {
      pTmpStr = p.Output.GetStrPointer()
      SetBuffer(pTmpStr)
      SendClient(p.SocketHandle)
      p.Output = ""
    }
  }
}
