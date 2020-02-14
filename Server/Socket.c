// HolyQuest
// MySocket.c
// Sockets
// Created by Steve Bryant on 05/09/2019.
// Copyright 2019 CodePlain. All rights reserved.

// Mud Server includes
#include <fcntl.h>
#include <stdio.h>        // perror printf
#include <stdlib.h>       // exit
#include <string.h>       // strlen
#include <errno.h>        // errno EINTR
#include <unistd.h>       // read close
#include <sys/socket.h>   // All things Socket
#include <netinet/in.h>   // sockaddr_in
#include <arpa/inet.h>    // inet_ntoa
#include <sys/time.h>     // select

#include "Socket.h"

#define TRUE            1
#define FALSE           0
#define COMMS_WAIT_SEC  0
#define COMMS_WAIT_USEC 1
#define DEBUGIT(x)      if (DEBUGIT_LVL >= x) {printf("*** ");printf(__FUNCTION__);printf(" ***\r\n");}
#define DEBUGIT_LVL     1
#define MSG_NOSIGNAL    0x2000 /* don't raise SIGPIPE */

int       BindResult;
size_t    BufferLen;
int       i;
int       j;
int       LingerSize;
int       ListenResult;
int       ListenSocket;
int       MaxClients;
int       MaxSocketHandle;
int       OptVal;
int       OptValSize;
long      ReadByteCount;
int       ReturnCode;
long      SendResult;
int       SocketCount;
int       SocketHandle1;
int       SocketHandle2;
socklen_t SocketSize;

char    Buffer[2048];

struct  linger      Linger;
struct  sockaddr_in Socket;
struct  timeval     TimeOut;

fd_set  InpSet;

char * GetBuffer(void)                        // BigDog.swift
{
  return Buffer;
}

void SetBuffer(char * StringInp)              // BigDog.swift
{
  strcpy(Buffer, StringInp);
}

void SocketServerInit(void)                   // Utility.swift
{
  DEBUGIT(5);
  i               = 0;
  j               = 0;
  Linger.l_onoff  = 0;
  Linger.l_linger = 0;
  LingerSize      = sizeof(Linger);
  OptVal          = TRUE;
  OptValSize      = sizeof(OptVal);
  MaxClients      = 30;
  TimeOut.tv_sec  = COMMS_WAIT_SEC;
  TimeOut.tv_usec = COMMS_WAIT_USEC;
  SocketSize      = sizeof(Socket);
  signal(SIGPIPE, SIG_IGN);
}

int SocketServerListen(int Port)              // BigDog.swift
{
  //**************************
  // Establish master socket *
  //**************************
  DEBUGIT(5);
  //****************
  // Create socket *
  //****************
  ListenSocket = socket(AF_INET, SOCK_STREAM, 0);
  if (ListenSocket == 0)
  {
    perror("-- Create listening socket failed\r\n");
    exit(EXIT_FAILURE);
  }
  //*******************
  // Set non-blocking *
  //*******************
  ReturnCode = fcntl(ListenSocket, F_SETFL, FNDELAY);
  if (ReturnCode < 0)
  {
    perror("-- Set non-blocking failed\r\n");
    exit(EXIT_FAILURE);
  }
  //****************
  // Set SO_LINGER *
  //****************
  ReturnCode = setsockopt(ListenSocket, SOL_SOCKET, SO_LINGER, &Linger, LingerSize);
  if (ReturnCode < 0)
  {
    perror("-- Set SO_LINGER failed\r\n");
    exit(EXIT_FAILURE);
  }
  //*******************
  // Set SO_REUSEADDR *
  //*******************
  ReturnCode = setsockopt(ListenSocket, SOL_SOCKET, SO_REUSEADDR, &OptVal, OptValSize);
  if (ReturnCode < 0)
  {
    perror("-- Set SO_REUSEADDR failed\r\n");
    exit(EXIT_FAILURE);
  }
  //************************
  // Init socket structure *
  //************************
  Socket.sin_family      = AF_INET;
  Socket.sin_addr.s_addr = INADDR_ANY;
  Socket.sin_port        = htons(Port);
  //*******
  // Bind *
  //*******
  BindResult = bind(ListenSocket, (struct sockaddr *) &Socket, SocketSize);
  if (BindResult < 0)
  {
    perror("-- Bind failed\r\n");
    exit(EXIT_FAILURE);
  }
  //*********
  // Listen *
  //*********
  ListenResult = listen(ListenSocket, 20);
  if (ListenResult < 0)
  {
    perror("-- Listen failed\r\n");
    exit(EXIT_FAILURE);
  }
  return ListenSocket;
}

