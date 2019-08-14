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
  SetTimestampFmt()
  HostAdr     = HOST_ADDRESS_IPV4
  PortNbr     = PORT_NUMBER
  LogPath     = HOME_DIR + "/" + LOG_DIR + "/"
  LogFileName = LOG_FILE_NAME
  OpenLog()
  Db.Open()
}

func ShutItDown()
{
  Db.Close()
  CloseLog()
}

func LogIt
  (LogMsg:    String,
   LogLvl:    Int,
   function:  String = #function,
   file:      String = #file,
   line:      Int    = #line)
{
  if LogLvl > LogLvlMax {return}
  TimeStamp = Date()
  TmpStr = TimeStampFmt.string(from: TimeStamp)
  TmpStr = TmpStr + " \(LogMsg) (File: \(file), Function: \(function), Line: \(line))"
  TmpStr = TmpStr + "\r\n"
  LogHandle = try! FileHandle(forWritingTo: LogFile)
  LogHandle.seekToEndOfFile()
  LogHandle.write(TmpStr.data(using: .utf8)!)
}

func OpenLog()
{
  let FromFile = LogPath + LogFileName + ".empty"
  let ToFile   = LogPath + LogFileName
  let (output, error, status) = RunCmd(cmd: "/bin/cp", args: FromFile, ToFile)
  if status != 0
  {
    print("Program exited with status \(status)")
    if output.count > 0
    {
      print("Program output:")
      print(output)
      exit(2)
    }
    if error.count > 0
    {
      print("Error output:")
      print(error)
      exit(2)
    }
  }
  LogFile = URL.init(fileURLWithPath: LogPath)
  LogFile = LogFile.appendingPathComponent(LogFileName)
  LogHandle = try! FileHandle(forWritingTo: LogFile)
  TmpStr = "HolyQuest Log File\r\n"
  LogHandle.write(TmpStr.data(using: .utf8)!)
  TmpStr = "------------------\r\n"
  LogHandle.write(TmpStr.data(using: .utf8)!)
  LogHandle.closeFile()
}

func CloseLog()
{
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

extension String
{
  var Words : Int
  {
    return self.split(separator: " ").count
  }

  mutating func Squeeze()
  {
    self.Strip()
    self = self.replacingOccurrences(of: "\r", with: " ")
    self = self.replacingOccurrences(of: "\n", with: " ")
    self = self.replacingOccurrences(of: "\t", with: " ")
    while self.contains("  ")
    {
      self = self.replacingOccurrences(of: "  ", with: " ")
    }
  }

  mutating func Strip()
  {
    self = self.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  mutating func DeletePrefix(_ prefix: String) -> String
  {
    guard self.hasPrefix(prefix) else { return self }
    return String(self.dropFirst(prefix.count))
  }

  mutating func Lower()
  {
    self = self.lowercased()
  }

  func Word(_ Nbr: Int) -> String
  {
    return String(self.split(separator: " ")[Nbr-1])
  }

  // Get pointer to a string so we can use it like a C string
  func GetStrPointer() -> UnsafeMutablePointer<Int8>
  {
    var Count  : Int
    var Result : UnsafeMutablePointer<Int8>

    Count = self.utf8.count + 1
    Result = UnsafeMutablePointer<Int8>.allocate(capacity: Count)
    self.withCString
      { (BaseAddress) in
        Result.initialize(from: BaseAddress, count: Count)
    }
    return Result
  }
}
