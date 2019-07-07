// HolyQuest
// MySocket.c
// Socket stuff code
// Created by Steve Bryant on 05/09/2019.
// Copyright 2019 Steve Bryant. All rights reserved.

// ChatServer includes
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
#define PORT            7777
#define COMMS_WAIT_SEC  0
#define COMMS_WAIT_USEC 1
#define DEBUGIT(x)      if (DEBUGIT_LVL >= x) {printf("*** ");printf(__FUNCTION__);printf(" ***\r\n");}
#define DEBUGIT_LVL     1

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

char    Buffer[1025];         //data buffer of 1K

struct  linger      Linger;
struct  sockaddr_in Socket;
struct  timeval     TimeOut;

fd_set  InpSet;               // set of socket descriptors

char * PassReturnString(char * StringInp)
{
  printf("String from inside PassReturnString: %s", StringInp);
  strcpy(Buffer, StringInp);
  Buffer[strlen(StringInp)] = '!';
  Buffer[strlen(StringInp)+1] = '\0';
  return Buffer;
}

char * GetBuffer(void)
{
  //strcpy(Buffer, "My Buffer");
  return Buffer;
}

void SetBuffer(char * StringInp)
{
  strcpy(Buffer, StringInp);
}

void ChatServerInit(void)
{
  DEBUGIT(1);
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
}

int ChatServerListen(void)
{
  DEBUGIT(1);
  //****************
  // Create socket *
  //****************
  ListenSocket = socket(AF_INET, SOCK_STREAM, 0);
  if (ListenSocket == 0)
  {
    perror("-- Create listening socket failed\r\n");
    exit(1);
  }
  //*******************
  // Set non-blocking *
  //*******************
  ReturnCode = fcntl(ListenSocket, F_SETFL, FNDELAY);
  if (ReturnCode < 0)
  {
    perror("-- Set non-blocking failed\r\n");
    exit(1);
  }
  //****************
  // Set SO_LINGER *
  //****************
  ReturnCode = setsockopt(ListenSocket, SOL_SOCKET, SO_LINGER, &Linger, LingerSize);
  if (ReturnCode < 0)
  {
    perror("-- Set SO_LINGER failed\r\n");
    exit(1);
  }
  //*******************
  // Set SO_REUSEADDR *
  //*******************
  ReturnCode = setsockopt(ListenSocket, SOL_SOCKET, SO_REUSEADDR, &OptVal, OptValSize);
  if (ReturnCode < 0)
  {
    perror("-- Set SO_REUSEADDR failed\r\n");
    exit(1);
  }
  //************************
  // Init socket structure *
  //************************
  Socket.sin_family      = AF_INET;
  Socket.sin_addr.s_addr = INADDR_ANY;
  Socket.sin_port        = htons(PORT);
  //*******
  // Bind *
  //*******
  BindResult = bind(ListenSocket, (struct sockaddr *) &Socket, SocketSize);
  if (BindResult < 0)
  {
    perror("-- Bind failed\r\n");
    exit(1);
  }
  //*********
  // Listen *
  //*********
  ListenResult = listen(ListenSocket, 20);
  if (ListenResult < 0)
  {
    perror("-- Listen failed\r\n");
    exit(1);
  }
  printf("Listener on port %d\r\n", PORT);
  return ListenSocket;
}

void SetUpSelect1(void)
{
  //**********************
  // Set up for select() *
  //**********************
  DEBUGIT(5);
  FD_ZERO(&InpSet);                               // Clear the socket set
  FD_SET(ListenSocket, &InpSet);                  // Add master socket to set
}

void SetUpSelect2(int SocketHandle)
{
  DEBUGIT(5);
  FD_SET(SocketHandle, &InpSet);
}

void CheckForSocketActivity(int MaxSocketHandle)
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

int IsNewConnection(void)
{
  DEBUGIT(5);
  if (FD_ISSET(ListenSocket, &InpSet))
  {
    return TRUE;
  }
  return FALSE;
}

int CheckClient(int SocketHandle1)
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

long ReadClient(int SocketHandle1)
{
  DEBUGIT(1);
  ReadByteCount = read(SocketHandle1, Buffer, 1024);
  Buffer[ReadByteCount] = '\0';   // Set the string terminating NULL byte on the end of the data read
  if (Buffer[0] == 'q')
    return 0;
  return ReadByteCount;
}

void DisconnectClient(int SocketHandle1)
{
  DEBUGIT(1);
  getpeername(SocketHandle1, (struct sockaddr *) &Socket, &SocketSize);
  printf("Client disconnected, ip %s, port %d\r\n", inet_ntoa(Socket.sin_addr), ntohs(Socket.sin_port));
  close(SocketHandle1);           // Close the socket
}

void SendClient(int SocketHandle1)
{
  DEBUGIT(1);
  BufferLen = strlen(Buffer);
  SendResult = send(SocketHandle1, Buffer, BufferLen, 0);
  if (SendResult != BufferLen)
  {
    perror("-- Send failed\r\n");
  }
}

int AcceptNewConnection(void)
{
  //****************************
  // Accept the new connection *
  //****************************
  DEBUGIT(1);
  SocketHandle2 = accept(ListenSocket, (struct sockaddr *) &Socket, (socklen_t *) &SocketSize);
  if (SocketHandle2 < 0)
  {
    perror("-- Accept failed\r\n");
    exit(1);
  }
  printf("New connection, socket fd is %d , ip is : %s , port : %d\r\n", SocketHandle2, inet_ntoa(Socket.sin_addr), ntohs(Socket.sin_port));
  return SocketHandle2;
}
