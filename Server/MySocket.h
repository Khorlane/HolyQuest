// HolyQuest
// MySocket.h
// Socket stuff header
// Created by Steve Bryant on 05/09/2019.
// Copyright © 2019 Steve Bryant. All rights reserved.

#ifndef MySocket_h
#define MySocket_h

void ChatServerInit(void);
void ChatServerListen(void);
void ChatServerLooper(void);

void Initialize(void);
void PutMessage(void);

char * ReturnBuffer(void);
char * PassReturnString(char * StringInp);

#endif /* MySocket_h */
