//+------------------------------------------------------------------+
//|   base on v 1.0.4 
//|   change method of get price for tick                   
//|                                    
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//sinput string mainPair="AUDCAD";  
//sinput string pair1="AUDUSD";  
//sinput string pair2="USDCAD";  
//input double tp_pip=0.0005;
//input double ar_pip=0.0015;
//input double volume=0.05;   
//input int maxOpenPostitions=5;                    
//+------------------------------------------------------------------+

#include<Trade\Trade.mqh>

ENUM_POSITION_TYPE last_pos_type[3];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   printf("versions final ");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   OpenPosition( "AUDCAD","AUDUSD","USDCAD",0.0006, 0.0015,0.01,5,0);
   OpenPosition( "NZDCAD","NZDUSD","USDCAD",0.0002, 0.0015,0.01,5,1);
   OpenPosition( "NZDCHF","NZDUSD","USDCHF",0.0002, 0.0015,0.01,7,2);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPosition(string mainPair,string pair1,string pair2,double tp_pip,double ar_pip,double volume,int maxOpenPostitions,int pairIndex)
  {

   int digits=(int)SymbolInfoInteger(mainPair,SYMBOL_DIGITS);

   MqlTick mainPair_tick,pair1_tick,pair2_tick;
   bool r1=SymbolInfoTick(mainPair,mainPair_tick);
   bool r2=SymbolInfoTick(pair1,pair1_tick);
   bool r3=SymbolInfoTick(pair2,pair2_tick);

   if(r1 && r2 && r3)
     {

      double price_mainPair_ask = mainPair_tick.ask;
      double price_mainPair_bid = mainPair_tick.bid;
      double price_pair1_ask = pair1_tick.ask;
      double price_pair1_bid = pair1_tick.bid;
      double price_pair2_ask = pair2_tick.ask;
      double price_pair2_bid = pair2_tick.bid;


      double x_bid = (price_pair1_bid * price_pair2_bid);
      double x_ask = (price_pair1_ask * price_pair2_ask);

      checkForClose(mainPair,pairIndex);
      int openPositions=PositionsTotal();

      if(x_bid>0 && x_bid-price_mainPair_ask>ar_pip && openPositions<=maxOpenPostitions)
        {
         MqlTradeRequest request1={0};
         MqlTradeResult result1={0};
         request1.symbol = mainPair;
         request1.volume = volume;
         request1.type=ORDER_TYPE_BUY;
         request1.action= TRADE_ACTION_DEAL;
         request1.price = price_mainPair_ask;
         request1.tp=NormalizeDouble(x_bid-tp_pip,digits);

         if(!OrderSend(request1,result1))
            PrintFormat("OrderSend error %d",GetLastError());
         else
           {
            last_pos_type[pairIndex]=POSITION_TYPE_BUY;
           }
        }
      else if(x_ask>0 && x_ask-price_mainPair_bid<(-1*ar_pip) && openPositions<=maxOpenPostitions)
        {
         MqlTradeRequest request1={0};
         MqlTradeResult result1={0};
         request1.symbol = mainPair;
         request1.volume = volume;
         request1.type=ORDER_TYPE_SELL;
         request1.action= TRADE_ACTION_DEAL;
         request1.price = price_mainPair_bid;
         request1.tp=NormalizeDouble(x_ask+tp_pip,digits);

         if(!OrderSend(request1,result1))
            PrintFormat("OrderSend error %d",GetLastError());
         else
           {
            last_pos_type[pairIndex]=POSITION_TYPE_SELL;
           }
        }
     }
   else
      Print("SymbolInfoTick() failed, error = ",GetLastError());
  }
//+------------------------------------------------------------------+
void checkForClose(string mainPair,int pairIndex)
  {
   for(int i=0; i<PositionsTotal(); i++)
     {
      if(PositionSelect(mainPair))
        {
         ResetLastError();
         ENUM_POSITION_TYPE pos_type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(pos_type!=last_pos_type[pairIndex])
           {
            CTrade trade;
            trade.PositionClose(mainPair);
           }
        }
     }

  }
//+------------------------------------------------------------------+
