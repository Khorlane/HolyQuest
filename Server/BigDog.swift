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
  Initialization()
  SocketServerInit()
  ListenSocket = SocketServerListen()
  TmpStr = "INFOx HolyQuest is Listening on Port "
  TmpStr += String(PORT_NUMBER)
  LogIt(LogMsg: TmpStr, LogLvl: 0)
  while !GameShutdown
  {
    CheckForPlayers()
    GetPlayerInput()
    SendPlayerOutput()
    usleep(0100000)
  }
  ShutItDown()
}

func CheckForPlayers()
{
  SetUpSelectMaster()
  MaxSocketHandle = ListenSocket
  for p in PlayerSet
  {
    SetUpSelectPlayer(p.SocketHandle)
    if p.SocketHandle > MaxSocketHandle
    {
      MaxSocketHandle = p.SocketHandle
    }
  }
  CheckForSocketActivity(MaxSocketHandle)
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