void PrepForSelectMaster(void)                // BigDog.swift
{
  //*********************************
  // Add master socket to input set *
  //*********************************
  DEBUGIT(5);
  FD_ZERO(&InpSet); // Clear the socket set
  FD_SET(ListenSocket, &InpSet);
}

void PrepForSelectPlayer(int SocketHandle)    // BigDog.swift
{
  //**********************************
  // Add player sockets to input set *
  //**********************************
  DEBUGIT(5);
  FD_SET(SocketHandle, &InpSet);
}

void SocketSelect(int MaxSocketHandle)        // BigDog.swift
{
  //************************************
  // Check for activity using select() *
  //************************************
  DEBUGIT(5);
  SocketCount = select(MaxSocketHandle + 1, &InpSet, NULL, NULL, &TimeOut);
  if ((SocketCount < 0) && (errno != EINTR))
  {
    printf("-- Select error\r\n");
  }
}

int IsNewConnection(void)                     // BigDog.swift
{
  //****************************
  // Check for new connections *
  //****************************
  DEBUGIT(5);
  if (FD_ISSET(ListenSocket, &InpSet))
  {
    return TRUE;
  }
  return FALSE;
}

int AcceptNewConnection(void)                 // BigDog.swift
{
  //****************************
  // Accept the new connection *
  //****************************
  DEBUGIT(5);
  SocketHandle2 = accept(ListenSocket, (struct sockaddr *) &Socket, (socklen_t *) &SocketSize);
  if (SocketHandle2 < 0)
  {
    perror("-- Accept failed\r\n");
    exit(EXIT_FAILURE);
  }
  printf("New connection, socket fd is %d , ip is : %s , port : %d\r\n", SocketHandle2, inet_ntoa(Socket.sin_addr), ntohs(Socket.sin_port));
  return SocketHandle2;
}

int CheckClient(int SocketHandle1)            // BigDog.swift
{
  //******************************************
  // Check for activity on other connections *
  //******************************************
  DEBUGIT(5);
  if (FD_ISSET(SocketHandle1, &InpSet))
  {
    return TRUE;
  }
  return FALSE;
}

long ReadClient(int SocketHandle1)            // BigDog.swift
{
  //*************************
  // Read input into Buffer *
  //*************************
  DEBUGIT(5);
  ReadByteCount = read(SocketHandle1, Buffer, 1024);
  Buffer[ReadByteCount] = '\0';   // Set the string terminating NULL byte on the end of the data read
  return ReadByteCount;
}

void SendClient(int SocketHandle1)            // BigDog.swift
{
  //**************************
  // Send output from Buffer *
  //**************************
  DEBUGIT(5);
  BufferLen = strlen(Buffer);
  SendResult = send(SocketHandle1, Buffer, BufferLen, 0);
  if (SendResult != BufferLen)
  {
    strcpy(Buffer,"quit\0");
    perror("-- Send failed\r\n");
  }
  else
  {
    Buffer[0] = '\0';
  }
}

void DisconnectClient(int SocketHandle1)      // Command.swift
{
  //******************************
  // Disconnect and close socket *
  //******************************
  DEBUGIT(5);
  getpeername(SocketHandle1, (struct sockaddr *) &Socket, &SocketSize);
  printf("Client disconnected, ip %s, port %d\r\n", inet_ntoa(Socket.sin_addr), ntohs(Socket.sin_port));
  close(SocketHandle1);
}
