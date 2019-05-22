// HolyQuest
// MySocket.h
// Socket stuff header
// Created by Steve Bryant on 05/09/2019.
// Copyright © 2019 Steve Bryant. All rights reserved.

#ifndef Socket_h
#define Socket_h

void ChatServerInit(void);
void ChatServerListen(void);
int  ChatServerLooper(void);
void AcceptNewConnection(void);

int  GetListenSocket(void);

void Initialize(void);
void PutMessage(void);

char * ReturnBuffer(void);
char * PassReturnString(char * StringInp);

#endif /* Socket_h */
