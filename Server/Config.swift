// HolyQuest
// Config.swift
// Configuration file
// Created by Steve Bryant on 12/25/2018.
// Copyright 2019 Steve Bryant. All rights reserved.

import Foundation
// Date
// DateFormatter
// FileHandle
// URL

var Command             : String          = ""
var CommandWordCount    : Int             = 0
var Found               : Bool            = false
var GameShutdown        : Bool            = false
var GotInput            : Int32           = 0
var HostAdr             : String          = ""
var Index               : Int             = 0
var ListenSocket        : Int32           = 0
var LogFile             : URL             = URL.init(fileURLWithPath: "/")
var LogFileName         : String          = ""
var LogHandle           : FileHandle      = FileHandle()
var LogPath             : String          = ""
var MaxSocketHandle     : Int32           = 0
var MsgTxt              : String          = ""
var MudCmd              : String          = ""
var NewConnection       : Int32           = 0
var PlayerTargetName    : String          = ""
var PortNbr             : Int             = 0
var ReadBytes           : Int             = 0
var SocketAddr          : String          = ""
var SocketHandle1       : Int32           = 0
var SockLocAdr          : String          = ""
var SqlStmt             : String          = ""
var SqlStmtLen          : Int32           = 0
var SqlCode             : Int32           = 0
var TimeStamp           : Date            = Date()
var TimeStampFmt        : DateFormatter   = DateFormatter()
var TmpStr              : String          = ""

var x                   : Int             = 0

var pWorldDb            : OpaquePointer?
var pSqlResultSet       : OpaquePointer?
var pActor              : Player!         = nil
var pPlayer             : Player!         = nil
var pTarget             : Player!         = nil
var PlayerSet                             = Set<Player>()

let ShortCommand =
  [
    "i":"inventory",
    "l":"look",
    "k":"kill"
  ]

let HOST_ADDRESS_IPV4 = "127.0.0.1"
let HOST_ADDRESS_IPV6 = "::1"
let LOG_PATH          = "/Users/stephenbryant/Projects/HolyQuest/Logs/"
let LOG_FILE_NAME     = "Log.txt"
let PORT_NUMBER       = 7777
let START_ROOM        = 86
