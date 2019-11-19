// HolyQuest
// BigDog.swift
// Game loop
// Created by Steve Bryant on 08/23/2019.
// Copyright 2019 CodePlain. All rights reserved.

func BigDog()
{
  StartItUp()

  while !GameShutdown
  {
    HeartBeat()
    CheckSocketActivity()
    CheckForNewPlayers()
    if PlayerSet.isEmpty
    {
      LogIt(LogMsg: "INFOx No Connections: Going to sleep", LogLvl: 0)
      while PlayerSet.isEmpty
      {
        Sleep()
        CheckSocketActivity()
        CheckForNewPlayers()
      }
      LogIt(LogMsg: "INFOx Waking up", LogLvl: 0)
    }
    GetPlayerInput()
    SendPlayerOutput()
    Sleep()
  }
  ShutItDown()
}

func HeartBeat()
{
  let MobsMove = "GoGo"
  if MobsMove == "GoGo" {return}
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
      // If socket is closed or other issue, SendClient() sticks 'quit' in the buffer
      pTmpStr = GetBuffer()
      Command = String(cString: pTmpStr!)
      if Command == "quit"
      {
        pPlayer.State = Player.States.Disconnect
        ProcessCommand()
        Command = ""
      }
      p.Output = ""
    }
  }
}
