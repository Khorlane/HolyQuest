// HolyQuest
// Utility.swift
// Utility functions
// Created by Steve Bryant on 12/25/2018.
// Copyright 2019 Steve Bryant. All rights reserved.

import Foundation
// Date()
// FileHandle
// URL

func StartItUp()
{
  OpenLog()
  Db.Open()
  SocketServerInit()
  ListenSocket = SocketServerListen(Int32(PORT_NUMBER))
  TmpStr = "INFOx HolyQuest is Listening on Port "
  TmpStr += String(PORT_NUMBER)
  LogIt(LogMsg: TmpStr, LogLvl: 0)
}

func ShutItDown()
{
  LogIt(LogMsg: "INFOx HolyQuest is stopping...", LogLvl: 0)
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
  LogPath     = HOME_DIR + "/" + LOG_DIR + "/"
  LogFileName = LOG_FILE_NAME
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
      exit(EXIT_FAILURE)
    }
    if error.count > 0
    {
      print("Error output:")
      print(error)
      exit(EXIT_FAILURE)
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
  SetTimestampFmt()
}

func CloseLog()
{
  TmpStr =          "-------------------------\r\n"
  TmpStr = TmpStr + "HolyQuest End of Log File\r\n"
  LogHandle = try! FileHandle(forWritingTo: LogFile)
  LogHandle.seekToEndOfFile()
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

extension String
{
  // Return count of words in a string
  var Words : Int
  {
    return self.split(separator: " ").count
  }

  // Remove extra whitespace
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

  // Trim leadng and trailing whitespace and newlines
  mutating func Strip()
  {
    self = self.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  // Delete first word from a string
  mutating func RemoveWord(_ Nbr: Int) -> String
  {
    return String(self.dropFirst(self.Word(Nbr).count))
  }

  // Force string to lowercase
  mutating func Lower()
  {
    self = self.lowercased()
  }

  // Return the nth word in a string
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
