//+------------------------------------------------------------------+
//|                                                           01.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include<Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   CheckOpenPosition("AUDUSD","USDCAD","AUDCAD",0.0015,0.01,3);
  }
//+------------------------------------------------------------------+
void CheckOpenPosition(string pair1,string pair2,string pair3,double ar_pip,double volume,int maxOpenPostitions)
  {

   double price_pair1_ask = SymbolInfoDouble(pair1, SYMBOL_ASK);
   double price_pair1_bid = SymbolInfoDouble(pair1, SYMBOL_BID);
   double price_pair2_ask = SymbolInfoDouble(pair2, SYMBOL_ASK);
   double price_pair2_bid = SymbolInfoDouble(pair2, SYMBOL_BID);
   double price_pair3_ask = SymbolInfoDouble(pair3, SYMBOL_ASK);
   double price_pair3_bid = SymbolInfoDouble(pair3, SYMBOL_BID);

   double x_bid = (price_pair1_bid * price_pair2_bid);
   double x_ask = (price_pair1_ask * price_pair2_ask);
   int openPositions=PositionsTotal();

   if(x_bid-price_pair3_ask>ar_pip && openPositions<=maxOpenPostitions)
     {
      //printf("BUY");
      //printf("volume1: "+volume);
      // printf("volume2: "+(volume*price_pair1_bid));
      // printf("volume3: "+NormalizeDouble((((100000*volume*price_pair1_bid)/price_pair2_bid)/price_pair3_ask)/100000,2));
      bool pair3Result=false,pair1Result=false,pair2Result=false;
      //     
      while(!pair1Result)
         pair1Result=openPosition(pair1,volume,ORDER_TYPE_SELL,price_pair1_bid,ar_pip);
      while(!pair2Result)
         pair2Result=openPosition(pair2,NormalizeDouble(volume*price_pair1_bid,2),ORDER_TYPE_SELL,price_pair2_bid,ar_pip);
      while(!pair3Result)
         pair3Result=openPosition(pair3,NormalizeDouble((((100000*volume*price_pair1_bid)/price_pair2_bid)/price_pair3_ask)/100000,2),ORDER_TYPE_BUY,price_pair3_ask,ar_pip);
      //maxOpenPostitions++;

     }
   else if(x_ask-price_pair3_bid<(-1*ar_pip) && openPositions<=maxOpenPostitions)
     {
      //printf("SELL");
      // printf("volume1: "+NormalizeDouble(((100000/price_pair2_ask*volume)/price_pair1_ask)/100000,2));//100000),2));
      // printf("volume2: "+volume);
      // printf("volume3: "+NormalizeDouble((price_pair3_bid/(price_pair1_bid/price_pair2_bid*volume)/100000)*100000,2));


      bool pair3Result=false,pair1Result=false,pair2Result=false;

      while(!pair1Result)

         pair1Result=openPosition(pair1,NormalizeDouble(((100000/price_pair2_ask*volume)/price_pair1_ask)/100000,2),ORDER_TYPE_BUY,price_pair1_ask,ar_pip);
      while(!pair2Result)
         pair2Result=openPosition(pair2,volume,ORDER_TYPE_BUY,price_pair2_ask,ar_pip);
      while(!pair3Result)
         pair3Result=openPosition(pair3,NormalizeDouble((price_pair3_bid/(price_pair1_bid/price_pair2_bid*volume)/100000)*100000,2),ORDER_TYPE_SELL,price_pair3_bid,ar_pip);

     }
//   if(x_bid>=price_pair3_ask)
//      closeAllPostitions();
//
//   if(x_bid<=price_pair3_ask)
//      closeAllPostitions();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool openPosition(string pair,double volume,ENUM_ORDER_TYPE orderType,double price,double ar_pip)
  {
   MqlTradeRequest request1={0};
   MqlTradeResult result1={0};
   request1.symbol = pair;
   request1.volume = volume;
   request1.type=orderType;
   request1.action= TRADE_ACTION_DEAL;
   request1.price = price;
   int digits=(int)SymbolInfoInteger(pair,SYMBOL_DIGITS);

   request1.tp=NormalizeDouble(price+ar_pip-0.0005,digits);
   if(orderType==ORDER_TYPE_SELL)
      request1.tp=NormalizeDouble(price-ar_pip+0.0005,digits);

   if(!OrderSend(request1,result1))
     {
      PrintFormat("OrderSend error %d",GetLastError());
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllPostitions()
  {

   int i=PositionsTotal()-1;
   while(i>=0)
     {
      CTrade trade;
      if(trade.PositionClose(PositionGetSymbol(i))) i--;
     }

  }
//+------------------------------------------------------------------+
