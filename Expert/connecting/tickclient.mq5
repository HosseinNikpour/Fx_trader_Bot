//+------------------------------------------------------------------+
//|                                                       TickClient |
//|                       programming & development - Alexey Sergeev |
//+------------------------------------------------------------------+
#property copyright "© 2006-2016 Alexey Sergeev"
#property link      "profy.mql@gmail.com"
#property version   "1.00"

#include "SocketLib.mqh"

input string Host="127.0.0.1";
input ushort Port=8082;

SOCKET64 client=INVALID_SOCKET64; // client socket
ref_sockaddr srvaddr={0};
//------------------------------------------------------------------	OnInit
int OnInit()
  {
// fill the structure for the server address
   char ch[]; StringToCharArray(Host,ch);
   sockaddr_in addrin;
   addrin.sin_family=AF_INET;
   addrin.sin_addr.u.S_addr=inet_addr(ch);
   addrin.sin_port=htons(Port);
   srvaddr.in=addrin;

   OnTick();

   return INIT_SUCCEEDED;
  }
//------------------------------------------------------------------	OnDeinit
void OnDeinit(const int reason) { CloseClean(); }
//------------------------------------------------------------------	OnTick
void OnTick()
  {
   if(client!=INVALID_SOCKET64) // if the socket is already created, send
     {
      uchar data[]; StringToCharArray(Symbol()+" "+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_BID),Digits()),data);
      if(sendto(client,data,ArraySize(data),0,srvaddr.ref,ArraySize(srvaddr.ref))==SOCKET_ERROR)
        {
         int err=WSAGetLastError();
         if(err!=WSAEWOULDBLOCK) { Print("-Send failed error: "+WSAErrorDescript(err)); CloseClean(); }
        }
      else
         Print("send "+Symbol()+" tick to server");
     }
   else // create a client socket
     {
      int res=0;
      char wsaData[]; ArrayResize(wsaData,sizeof(WSAData));
      res=WSAStartup(MAKEWORD(2,2),wsaData);
      if(res!=0) { Print("-WSAStartup failed error: "+string(res)); return; }

      // create socket
      client=socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
      if(client==INVALID_SOCKET64) { Print("-Create failed error: "+WSAErrorDescript(WSAGetLastError())); CloseClean(); return; }

      // set to nonblocking mode
      int non_block=1;
      res=ioctlsocket(client,(int)FIONBIO,non_block);
      if(res!=NO_ERROR) { Print("ioctlsocket failed error: "+string(res)); CloseClean(); return; }

      Print("create socket OK");
     }
  }
//------------------------------------------------------------------	CloseClean
void CloseClean() // close socket
  {
   if(client!=INVALID_SOCKET64)
     {
      if(shutdown(client,SD_BOTH)==SOCKET_ERROR) Print("-Shutdown failed error: "+WSAErrorDescript(WSAGetLastError()));
      closesocket(client); client=INVALID_SOCKET64;
     }

   WSACleanup();
   Print("close socket");
  }
//+------------------------------------------------------------------+
