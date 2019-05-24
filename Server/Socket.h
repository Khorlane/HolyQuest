// HolyQuest
// MySocket.h
// Socket stuff header
// Created by Steve Bryant on 05/09/2019.
// Copyright 2019 Steve Bryant. All rights reserved.

#ifndef Socket_h
#define Socket_h

void ChatServerInit(void);
int  ChatServerListen(void);
int  ChatServerLooper(void);
int  AcceptNewConnection(void);
void SetUpSelect1(void);
void SetUpSelect2(int SocketHandle);
void CheckForSocketActivity(int MaxSocketHandle);
int  IsNewConnection(void);
int  CheckClient(int SocketHandle1);
long ReadClient(int SocketHandle1);
void SendClient(int SocketHandle1);
void DisconnectClient(int SocketHandle1);

void Initialize(void);
void PutMessage(void);

char * GetBuffer(void);
void SetBuffer(char * StringInp);
char * PassReturnString(char * StringInp);

#endif /* Socket_h */
