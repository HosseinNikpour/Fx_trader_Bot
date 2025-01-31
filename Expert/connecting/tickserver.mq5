//+------------------------------------------------------------------+
//|                                                       TickServer |
//|                       programming & development - Alexey Sergeev |
//+------------------------------------------------------------------+
#property copyright "© 2006-2016 Alexey Sergeev"
#property link      "profy.mql@gmail.com"
#property version   "1.00"

#include "SocketLib.mqh"

input string Host="0.0.0.0";
input ushort Port=8082;

SOCKET64 server=INVALID_SOCKET64;

//------------------------------------------------------------------	OnInit
int OnInit() { EventSetMillisecondTimer(300); return 0; }
//------------------------------------------------------------------	OnDeinit
void OnDeinit(const int reason) { EventKillTimer(); CloseClean(); }
//------------------------------------------------------------------	OnTimer
void OnTimer()
  {
   if(server!=INVALID_SOCKET64)
     {
      char buf[1024]={0};
      ref_sockaddr ref={0}; int len=ArraySize(ref.ref);
      int res=recvfrom(server,buf,1024,0,ref.ref,len);
      if (res>=0) // receive and display data
         Print("receive tick from client: ", CharArrayToString(buf));
        else
        {
         int err=WSAGetLastError();
         if(err!=WSAEWOULDBLOCK) { Print("-receive failed error: "+WSAErrorDescript(err)+". Cleanup socket"); CloseClean(); return; }
        }

     }
   else // otherwise start the server
     {
      // initialize the library
      char wsaData[]; ArrayResize(wsaData,sizeof(WSAData));
      int res=WSAStartup(MAKEWORD(2,2), wsaData);
      if(res!=0) { Print("-WSAStartup failed error: "+string(res)); return; }

      // create a socket
      server=socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
      if(server==INVALID_SOCKET64) { Print("-Create failed error: "+WSAErrorDescript(WSAGetLastError())); CloseClean(); return; }

      // bind to address and port
      Print("try bind..."+Host+":"+string(Port));

      char ch[]; StringToCharArray(Host,ch);
      sockaddr_in addrin;
      addrin.sin_family=AF_INET;
      addrin.sin_addr.u.S_addr=inet_addr(ch);
      addrin.sin_port=htons(Port);
      ref_sockaddr ref; ref.in=addrin;
      if(bind(server,ref.ref,sizeof(addrin))==SOCKET_ERROR)
        {
         int err=WSAGetLastError();
         if(err!=WSAEISCONN) { Print("-Connect failed error: "+WSAErrorDescript(err)+". Cleanup socket"); CloseClean(); return; }
        }

      // set to nonblocking mode
      int non_block=1;
      res=ioctlsocket(server,(int)FIONBIO,non_block);
      if(res!=NO_ERROR) { Print("ioctlsocket failed error: "+string(res)); CloseClean(); return; }

      Print("start server ok");
     }
  }
//------------------------------------------------------------------	CloseClean
void CloseClean() // close and clear operation
  {
   printf("Shutdown server");
   if(server!=INVALID_SOCKET64) { closesocket(server); server=INVALID_SOCKET64; } // close the server
   WSACleanup();
  }
//+------------------------------------------------------------------+
