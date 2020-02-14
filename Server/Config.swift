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
var AddExp                : Float                 = 0
var BaseExp               : Float                 = 0
var Command               : String                = ""
var CommandWordCount      : Int                   = 0
var Contents              : String                = ""
var Found                 : Bool                  = false
var GameShutdown          : Bool                  = false
var GotInput              : Int32                 = 0
var HostAdr               : String                = ""
var Index                 : Int                   = 0
var Lines                 : Array<Substring>      = []
var ListenSocket          : Int32                 = 0
var LogLvlMax             : Int                   = 1
var MaxSocketHandle       : Int32                 = 0
var MsgTxt                : String                = ""
var MudCmd                : String                = ""
var NewConnection         : Int32                 = 0
var PlayerSet                                     = Set<Player>()
var PlayerTargetName      : String                = ""
var PortNbr               : Int                   = 0
var PosNbr1               : Int                   = 0
var PosNbr2               : Int                   = 0
var PosNbr3               : Int                   = 0
var PronounHeShe          : String                = ""
var PronounHimHer         : String                = ""
var PronounHimselfHerself : String                = ""
var PronounHisHers        : String                = ""
var ReadBytes             : Int                   = 0
var SetInsertOk           : Bool                  = false
var SockLocAdr            : String                = ""
var SocketAddr            : String                = ""
var SocketHandle1         : Int32                 = 0
var SqlCode               : Int32                 = 0
var SqlSetPart            : String                = ""
var SqlStmt               : String                = ""
var SqlStmtLen            : Int32                 = 0
var TimeStamp             : Date                  = Date()
var TimeStampFmt          : DateFormatter         = DateFormatter()
var TmpInt                : Int                   = 0
var TmpStr                : String                = ""
var TmpStr1               : String                = ""
var TmpStr2               : String                = ""
var TotalExp              : Float                 = 0

// File related variables
var GreetingFile          : String                = ""
var GreetingFileName      : String                = ""
var GreetingPath          : String                = ""
var HelpFile              : String                = ""
var HelpFileName          : String                = ""
var HelpPath              : String                = ""
var LogFile               : URL                   = URL.init(fileURLWithPath: "/")
var LogFileName           : String                = ""
var LogFromFile           : String                = ""
var LogHandle             : FileHandle            = FileHandle()
var LogPath               : String                = ""
var LogToFile             : String                = ""
var WorldFile             : String                = ""
var WorldFileName         : String                = ""
var WorldPath             : String                = ""

// Single letter variables
var x                     : Int                   = 0
var y                     : Int                   = 0

// Player pointers
var pPlayer               : Player!               = nil
var pTarget               : Player!               = nil
var pRemove               : Player!               = nil
var pInsert               : Player!               = nil

// SQLite pointers
var pColTxt               : UnsafePointer<UInt8>? = nil
var pSqlResultSet         : OpaquePointer?
var pWorldDb              : OpaquePointer?

// Columns in an SQLite result set
var ColInt                : Int                   = 0
var ColNbr                : Int32                 = 0
var ColTxt                : String                = ""

// The ubiquitous C char pointer
var pCh                   : UnsafeMutablePointer<Int8>?

// Some literals
let HIT_POINTS_PER_LEVEL = 31
let PORT_NUMBER          = 7777
let SLEEP_TIME           = 0100000
let START_ROOM           = 86

// Game directories
let HELP_DIR             = "Library"
let HOME_DIR             = "/Users/stephenbryant/Projects/HolyQuest"
let GREETING_DIR         = "Library"
let LOG_DIR              = "Log"
let WORLD_DIR            = "Library"

// File names
let HELP_FILE_NAME       = "Help.txt"
let GREETING_FILE_NAME   = "Greeting.txt"
let LOG_FILE_NAME        = "Log.txt"
let WORLD_FILE_NAME      = "World.db3"

// Color codes
let Normal               = "\u{001B}[0;m"     // &N
let Black                = "\u{001B}[1;30m"   // &K
let Red                  = "\u{001B}[1;31m"   // &R
let Green                = "\u{001B}[1;32m"   // &G
let Yellow               = "\u{001B}[1;33m"   // &Y
let Blue                 = "\u{001B}[1;34m"   // &B
let Magenta              = "\u{001B}[1;35m"   // &M
let Cyan                 = "\u{001B}[1;36m"   // &C
let White                = "\u{001B}[1;37m"   // &W

// Messages
let GameSleepMsg         = "INFOx No Connections: Going to sleep"
let GameWakeMsg          = "INFOx Waking up"
