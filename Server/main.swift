//
//  main.swift
//  HolyQuest
//
//  Created by Stephen Bryant on 5/5/19.
//  Copyright © 2019 CodePlain. All rights reserved.
//
public func porthtons(port: in_port_t) -> in_port_t
{
  let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian
  return isLittleEndian ? _OSSwapInt16(port) : port
}
import Foundation

print("HolyQuest is starting...")

var MyListenSocket : Int32
var MyListenAddr : sockaddr_in! = sockaddr_in()
var port : in_port_t
port = 7777



MyListenAddr.sin_len = UInt8(MemoryLayout.size(ofValue: sockaddr_in.self))
MyListenAddr.sin_family = sa_family_t(AF_INET)
MyListenAddr.sin_addr.s_addr = inet_addr("127.0.0.1")
MyListenAddr.sin_port = porthtons(port: in_port_t(port))
MyListenAddr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)

MyListenSocket = Darwin.socket(AF_INET, Int32(SOCK_STREAM), 0)
print (type(of: MyListenSocket))

withUnsafePointer(to: &MyListenAddr)
{
  sockaddrInPtr in
  let sockaddrPtr = UnsafeRawPointer(sockaddrInPtr).assumingMemoryBound(to: sockaddr.self)
  Darwin.bind(MyListenSocket, sockaddrPtr, UInt32(MemoryLayout<sockaddr_in>.stride))
}
print("HolyQuest is Listening on Port 7777")

class EchoServer
{
  let bufferSize = 1024
  let port: Int
  var listenSocket: Socket? = nil
  var connected = [Int32: Socket]()
  var acceptNewConnection = true

  init(port: Int)
  {
    self.port = port
  }

  deinit
  {
    for socket in connected.values
    {
      socket.close()
    }
    listenSocket?.close()
  }

  func start() throws
  {
    let socket = try Socket.create()
    listenSocket = socket
    try socket.listen(on: port)
    print("Listening port: \(socket.listeningPort)")
    repeat
    {
      let connectedSocket = try socket.acceptClientConnection()
      print("Connection from: \(connectedSocket.remoteHostname)")
      newConnection(socket: connectedSocket)
    } while acceptNewConnection
  }

  func newConnection(socket: Socket)
  {
    connected[socket.socketfd] = socket
    var cont = true
    var dataRead = Data(capacity: bufferSize)
    repeat
    {
      do
      {
        let bytes = try socket.read(into: &dataRead)
        if bytes > 0
        {
          if let readStr = String(data: dataRead, encoding: .utf8)
          {
            print("Received: \(readStr)")
            try socket.write(from: readStr)
            if readStr.hasPrefix("quit")
            {
              cont = false
              socket.close()
            }
            dataRead.count = 0
          }
        }
      } catch let error {
        print("error: \(error)")
      }
    } while cont
    connected.removeValue(forKey: socket.socketfd)
    socket.close()
  }
}

//let server = EchoServer(port: 7777)
//do
//{
//  try server.start()
//} catch let error
//{
//  print("Error: \(error)")
//}
