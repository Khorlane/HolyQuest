// HolyQuest
// MySocket.c
// Socket stuff code
// Created by Steve Bryant on 05/09/2019.
// Copyright © 2019 Steve Bryant. All rights reserved.

// ChatServer includes
#include <fcntl.h>
#include <stdio.h>        // perror printf
#include <stdlib.h>       // exit EXIT_FAILURE
#include <string.h>       // strlen
#include <errno.h>        // errno EINTR
#include <unistd.h>       // read close
#include <sys/socket.h>   // All things Socket
#include <netinet/in.h>   // sockaddr_in
#include <arpa/inet.h>    // inet_ntoa
#include <sys/time.h>     // select

#include "Socket.h"

#define TRUE  1
#define FALSE 0
#define PORT  7777
#define COMMS_WAIT_SEC  0
#define COMMS_WAIT_USEC 1

int       BindResult;
size_t    BufferLen;
int       i;
int       j;
int       LingerSize;
int       ListenResult;
int       ListenSocket;
int       MaxClients;
int       MaxSocketHandle;
char *    Message;
long      MessageLen;
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
int     ClientSocketList[30];

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

void PutMessage(void)
{
  printf("%s\r\n", Message);
  return;
}

char * ReturnBuffer(void)
{
  strcpy(Buffer, "My Buffer");
  return Buffer;
}

void ChatServerInit(void)
{
  i               = 0;
  j               = 0;
  Linger.l_onoff  = 0;
  Linger.l_linger = 0;
  LingerSize      = sizeof(Linger);
  OptVal          = TRUE;
  OptValSize      = sizeof(OptVal);
  MaxClients      = 30;
  Message         = "ECHO Daemon v1.0 \r\n";
  TimeOut.tv_sec  = COMMS_WAIT_SEC;
  TimeOut.tv_usec = COMMS_WAIT_USEC;
  SocketSize      = sizeof(Socket);
  for (i = 0; i < MaxClients; i++)   // Initialise all ClientSocketList[] to 0
  {
    ClientSocketList[i] = 0;
  }
}

void ChatServerListen(void)
{
  //****************
  // Create socket *
  //****************
  ListenSocket = socket(AF_INET, SOCK_STREAM, 0);
  if (ListenSocket == 0)
  {
    perror("Create listening socket failed");
    exit(EXIT_FAILURE);
  }
  //*******************
  // Set non-blocking *
  //*******************
  ReturnCode = fcntl(ListenSocket, F_SETFL, FNDELAY);
  if (ReturnCode < 0)
  {
    perror("Set non-blocking failed");
    exit(EXIT_FAILURE);
  }
  //****************
  // Set SO_LINGER *
  //****************
  ReturnCode = setsockopt(ListenSocket, SOL_SOCKET, SO_LINGER, &Linger, LingerSize);
  if (ReturnCode < 0)
  {
    perror("Set SO_LINGER failed");
    exit(EXIT_FAILURE);
  }
  //*******************
  // Set SO_REUSEADDR *
  //*******************
  ReturnCode = setsockopt(ListenSocket, SOL_SOCKET, SO_REUSEADDR, &OptVal, OptValSize);
  if (ReturnCode < 0)
  {
    perror("Set SO_REUSEADDR failed");
    exit(EXIT_FAILURE);
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
    perror("Bind failed");
    exit(EXIT_FAILURE);
  }
  //*********
  // Listen *
  //*********
  ListenResult = listen(ListenSocket, 20);
  if (ListenResult < 0)
  {
    perror("listen");
    exit(EXIT_FAILURE);
  }
  printf("Listener on port %d\r\n", PORT);
}

int ChatServerLooper(void)
{
  //**********************
  // Set up for select() *
  //**********************
  FD_ZERO(&InpSet);                               // Clear the socket set
  FD_SET(ListenSocket, &InpSet);                  // Add master socket to set
  MaxSocketHandle = ListenSocket;                 // Figure
  for (i = 0; i < MaxClients; i++)                //  out
  {                                               //   max socket handle
    SocketHandle1 = ClientSocketList[i];          //    and
    if (SocketHandle1 > 0)                        //     add
      FD_SET(SocketHandle1, &InpSet);             //      acitve
    if (SocketHandle1 > MaxSocketHandle)          //       clients
      MaxSocketHandle = SocketHandle1;            //        to InpSet
  }
  //************************************
  // Check for activity using select() *
  //************************************
  j++;
  printf("\r\n");
  printf("Before Select %i\r\n", j);
  SocketCount = select(MaxSocketHandle + 1, &InpSet, NULL, NULL, &TimeOut);
  printf("After Select %i\r\n", j);
  if ((SocketCount < 0) && (errno != EINTR))
  {
    printf("select error");
  }
  if (FD_ISSET(ListenSocket, &InpSet))
  {
    AcceptNewConnection();
  }
  //******************************************
  // Check for activity on other connections *
  //******************************************
  for (i = 0; i < MaxClients; i++)
  {
    SocketHandle1 = ClientSocketList[i];
    if (FD_ISSET(SocketHandle1, &InpSet))
    {
      ReadByteCount = read(SocketHandle1, Buffer, 1024);
      if (ReadByteCount == 0)           // Somebody disconnected, get his details and print
      {
        getpeername(SocketHandle1, (struct sockaddr *) &Socket, &SocketSize);
        printf("Client disconnected, ip %s, port %d\r\n", inet_ntoa(Socket.sin_addr), ntohs(Socket.sin_port));
        close(SocketHandle1);           // Close the socket
        ClientSocketList[i] = 0;        // Mark as 0 in list for reuse
      }
      else  // Echo back the message that came in
      {
        Buffer[ReadByteCount] = '\0';   // Set the string terminating NULL byte on the end of the data read
        if (Buffer[0] == 'q')
          return 0;
        BufferLen = strlen(Buffer);
        send(SocketHandle1, Buffer, BufferLen, 0);
      }
    }
  }
  return 1;
}

void AcceptNewConnection(void)
{
  //****************************
  // Accept the new connection *
  //****************************
  SocketHandle2 = accept(ListenSocket, (struct sockaddr *) &Socket, (socklen_t *) &SocketSize);
  if (SocketHandle2 < 0)
  {
    perror("Accept failed");
    exit(EXIT_FAILURE);
  }
  //***********************
  // Send welcome message *
  //***********************
  printf("New connection, socket fd is %d , ip is : %s , port : %d\r\n", SocketHandle2, inet_ntoa(Socket.sin_addr), ntohs(Socket.sin_port));
  MessageLen = strlen(Message);
  SendResult = send(SocketHandle2, Message, MessageLen, 0);
  if (SendResult != MessageLen)
  {
    perror("Send failed");
  }
  printf("Welcome message sent successfully\r\n");
  //************************************
  // Add new client to list of clients *
  //************************************
  for (i = 0; i < MaxClients; i++)
  {
    if (ClientSocketList[i] == 0)
    {
      ClientSocketList[i] = SocketHandle2;
      printf("Adding to list of sockets as %d\r\n", i);
      break;
    }
  }
}
