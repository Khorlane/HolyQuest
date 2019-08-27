// HolyQuest
// MySocket.h
// Socket stuff header
// Created by Steve Bryant on 05/09/2019.
// Copyright 2019 Steve Bryant. All rights reserved.

#ifndef Socket_h
#define Socket_h

int   AcceptNewConnection(void);
int   CheckClient(int SocketHandle1);
void  SocketSelect(int MaxSocketHandle);
void  DisconnectClient(int SocketHandle1);
char *GetBuffer(void);
int   IsNewConnection(void);
void  SocketServerInit(void);
int   SocketServerListen(int Port);
long  ReadClient(int SocketHandle1);
void  SendClient(int SocketHandle1);
void  SetBuffer(char * StringInp);
void  PrepForSelectMaster(void);
void  PrepForSelectPlayer(int SocketHandle);

#endif /* Socket_h */
