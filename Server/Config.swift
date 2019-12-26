// HolyQuest
// Config.swift
// Configuration file
// Created by Steve Bryant on 12/25/2018.
// Copyright 2019 CodePlain. All rights reserved.

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
var LogLvlMax           : Int             = 1
var MaxSocketHandle     : Int32           = 0
var MsgTxt              : String          = ""
var MudCmd              : String          = ""
var NewConnection       : Int32           = 0
var PlayerTargetName    : String          = ""
var PlayerSet                             = Set<Player>()
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
var TmpStr1             : String          = ""
var TmpStr2             : String          = ""

var pSqlResultSet       : OpaquePointer?
var pWorldDb            : OpaquePointer?

var pPlayer             : Player!         = nil
var pTarget             : Player!         = nil

var pCh                 : UnsafeMutablePointer<Int8>?

//let HOST_ADDRESS_IPV4 = "127.0.0.1"
//let HOST_ADDRESS_IPV6 = "::1"
let PORT_NUMBER         = 7777
let START_ROOM          = 86

let HOME_DIR            = "/Users/stephenbryant/Projects/HolyQuest"
let GREETING_DIR        = "Library"
let LOG_DIR             = "Log"
let WORLD_DIR           = "Library"

let GREETING_FILE_NAME  = "Greeting.txt"
let LOG_FILE_NAME       = "Log.txt"
let WORLD_FILE_NAME     = "World.db3"

let SLEEP_TIME          = 0100000

// Color codes
let Normal              = "\u{001B}[0;m"
let Magenta             = "\u{001B}[1;35m"
