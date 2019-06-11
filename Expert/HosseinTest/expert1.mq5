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
#include<Trade\Trade.mqh>
double volume=0.01;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(isNewBar())
      HN();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HN()
  {
  int digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
   MqlTick Latest_Price;
   SymbolInfoTick(Symbol(),Latest_Price);

   double avgPrice=calcAvreagePrice(Symbol());
   double diff=NormalizeDouble(-avgPrice+Latest_Price.ask,digits);
  // printf("avgPrice: "+avgPrice+"    Latest_Price.bid: "+Latest_Price.bid+"      diff: "+diff);
   if(NormalizeDouble(Latest_Price.ask+0.00015,digits)<avgPrice)
     {
      openPosition(Symbol(),volume,ORDER_TYPE_BUY,Latest_Price.ask);
     }
   else
     {
      printf("in closeAllPositions");
      closeAllPositions(Symbol());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double calcAvreagePrice(string symbol)
  {

   double myPrice=0;
   int counter=0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      if(PositionSelect(symbol))
        {
         double price=PositionGetDouble(POSITION_PRICE_OPEN);
         double volume=PositionGetDouble(POSITION_VOLUME);
         myPrice+=(price);
         counter+=1;
        }
     }
   if(counter==0)
      return 0;
   return  myPrice/counter;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar()
  {
   static datetime last_time=0;
   datetime lastbar_time=SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);
   if(last_time==0)
     {
      last_time=lastbar_time;
      return(false);
     }
   if(last_time!=lastbar_time)
     {
      last_time=lastbar_time;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void openPosition(string pair,double vol,ENUM_ORDER_TYPE orderType,double price)
  {
   MqlTradeRequest request1={0};
   MqlTradeResult result1={0};
   request1.symbol = pair;
   request1.volume = vol;
   request1.type=orderType;
   request1.action= TRADE_ACTION_DEAL;
   request1.price = price;
//request1.tp=tp;
// request1.sl=sl;

   if(!OrderSend(request1,result1))
     {
      PrintFormat("OrderSend error %d",GetLastError());
     }
  }
//+------------------------------------------------------------------+
void closeAllPositions(string symbol)
  {

   for(int i=0; i<PositionsTotal(); i++)
     {
      if(PositionSelect(symbol))
        {

         CTrade trade;
         trade.PositionClose(symbol);

        }
     }

  }
//+-------
