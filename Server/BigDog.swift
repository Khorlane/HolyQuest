// HolyQuest
// BigDog.swift
// Game loop
// Created by Steve Bryant on 08/23/2019.
// Copyright 2019 CodePlain. All rights reserved.

import Foundation
// usleep

// Main Game Loop
func BigDog()
{
  StartItUp()                                 // BigDog.swift

  while !GameShutdown
  {
    HeartBeat()                               // BigDog.swift
    CheckSocketActivity()                     // BigDog.swift
    CheckForNewPlayers()                      // BigDog.swift
    if PlayerSet.isEmpty
    {
      GameSleep()                             // BigDog.swift
      while PlayerSet.isEmpty
      {
        Sleep()                               // BigDog.swift
        CheckSocketActivity()                 // BigDog.swift
        CheckForNewPlayers()                  // BigDog.swift
      }
      GameWake()                              // BigDog.swift
    }
    GetPlayerInput()                          // BigDog.swift
    SendPlayerOutput()                        // BigDog.swift
    Sleep()                                   // BigDog.swift
  }
  ShutItDown()
}

// Tasks not directly related a player's command
func HeartBeat()                              // BigDog.swift BigDog()
{
  let MobsMove = "GoGo"
  if MobsMove == "GoGo" {return}
}

// Do we have any activity on any of our sockets?
func CheckSocketActivity()                    // BigDog.swift BigDog()
{
  PrepForSelectMaster()                       // Socket.c
  MaxSocketHandle = ListenSocket
  for p in PlayerSet
  {
    PrepForSelectPlayer(p.SocketHandle)       // Socket.c
    if p.SocketHandle > MaxSocketHandle
    {
      MaxSocketHandle = p.SocketHandle
    }
  }
  SocketSelect(MaxSocketHandle)               // Socket.c
}

// Do we have a new player connecting?
func CheckForNewPlayers()                     // BigDog.swift BigDog()
{
  NewConnection = IsNewConnection()           // Socket.c
  if NewConnection == 1
  {
    SocketHandle1 = AcceptNewConnection();    // Socket.c
    NewPlayer()                               // BigDog.swift
  }
}

// We have a new player
func NewPlayer()                              // BigDog.swift CheckForNewPlayers()
{
  LogIt("DEBUG", 5)
  pPlayer = Player.init(Name: "*", SocketAddr: SocketAddr, SocketHandle: SocketHandle1) // Player.swift
  Player.Greeting()                           // Player.swift
  pPlayer.Output += "Name?"
  pPlayer.Output += "\r\n"
  pPlayer.Output += "> "
  Player.SetInsert()                           // Player.swift
}

// For each player, Get and process commands
func GetPlayerInput()                         // BigDog.swift BigDog()
{
  for p in PlayerSet
  {
    pPlayer = p
    GotInput = CheckClient(p.SocketHandle)    // Socket.c
    if GotInput == 1
    {
      ReadBytes = ReadClient(p.SocketHandle)  // Socket.c
      pCh = GetBuffer()                       // Socket.c
      Command = String(cString: pCh!)
      ProcessCommand()                        // Command.swift
    }
  }
}

// For each player, send output
func SendPlayerOutput()                       // BigDog.swift BigDog()
{
  for p in PlayerSet
  {
    if p.Output.count > 0
    {
      Color(p)
      pCh = p.Output.GetStrPointer()          // Utility.swift
      SetBuffer(pCh)                          // Socket.c
      SendClient(p.SocketHandle)              // Socket.c
      // If socket is closed or other issue, SendClient() sticks 'quit' in the buffer
      pCh = GetBuffer()                       // Socket.c
      Command = String(cString: pCh!)
      if Command == "quit"
      {
        pPlayer.State = Player.States.Disconnect
        ProcessCommand()                      // Command.swift
        Command = ""
      }
      p.Output = ""
    }
  }
}

// Colorize player's output or not colorize
func Color(_ p: Player)
{
  if p.Color == "Yes"
  {
    p.Output.Replace("&N", Normal)
    p.Output.Replace("&K", Black)
    p.Output.Replace("&R", Red)
    p.Output.Replace("&G", Green)
    p.Output.Replace("&Y", Yellow)
    p.Output.Replace("&B", Blue)
    p.Output.Replace("&M", Magenta)
    p.Output.Replace("&C", Cyan)
    p.Output.Replace("&W", White)
  }
  else
  {
    p.Output.Replace("&N", "")
    p.Output.Replace("&K", "")
    p.Output.Replace("&R", "")
    p.Output.Replace("&G", "")
    p.Output.Replace("&Y", "")
    p.Output.Replace("&B", "")
    p.Output.Replace("&M", "")
    p.Output.Replace("&C", "")
    p.Output.Replace("&W", "")
  }
}

// Start up the game
func StartItUp()                              // BigDog.swift BigDog()
{
  OpenLog()                                   // Utility.swift
  Db.Open()                                   // Db.swift
  SocketServerInit()                          // Socket.c
  ListenSocket = SocketServerListen(Int32(PORT_NUMBER)) // Socket.c
  TmpStr = "INFOx HolyQuest is Listening on Port "
  TmpStr += String(PORT_NUMBER)
  LogIt(TmpStr, 0)
}

// Shut down the game
func ShutItDown()                             // BigDog.swift BigDoc()
{
  LogIt("INFOx HolyQuest is stopping...", 0)
  for p1 in PlayerSet
  {
    if p1.State == Player.States.Playing
    {
      DisconnectClient(p1.SocketHandle)       // Socket.c
    }
  }
  Db.Close()                                  // Db.swift
  CloseLog()                                  // Utility.swift
}

// Sleep a bit
func Sleep()                                  // BigDog.swift
{
  usleep(useconds_t(SLEEP_TIME))
}

// Nothing to do
func GameSleep()
{
  LogIt("INFOx No Connections: Going to sleep", 0)
}

// Soemthing to do
func GameWake()
{
  LogIt("INFOx Waking up", 0)
}
