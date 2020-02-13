// HolyQuest
// Utility.swift
// Utility functions
// Created by Steve Bryant on 12/25/2018.
// Copyright 2019 CodePlain. All rights reserved.

import Foundation
// Date()
// FileHandle
// URL

// Log messages
func LogIt                                    // Called from all over the place
  (_ LogMsg:  String,
   _ LogLvl:  Int,
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

// Open the log
func OpenLog()                                // BigDog.swift StartItUp()
{
  LogPath     = HOME_DIR + "/" + LOG_DIR + "/"
  LogFileName = LOG_FILE_NAME
  LogFromFile = LogPath + LogFileName + ".empty"
  LogToFile   = LogPath + LogFileName
  let (output, error, status) = RunCmd(cmd: "/bin/cp", args: LogFromFile, LogToFile)
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
  SetTimestampFmt()                           // Utility.swift
}

// Close the log
func CloseLog()                               // BigDog.swift ShutItDown()
{
  TmpStr =          "-------------------------\r\n"
  TmpStr = TmpStr + "HolyQuest End of Log File\r\n"
  LogHandle = try! FileHandle(forWritingTo: LogFile)
  LogHandle.seekToEndOfFile()
  LogHandle.write(TmpStr.data(using: .utf8)!)
  LogHandle.closeFile()
}

// Run a shell command                        // Utility.swift OpenLog()
func RunCmd(cmd : String, args : String...) -> (output: [String], error: [String], exitCode: Int32) // Utility.swift OpenLog()
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

// Set up log timestamp format
func SetTimestampFmt()                        // Utility.swift OpenLog()
{
  TimeStampFmt.dateStyle  = .full
  TimeStampFmt.timeStyle  = .full
  TimeStampFmt.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
}

// Add commas to a number
func FormatCommas(_ x: Int) -> String
{
  let numberFormatter = NumberFormatter()
  numberFormatter.numberStyle = .decimal
  let y = numberFormatter.string(from: NSNumber(value:x))!
  return y
}

func GetPosNbr(_ Position: String) -> Int
{
  switch Position
  {
    case "sleep" : return 1
    case "sit"   : return 2
    case "stand" : return 3
    default      : return 0
  }
}

func RoomsVisited()
{
  var RoomsVisited = [UInt8]()
  var Bits : UInt8
  var Flip : UInt8
  Bits = 0b00000000
  RoomsVisited.append(Bits)
  RoomsVisited.append(Bits)
  Flip = 0b00000100
  Bits = Bits | Flip
  RoomsVisited[0] = Bits
  RoomsVisited[1] = Bits
}

//***************************
//* String class extensions *
//***************************
extension String
{
  // Force string to all lower case and then capitalize first letter
  mutating func CapFirst()
  {
    self = self.lowercased()
    self = self.capitalized
  }

  // Delete first word from a string
  mutating func DelFirstWord()
  {
    self = String(self.dropFirst(self.Word(1).count+1))
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

  // Force string to lowercase
  mutating func Lower()
  {
    self = self.lowercased()
  }

  // Pad a string to a specified length
  mutating func Pad(_ Length: Int, _ LeftOrRight: String = "R")
  {
    if LeftOrRight == "R"
    {
      self.PadRight(Length)
    }
    if LeftOrRight == "L"
    {
      self.PadLeft(Length)
    }
  }

  mutating func PadRight(_ Length: Int)
  {
    if self.count > Length {return}
    self = self.padding(toLength: Length, withPad: " ", startingAt: 0)
  }

  mutating func PadLeft(_ Length: Int)
  {
    let ToPad = Length - self.count;
    if ToPad < 1 {return}
    self = "".padding(toLength: ToPad, withPad: " ", startingAt: 0) + self;
  }

  // Relace stuff in a string
  mutating func Replace(_ From: String, _ To: String)
  {
    self = self.replacingOccurrences(of: From, with: To)
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

  // Substitute appropriate pronouns
  mutating func SubPronoun()
  {
    // Player
    if pPlayer.Sex == "M"
    {
      PronounHeShe          = "he";
      PronounHimHer         = "him";
      PronounHisHers        = "his";
      PronounHimselfHerself = "himself";
    }
    else
    {
      PronounHeShe          = "she";
      PronounHimHer         = "her";
      PronounHisHers        = "hers";
      PronounHimselfHerself = "herself";
    }
    self.Replace("$P",               pPlayer.Name)
    self.Replace("$pHeShe",          PronounHeShe)
    self.Replace("$pHimHer",         PronounHimHer)
    self.Replace("$pHisHers",        PronounHisHers)
    self.Replace("$pHimselfHerself", PronounHimselfHerself)
    // Target
    if pTarget.Sex == "M"
    {
      PronounHeShe          = "he";
      PronounHimHer         = "him";
      PronounHisHers        = "his";
      PronounHimselfHerself = "himself";
    }
    else
    {
      PronounHeShe          = "she";
      PronounHimHer         = "her";
      PronounHisHers        = "hers";
      PronounHimselfHerself = "herself";
    }
    self.Replace("$T",               pPlayer.Name)
    self.Replace("$tHeShe",          PronounHeShe)
    self.Replace("$tHimHer",         PronounHimHer)
    self.Replace("$tHisHers",        PronounHisHers)
    self.Replace("$tHimselfHerself", PronounHimselfHerself)
  }

  // Return the nth word in a string
  func Word(_ Nbr: Int) -> String
  {
    if self.split(separator: " ").count == 0 {return ""}
    return String(self.split(separator: " ")[Nbr-1])
  }

  // Return count of words in a string
  var Words : Int
  {
    return self.split(separator: " ").count
  }
}
