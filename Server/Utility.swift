// HolyQuest
// Utility.swift
// Utility functions
// Created by Steve Bryant on 12/25/2018.
// Copyright 2019 Steve Bryant. All rights reserved.

import Foundation
// Date()
// FileHandle
// URL

func Initialization()
{
  HostAdr     = HOST_ADDRESS_IPV4
  PortNbr     = PORT_NUMBER
  LogPath     = LOG_PATH
  LogFileName = LOG_FILE_NAME
  OpenLog()
  SetTimestampFmt()
}

func LogIt
  (Message:  String,
   function: String = #function,
   file:     String = #file,
   line:     Int    = #line)
{
  TimeStamp = Date()
  TmpStr = TimeStampFmt.string(from: TimeStamp)
  TmpStr = TmpStr + " \(Message) (File: \(file), Function: \(function), Line: \(line))"
  print(TmpStr)
  TmpStr = TmpStr + "\r\n"
  LogHandle = try! FileHandle(forWritingTo: LogFile)
  LogHandle.seekToEndOfFile()
  LogHandle.write(TmpStr.data(using: .utf8)!)
}

func OpenLog()
{
  LogFile = URL.init(fileURLWithPath: LogPath)
  LogFile = LogFile.appendingPathComponent(LogFileName)
  let (output, error, status) = RunCmd(cmd: "/bin/cp", args: "/Users/stephenbryant/Projects/HolyQuest/Logs/Log1.txt", "/Users/stephenbryant/Projects/HolyQuest/Logs/Log.txt")
  if status != 0
  {
    print("Program exited with status \(status)")
    if output.count > 0 {
      print("Program output:")
      print(output)
    }
    if error.count > 0 {
      print("Error output:")
      print(error)
    }
  }
  LogHandle = try! FileHandle(forWritingTo: LogFile)
  TmpStr = "HolyQuest Log File\r\n"
  LogHandle.write(TmpStr.data(using: .utf8)!)
  TmpStr = "------------------\r\n"
  LogHandle.write(TmpStr.data(using: .utf8)!)
  LogHandle.closeFile()
}

func RunCmd(cmd : String, args : String...) -> (output: [String], error: [String], exitCode: Int32)
{
  var output : [String] = []
  var error  : [String] = []

  let task = Process()
  task.launchPath = cmd
  task.arguments  = args

  let outpipe = Pipe()
  task.standardOutput = outpipe
  let errpipe = Pipe()
  task.standardError  = errpipe

  task.launch()

  let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
  if var string = String(data: outdata, encoding: .utf8)
  {
    string = string.trimmingCharacters(in: .newlines)
    output = string.components(separatedBy: "\n")
  }

  let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
  if var string = String(data: errdata, encoding: .utf8)
  {
    string = string.trimmingCharacters(in: .newlines)
    error = string.components(separatedBy: "\n")
  }

  task.waitUntilExit()
  let status = task.terminationStatus

  return (output, error, status)
}

func SetTimestampFmt()
{
  TimeStampFmt.dateStyle = .full
  TimeStampFmt.timeStyle = .full
  TimeStampFmt.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
}

func StopServer()
{
  LogHandle.closeFile()
  //try! group.syncShutdownGracefully()
}

extension String
{
  mutating func Strip()
  {
    self = self.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

extension String
{
  mutating func Lower()
  {
    self = self.lowercased()
  }
}

// string2cstring.swift
func GetStrPtr(from Str: String) -> UnsafeMutablePointer<Int8>
{
  var Count  : Int
  var Result : UnsafeMutablePointer<Int8>

  Count = Str.utf8.count + 1
  Result = UnsafeMutablePointer<Int8>.allocate(capacity: Count)
  Str.withCString
    { (BaseAddress) in
      Result.initialize(from: BaseAddress, count: Count)
  }
  return Result
}
