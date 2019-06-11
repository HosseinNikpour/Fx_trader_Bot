//+------------------------------------------------------------------+
//|                                                      testapi.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <JAson.mqh>
int OnInit()
  {
   call();
//--- create timer
   EventSetTimer(10);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
void call()
  {
  string strOut;
   CJAVal js(NULL,jtUNDEF); bool b;
  
   string cookie=NULL,headers;
   char   post[],result[];

   string url="http://127.0.0.1/url2";
   ResetLastError();
   int res=WebRequest("GET",url,cookie,NULL,500,post,0,result,headers);
   if(res==-1)
      Print("Error in WebRequest. Error code  =",GetLastError());
   else
     {
      if(res==200)
        {
        string resultString = CharArrayToString(result);
        
            strOut="";
            b=js.Deserialize(result);
            js.Serialize(strOut);
            printf(js["names"][0].ToStr());
        }
     }
  }
//+------------------------------------------------------------------+
