// HolyQuest
// main.swift
// The main()
// Created by Steve Bryant on 12/25/2018.
// Copyright 2019 Steve Bryant. All rights reserved.

import Foundation     // Not required at this timex

Initialization()

var pTmpStr1 : UnsafeMutablePointer<Int8>?
var pTmpStr2 : UnsafeMutablePointer<Int8>?
var TmpStr1  : String
var TmpStr2  : String

ChatServerInit()

ListenSocket = ChatServerListen()
LogIt(LogMsg: "INFOx HolyQuest is Listening on Port 7777", LogLvl: 0)

while !GameShutdown
{
  SetUpSelect1()
  MaxSocketHandle = ListenSocket
  for p in PlayerSet
  {
    SetUpSelect2(p.SocketHandle)
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
  for p in PlayerSet
  {
    pPlayer = p
    GotInput = CheckClient(p.SocketHandle)
    if GotInput == 1
    {
      ReadBytes = ReadClient(p.SocketHandle)
      pTmpStr1 = GetBuffer()
      Command = String(cString: pTmpStr1!)
      ProcessCommand()
    }
  }
  for p in PlayerSet
  {
    if p.Output.count > 0
    {
      pTmpStr1 = p.Output.GetStrPointer()
      SetBuffer(pTmpStr1)
      SendClient(p.SocketHandle)
      p.Output = ""
    }
  }
  usleep(0100000)
}

ShutItDown()
