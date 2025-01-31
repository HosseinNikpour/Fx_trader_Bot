//+------------------------------------------------------------------+
//|                                                     SignalClient |
//|                       programming & development - Alexey Sergeev |
//+------------------------------------------------------------------+
#property copyright "© 2006-2016 Alexey Sergeev"
#property link      "profy.mql@gmail.com"
#property version   "1.00"

#include "SocketLib.mqh"
#include <Trade\Trade.mqh>

input string Host="127.0.0.1";
input ushort Port=8081;

SOCKET client=INVALID_SOCKET64; // client socket
string msg=""; // queue of received messages
//------------------------------------------------------------------	OnInit
int OnInit()
  {
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Alert("Client work only with Netting accounts"); return INIT_FAILED;
     }

   EventSetTimer(1); return INIT_SUCCEEDED;
  }
//------------------------------------------------------------------	OnInit
void OnDeinit(const int reason) { EventKillTimer(); CloseClean(); }
//------------------------------------------------------------------	OnInit
void OnTimer()
  {
   if(client==INVALID_SOCKET64) StartClient(Host,Port);
   else
     {
      uchar data[];
      if(Receive(data)>0) // receive data
        {
         msg+=CharArrayToString(data); // if something was received, add it to the total string
         printf("received msg from server: %s",msg);
        }
      CheckMessage();
     }
  }
//------------------------------------------------------------------	CloseClean
void StartClient(string addr,ushort port)
  {
// initialize the library
   int res=0;
   char wsaData[]; ArrayResize(wsaData, sizeof(WSAData));
   res=WSAStartup(MAKEWORD(2,2), wsaData);
   if (res!=0) { Print("-WSAStartup failed error: "+string(res)); return; }

// create a socket
   client=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
   if(client==INVALID_SOCKET64) { Print("-Create failed error: "+WSAErrorDescript(WSAGetLastError())); CloseClean(); return; }

// connect to server
   char ch[]; StringToCharArray(addr,ch);
   sockaddr_in addrin;
   addrin.sin_family=AF_INET;
   addrin.sin_addr.u.S_addr=inet_addr(ch);
   addrin.sin_port=htons(port);

   ref_sockaddr ref; ref.in=addrin;
   res=connect(client,ref.ref,sizeof(addrin));
   if(res==SOCKET_ERROR)
     {
      int err=WSAGetLastError();
      if(err!=WSAEISCONN) { Print("-Connect failed error: "+WSAErrorDescript(err)); CloseClean(); return; }
     }

// set to nonblocking mode
   int non_block=1;
   res=ioctlsocket(client,(int)FIONBIO,non_block);
   if(res!=NO_ERROR) { Print("ioctlsocket failed error: "+string(res)); CloseClean(); return; }

   Print("connect OK");
  }
//------------------------------------------------------------------	Receive
int Receive(uchar &rdata[]) // Receive until the peer closes the connection
  {
   if(client==INVALID_SOCKET64) return 0; // if the socket is still not open

   char rbuf[512]; int rlen=512; int r=0,res=0;
   do
     {
      res=recv(client,rbuf,rlen,0);
      if(res<0)
        {
         int err=WSAGetLastError();
         if(err!=WSAEWOULDBLOCK) { Print("-Receive failed error: "+string(err)+" "+WSAErrorDescript(err)); CloseClean(); return -1; }
         break;
        }
      if(res==0 && r==0) { Print("-Receive. connection closed"); CloseClean(); return -1; }
      r+=res; ArrayCopy(rdata,rbuf,ArraySize(rdata),0,res);
     }
   while(res>0 && res>=rlen);
   return r;
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
//------------------------------------------------------------------	CheckMessage
void CheckMessage()
  {
   string pos;
   while(FindNextPos(pos)) { printf("server position: %s",pos); };  // get the most recent change from the server
   if(StringLen(pos)<=0) return;
// receive data from the message
   string res[]; if(StringSplit(pos,'|',res)!=2) { printf("-wrong pos info: %s",pos); return; }
   string smb=res[0]; double lot=NormalizeDouble(StringToDouble(res[1]),2);

// synchronize volume
   if(!SyncSymbolLot(smb,lot)) msg="<<"+pos+">>"+msg; // if there is an error, return the message to the beginning of the "thread"
  }
//------------------------------------------------------------------	SyncSymbolLot
bool SyncSymbolLot(string smb,double nlot)
  {
// synchronize the server and client volumes
   CTrade trade;
   double clot=GetSymbolLot(smb); // get the current lot for the symbol
   if(clot==nlot) { Print("nothing change"); return true; } // if the volumes are equal, do nothing

                                                            // first, check the special case of no positions present on the server
   if(nlot==0 && clot!=0) { Print("full close position"); return trade.PositionClose(smb); }

// if the server has a position, change it on the client
   double dif=NormalizeDouble(nlot-clot,2);
// buy or sell depending on the difference
   if(dif>0) { Print("add Buy position"); return trade.Buy(dif,smb); }
   else { Print("add Sell position"); return trade.Sell(-dif,smb); }
  }
//------------------------------------------------------------------	FindNextPos
bool FindNextPos(string &pos)
  {
   int b=StringFind(msg, "<<"); if(b<0) return false; // no beginning of the message
   int e=StringFind(msg, ">>"); if(e<0) return false; // no end of the message

   pos=StringSubstr(msg,b+2,e-b-2); // get the information block
   msg=StringSubstr(msg,e+2); // remove it from the message
   return true;
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
   return NormalizeDouble(slot,2);
  }
//+------------------------------------------------------------------+
