// HolyQuest
// main.swift
// The main()
// Created by Steve Bryant on 12/25/2018.
// Copyright 2019 Steve Bryant. All rights reserved.

import Foundation     // Not required at this time

print("HolyQuest is starting...")
var x : Int32

var pTmpStr1 : UnsafeMutablePointer<Int8>?
var pTmpStr2 : UnsafeMutablePointer<Int8>?
var TmpStr1  : String
var TmpStr2  : String

pTmpStr1 = GetBuffer()
print("pTmpStr1 value:", pTmpStr1!)
print("pTmpStr1 type:", type(of: pTmpStr1))
TmpStr1 = String(cString: pTmpStr1!)
print(TmpStr1)

TmpStr1 = "This is my test string"
pTmpStr1 = GetStrPtr(from: TmpStr1)
pTmpStr2 = PassReturnString(pTmpStr1)
TmpStr2 = String(cString: pTmpStr2!)
print()
print("String after returning:", TmpStr2)

ChatServerInit()

PutMessage()
ListenSocket = ChatServerListen()
print("HolyQuest is Listening on Port 7777")

while Running
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
    SocketAddr = String(SocketHandle1)
    PlayerAdd()
  }
  for p in PlayerSet
  {
    pPlayer = p
    GotInput = CheckClient(p.SocketHandle)
    if GotInput == 1
    {
      ReadBytes = ReadClient(p.SocketHandle)
      if ReadBytes == 0
      {
        DisconnectClient(p.SocketHandle)
        PlayerDel()
        continue
      }
      pTmpStr1 = GetBuffer()
      TmpStr1 = String(cString: pTmpStr1!)
      print("Buffer: ", TmpStr1)
      if TmpStr1 == "shutdown\n"
      {
        Running = false
      }
      SendClient(p.SocketHandle)
    }
  }
  usleep(5000000)
}
