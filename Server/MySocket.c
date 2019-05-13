//
//  MySocket.c
//  HolyQuest
//
//  Created by Stephen Bryant on 5/9/19.
//  Copyright © 2019 CodePlain. All rights reserved.
//

// ChatServer includes
#include <fcntl.h>
#include <stdio.h>        // perror puts printf
#include <stdlib.h>       // exit EXIT_FAILURE
#include <string.h>       // strlen
#include <errno.h>        // errno EINTR
#include <unistd.h>       // read close
#include <sys/socket.h>   // All things Socket
#include <netinet/in.h>   // sockaddr_in
#include <arpa/inet.h>    // inet_ntoa
#include <sys/time.h>     // select

#include "MySocket.h"

#define TRUE  1
#define FALSE 0
#define PORT  7777
#define COMMS_WAIT_SEC  5
#define COMMS_WAIT_USEC 500000

int     activity;
int     addrlen;
int     i;
int     j;
int     master_socket;
int     max_clients;
int     max_sd;
char *  message;
int     new_socket;
int     opt;
int     ReturnCode;
int     sd;
int     valread;

char    buffer[1025];       //data buffer of 1K
int     client_socket[30];

struct  linger      ld;
struct  sockaddr_in address;
struct  timeval     timeoutx;

fd_set  readfds;            // set of socket descriptors

char * ReturnBuffer(void)
{
  strcpy(buffer, "My Buffer");
  return buffer;
}

char * PassReturnString(char * StringInp)
{
  printf("String from inside PassReturnString: %s", StringInp);
  strcpy(buffer, StringInp);
  buffer[strlen(StringInp)] = '!';
  buffer[strlen(StringInp)+1] = '\0';
  return buffer;
}

void PutMessage(void)
{
  printf("%s\r\n", message);
  return;
}

void ChatServerInit(void)
{
  i = 0;
  j = 0;
  message     = "ECHO Daemon v1.0 \r\n";
  max_clients = 30;
  opt         = TRUE;
  for (i = 0; i < max_clients; i++)   // initialise all client_socket[] to 0 so not checked
  {
    client_socket[i] = 0;
  }
  ld.l_onoff  = 0;
  ld.l_linger = 0;
  timeoutx.tv_sec  = COMMS_WAIT_SEC;
  timeoutx.tv_usec = COMMS_WAIT_USEC;
  return;
}

void ChatServerListen(void)
{
  // Example code: A simple server side code, which echos back the received message.
  // Handle multiple socket connections with select and fd_set on Linux

  // create a master socket
  if ((master_socket = socket(AF_INET, SOCK_STREAM, 0)) == 0)
  {
    perror("socket failed");
    exit(EXIT_FAILURE);
  }

  // Set master socket to non-blocking
  ReturnCode = fcntl(master_socket, F_SETFL, FNDELAY);
  if (ReturnCode < 0)
  {
    perror("Set non-blocking");
    exit(EXIT_FAILURE);
  }

  // Don't allow closed sockets to hang around
  ReturnCode = setsockopt(master_socket, SOL_SOCKET, SO_LINGER, (char *) &ld, sizeof(ld));

  if (ReturnCode < 0)
  {
    perror("Set SO_LINGER");
    exit(EXIT_FAILURE);
  }

  // Set master socket to allow multiple connections, this is just a good habit, it will work without this
  if (setsockopt(master_socket, SOL_SOCKET, SO_REUSEADDR, (char *) &opt, sizeof(opt)) < 0 )
  {
    perror("setsockopt");
    exit(EXIT_FAILURE);
  }

  // type of socket created
  address.sin_family      = AF_INET;
  address.sin_addr.s_addr = INADDR_ANY;
  address.sin_port        = htons(PORT);

  // bind the socket to localhost port 7777
  if (bind(master_socket, (struct sockaddr *) &address, sizeof(address)) < 0)
  {
    perror("bind failed");
    exit(EXIT_FAILURE);
  }
  printf("Listener on port %d \n", PORT);

  // try to specify maximum of 3 pending connections for the master socket
  if (listen(master_socket, 3) < 0)
  {
    perror("listen");
    exit(EXIT_FAILURE);
  }

  // Accept the incoming connection
  addrlen = sizeof(address);
  puts("Waiting for connections ...");

  return;
}

void ChatServerLooper(void)
{
  while(TRUE)
  {
    // Clear the socket set
    FD_ZERO(&readfds);

    // Add master socket to set
    FD_SET(master_socket, &readfds);
    max_sd = master_socket;

    // Add child sockets to set
    for (i = 0; i < max_clients; i++)
    {
      // socket descriptor
      sd = client_socket[i];

      // If valid socket descriptor then add to read list
      if(sd > 0)
        FD_SET(sd, &readfds);

      // highest file descriptor number, need it for the select function
      if(sd > max_sd)
        max_sd = sd;
    }

    // Wait for an activity on one of the sockets, timeout is NULL, so wait indefinitely
    j++;
    printf("\r\n");
    printf("Before Select %i\r\n", j);
    activity = select(max_sd + 1, &readfds, NULL, NULL, &timeoutx);
    printf("After Select %i\r\n", j);

    if ((activity < 0) && (errno != EINTR))
    {
      printf("select error");
    }

    // If something happened on the master socket, then its an incoming connection
    if (FD_ISSET(master_socket, &readfds))
    {
      if ((new_socket = accept(master_socket, (struct sockaddr *) &address, (socklen_t *) &addrlen)) < 0)
      {
        perror("accept");
        exit(EXIT_FAILURE);
      }

      // Inform user of socket number - used in send and receive commands
      printf("New connection, socket fd is %d , ip is : %s , port : %d\n", new_socket, inet_ntoa(address.sin_addr), ntohs(address.sin_port));

      // Send new connection greeting message
      if(send(new_socket, message, strlen(message), 0) != strlen(message))
      {
        perror("send");
      }
      puts("Welcome message sent successfully");

      // add new socket to array of sockets
      for (i = 0; i < max_clients; i++)
      {
        // if position is empty
        if (client_socket[i] == 0)
        {
          client_socket[i] = new_socket;
          printf("Adding to list of sockets as %d\n", i);
          break;
        }
      }
    }

    // Else its some IO operation on some other socket
    for (i = 0; i < max_clients; i++)
    {
      sd = client_socket[i];

      if (FD_ISSET(sd, &readfds))
      {
        // Check if it was for closing , and also read the incoming message
        if ((valread = (int)read(sd, buffer, 1024)) == 0)
        {
          // Somebody disconnected, get his details and print
          getpeername(sd, (struct sockaddr *) &address, (socklen_t * ) &addrlen);
          printf("Host disconnected, ip %s, port %d \n", inet_ntoa(address.sin_addr), ntohs(address.sin_port));

          // Close the socket and mark as 0 in list for reuse
          close(sd);
          client_socket[i] = 0;
        }

        // Echo back the message that came in
        else
        {
          // set the string terminating NULL byte on the end of the data read
          buffer[valread] = '\0';
          if (buffer[0] == 'q')
            return;
          send(sd, buffer, strlen(buffer), 0 );
        }
      }
    }
  }
  return;
}
