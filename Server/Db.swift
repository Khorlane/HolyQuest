//
//  Db.swift
//  HolyQuest
//
//  Created by Stephen Bryant on 6/3/19.
//  Copyright © 2019 CodePlain. All rights reserved.
//

import Foundation
import SQLite3

class Db
{
  static func Open()
  {
    Result = sqlite3_open("/Users/stephenbryant/Projects/HolyQuest/Library/World.db3", &pWorldDb)
    if Result != SQLITE_OK
    {
      print("Open Failed")
      return
    }
    print("Database open worked!")
  }

  static func Close()
  {
    Result = sqlite3_close(pWorldDb)
    if Result == SQLITE_OK
    {
      print("Database close worked!")
    }
  }

  static func DoSqlStmt()
  {
    let SqlStmt = "Select * from Player where Name = 'Steve'"
    Result = sqlite3_exec(pWorldDb, SqlStmt, nil, nil, nil)
    if Result == SQLITE_OK
    {
      print("Database select worked!")
    }
    print("Result: ", Result)
  }
}
