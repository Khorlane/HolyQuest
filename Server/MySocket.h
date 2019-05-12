//
//  MySocket.h
//  HolyQuest
//
//  Created by Stephen Bryant on 5/9/19.
//  Copyright © 2019 CodePlain. All rights reserved.
//

#ifndef MySocket_h
#define MySocket_h

int Initialize(void);
int ChatServer(void);
int PutMessage(void);

char * ReturnBuffer(void);
char * PassReturnString(char * StringInp);

#endif /* MySocket_h */
