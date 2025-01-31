//+------------------------------------------------------------------+
//|                                                     SignalServer |
//|                       programming & development - Alexey Sergeev |
//+------------------------------------------------------------------+
#property copyright "© 2006-2016 Alexey Sergeev"
#property link      "profy.mql@gmail.com"
#property version   "1.00"

#include "SocketLib.mqh"

input string Host="0.0.0.0";
input ushort Port=8081;

bool bChangeTrades;
uchar data[];
SOCKET64 server=INVALID_SOCKET64;
SOCKET64 conns[];

//------------------------------------------------------------------	OnInit
int OnInit() { OnTrade(); EventSetTimer(1); return 0; }
//------------------------------------------------------------------	OnDeinit
void OnDeinit(const int reason) { EventKillTimer(); CloseClean(); }
//------------------------------------------------------------------	OnTrade
void OnTrade()
  {
   double lot=GetSymbolLot(Symbol());
   StringToCharArray("<<"+Symbol()+"|"+DoubleToString(lot,2)+">>",data); // convert the string to byte array
   bChangeTrades=true;
  }
//------------------------------------------------------------------	OnTimer
void OnTimer()
  {
   if(server==INVALID_SOCKET64) StartServer(Host,Port);
   else
     {
      AcceptClients(); // add pending clients
      if(bChangeTrades)
        {
         Print("send new posinfo to clients");
         Send(); bChangeTrades=false;
        }
     }
  }
//------------------------------------------------------------------	StartServer
void StartServer(string addr,ushort port)
  {
// initialize the library
   char wsaData[]; ArrayResize(wsaData,sizeof(WSAData));
   int res=WSAStartup(MAKEWORD(2,2), wsaData);
   if(res!=0) { Print("-WSAStartup failed error: "+string(res)); return; }

// create a socket
   server=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
   if(server==INVALID_SOCKET64) { Print("-Create failed error: "+WSAErrorDescript(WSAGetLastError())); CloseClean(); return; }

// bind to address and port
   Print("try bind..."+addr+":"+string(port));

   char ch[]; StringToCharArray(addr,ch);
   sockaddr_in addrin;
   addrin.sin_family=AF_INET;
   addrin.sin_addr.u.S_addr=inet_addr(ch);
   addrin.sin_port=htons(port);
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

// listen port and accept client connections
   if(listen(server,SOMAXCONN)==SOCKET_ERROR) { Print("Listen failed with error: ",WSAErrorDescript(WSAGetLastError())); CloseClean(); return; }

   Print("start server ok");
  }
//------------------------------------------------------------------	Accept
void AcceptClients() // Accept a client socket
  {
   if(server==INVALID_SOCKET64) return;

// add all pending clients
   SOCKET64 client=INVALID_SOCKET64;
   do
     {
      ref_sockaddr ch; int len=sizeof(ref_sockaddr);
      client=accept(server,ch.ref,len);
      if(client==INVALID_SOCKET64)
        {
         int err=WSAGetLastError();
         if(err==WSAEWOULDBLOCK) Comment("\nWAITING CLIENT ("+string(TimeCurrent())+")");
         else { Print("Accept failed with error: ",WSAErrorDescript(err)); CloseClean(); }
         return;
        }

      // set to nonblocking mode
      int non_block=1;
      int res=ioctlsocket(client, (int)FIONBIO, non_block);
      if(res!=NO_ERROR) { Print("ioctlsocket failed error: "+string(res)); continue; }

      // add client socket to the array
      int n=ArraySize(conns); ArrayResize(conns,n+1);
      conns[n]=client;
      bChangeTrades=true; // flag to indicate that information about the position must be sent

                          // show client information
      char ipstr[23]={0};
      ref_sockaddr_in aclient; aclient.in=ch.in; // convert into structure to get additional information about the connection
      inet_ntop(aclient.in.sin_family, aclient.ref, ipstr, sizeof(ipstr)); // get the address
      printf("Accept new client %s : %d",CharArrayToString(ipstr),ntohs(aclient.in.sin_port));
     }
   while(client!=INVALID_SOCKET64);
  }
//------------------------------------------------------------------	SendClient
void Send()
  {
   int len=ArraySize(data);
   for(int i=ArraySize(conns)-1; i>=0; --i) // send out the information to clients
     {
      if(conns[i]==INVALID_SOCKET64) continue; // skip closed
      int res=send(conns[i],data,len,0); // send
      if(res==SOCKET_ERROR) { Print("-Send failed error: "+WSAErrorDescript(WSAGetLastError())+". close socket"); Close(conns[i]); }
     }
  }
//------------------------------------------------------------------	CloseClean
void CloseClean() // close and clear operation
  {
   printf("Shutdown server and %d connections",ArraySize(conns));
   if(server!=INVALID_SOCKET64) { closesocket(server); server=INVALID_SOCKET64; } // close the server
   for(int i=ArraySize(conns)-1; i>=0; --i) Close(conns[i]); // close the clients
   ArrayResize(conns,0);
   WSACleanup();
  }
//------------------------------------------------------------------	Close
void Close(SOCKET64 &asock) // close one socket
  {
   if(asock==INVALID_SOCKET64) return;
   if(shutdown(asock,SD_BOTH)==SOCKET_ERROR) Print("-Shutdown failed error: "+WSAErrorDescript(WSAGetLastError()));
   closesocket(asock);
   asock=INVALID_SOCKET64;
  }
//------------------------------------------------------------------	GetSymbolLot
double GetSymbolLot(string smb)
  {
   double slot=0;
   int n=PositionsTotal();
   for(int i=0; i<n;++i)
     {
      PositionSelectByTicket(PositionGetTicket(i));
      if(PositionGetString(POSITION_SYMBOL)!=smb) continue; // filter the position of the current symbol, where the server is running
      double lot=PositionGetDouble(POSITION_VOLUME); // get the volume
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) lot=-lot; // consider the direction
      slot+=lot; // add to the sum
     }
   return slot;
  }
//+------------------------------------------------------------------+
