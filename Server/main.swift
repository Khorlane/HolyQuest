// HolyQuest
// main.swift
// The main()
// Created by Steve Bryant on 12/25/2018.
// Copyright © 2019 Steve Bryant. All rights reserved.

import Foundation     // Not required at this time

print("HolyQuest is starting...")
var x : Int32

var pTmpStr1 : UnsafeMutablePointer<Int8>?
var pTmpStr2 : UnsafeMutablePointer<Int8>?
var TmpStr1  : String
var TmpStr2  : String

pTmpStr1 = ReturnBuffer()
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
ChatServerListen()
print("HolyQuest is Listening on Port 7777")

while ChatServerLooper() == 1 {usleep(5000000)}
