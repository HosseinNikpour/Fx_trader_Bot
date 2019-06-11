//+------------------------------------------------------------------+
//|                                                        Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES timeFrame=PERIOD_H4;
input double volume=0.05;
int OnInit()
  {
  HN();
//printf(getTimeFrameSecond(timeFrame));
//--- create timer
   EventSetTimer(getTimeFrameSecond(timeFrame));
   
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
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+


void OnTimer()
  {
//---
   HN();
  }
//+------------------------------------------------------------------+
void HN(){
   double price_EURUSD = SymbolInfoDouble("EURUSD", SYMBOL_ASK);
   double price_USDJPY = SymbolInfoDouble("USDJPY", SYMBOL_ASK);
   double price_GBPUSD = SymbolInfoDouble("GBPUSD", SYMBOL_ASK);
   double price_USDCAD = SymbolInfoDouble("USDCAD", SYMBOL_ASK);
   double price_USDAUD = SymbolInfoDouble("USDAUD", SYMBOL_ASK);
   double price_USDCHF = SymbolInfoDouble("USDCHF", SYMBOL_ASK);
   double price_EURJPY = SymbolInfoDouble("EURJPY", SYMBOL_ASK);
   double price_EURGBP = SymbolInfoDouble("EURGBP", SYMBOL_ASK);
   double price_EURCHF = SymbolInfoDouble("EURCHF", SYMBOL_ASK);
   
   double price_EURUSD_prev = iClose("EURUSD", timeFrame,0);
   double price_USDJPY_prev = iClose("USDJPY", timeFrame,0);
   double price_GBPUSD_prev = iClose("GBPUSD", timeFrame,0);
   double price_USDCAD_prev = iClose("USDCAD", timeFrame,0);
   double price_USDAUD_prev = iClose("USDAUD", timeFrame,0);
   double price_USDCHF_prev = iClose("USDCHF", timeFrame,0);
   double price_EURJPY_prev = iClose("EURJPY", timeFrame,0);
   double price_EURGBP_prev = iClose("EURGBP", timeFrame,0);
   double price_EURCHF_prev = iClose("EURCHF", timeFrame,0);
   
   double DXY =50.14348112 *pow(price_EURUSD,-0.6013)*pow(price_USDJPY,0.142)*pow(price_GBPUSD,-0.1242)*pow(price_USDCAD,0.095)*pow(price_USDCHF,0.0376);
   double DXY_prev =50.14348112 *pow(price_EURUSD_prev,-0.6013)*pow(price_USDJPY_prev,0.142)*pow(price_GBPUSD_prev,-0.1242)*pow(price_USDCAD_prev,0.095)*pow(price_USDCHF_prev,0.0376);
   double EXY =34.38805726 *pow(price_EURUSD,0.3424)*pow(price_EURJPY,0.2052)*pow(price_EURGBP,0.3316)*pow(price_EURCHF,0.1206);
   double EXY_prev =34.38805726 *pow(price_EURUSD_prev,0.3424)*pow(price_EURJPY_prev,0.2052)*pow(price_EURGBP_prev,0.3316)*pow(price_EURCHF_prev,0.1206);

   //double GBPIndex=DXY*price_GBPUSD
   //      ,CHFIndex=DXY*(1/price_USDCHF)
   //      ,JPYIndex=DXY*(1/price_USDJPY)
   //      ,CADIndex=DXY*(1/price_USDCAD)
   //      //,AUDIndex=DXY*(1/price_USDAUD)
   //       //XAUIndex=DXY*(1/price_XAUCHF)
   //;

   
   
    double  tenkan_sen_buffer[],kijun_sen_buffer[];int  iHandle;  
   
     iHandle=iIchimoku("EURUSD",0,9,26,52);
   

    CopyBuffer(iHandle,0,0,1,tenkan_sen_buffer);
    CopyBuffer(iHandle,1,0,1,kijun_sen_buffer);
      
    ArraySetAsSeries(tenkan_sen_buffer,true);  
    ArraySetAsSeries(kijun_sen_buffer,true);
  
  double bigNum=0,smallNum=0;
  
   if(tenkan_sen_buffer[0]>price_EURUSD && kijun_sen_buffer[0]<price_EURUSD)
   {
      if(tenkan_sen_buffer[0]>kijun_sen_buffer[0])
      {
         bigNum=tenkan_sen_buffer[0];
         smallNum=kijun_sen_buffer[0];
      }
      else if(tenkan_sen_buffer[0]<kijun_sen_buffer[0])
      {
         smallNum=tenkan_sen_buffer[0];
         bigNum=kijun_sen_buffer[0];
      } 
   }
   else if(tenkan_sen_buffer[0]<price_EURUSD && kijun_sen_buffer[0]>price_EURUSD)
   {
      if(tenkan_sen_buffer[0]<kijun_sen_buffer[0])
      {
         bigNum=kijun_sen_buffer[0];
         smallNum=tenkan_sen_buffer[0];
      }
      else if(tenkan_sen_buffer[0]>kijun_sen_buffer[0])
      {
         smallNum=kijun_sen_buffer[0];
         bigNum=tenkan_sen_buffer[0];
      } 
   }
   
   if(DXY-DXY_prev>0 &&EXY-EXY_prev<0 &&bigNum!=0 ) //sell EURUSD
   {
      openPosition("EURUSD",volume,ORDER_TYPE_SELL,SymbolInfoDouble("EURUSD", SYMBOL_ASK),bigNum,smallNum);
   }
   else if(DXY-DXY_prev<0 &&EXY-EXY_prev>0 &&bigNum!=0 ) //buy EURUSD
   {
      openPosition("EURUSD",volume,ORDER_TYPE_BUY,SymbolInfoDouble("EURUSD", SYMBOL_BID),smallNum,bigNum);
   }
   
}

void openPosition(string pair,double vol,ENUM_ORDER_TYPE orderType,double price,double sl,double tp)
  {
   MqlTradeRequest request1={0};
   MqlTradeResult result1={0};
   request1.symbol = pair;
   request1.volume = vol;
   request1.type=orderType;
   request1.action= TRADE_ACTION_DEAL;
   request1.price = price;
   request1.tp=tp;
   request1.sl=sl;

   if(!OrderSend(request1,result1))
     {
      PrintFormat("OrderSend error %d",GetLastError());
    
     }

  }
  
  int getTimeFrameSecond(ENUM_TIMEFRAMES tf)
  {
  switch(tf){
     case PERIOD_M1: return 60;break;
     case PERIOD_M2: return 60*2;break;
     case PERIOD_M3: return 60*3;break;
     case PERIOD_M4: return 60*4;break;
     case PERIOD_M5: return 60*5;break;
     case PERIOD_M6: return 60*6;break;
     case PERIOD_M10: return 60*10;break;
     case PERIOD_M12: return 60*12;break;
     case PERIOD_M15: return 60*15;break;
     case PERIOD_M20: return 60*20;break;
     case PERIOD_M30: return 60*30;break;
    
     case PERIOD_H1: return 360;break;
     case PERIOD_H2: return 360*2;break;
     case PERIOD_H3: return 360*3;break;
     case PERIOD_H4: return 360*4;break;
     case PERIOD_H6: return 360*6;break;
     case PERIOD_H8: return 360*8;break;
     case PERIOD_H12: return 360*12;break;
   
     case PERIOD_D1: return 360*24;break;
     case PERIOD_W1: return 360*24*7;break;
     case PERIOD_MN1: return 360*24*30;break;
      }
      return 1;
 }


//PERIOD_D1
// 
//1 day
// 
//
//PERIOD_W1
// 
//1 week
// 
//
//PERIOD_MN1
// 
//1 month
 

  