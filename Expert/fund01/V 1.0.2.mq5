//+------------------------------------------------------------------+
//| base on version 1.0.1                                              
//| add dynamic stoploss                     
//|                                           
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
sinput string mainPair="AUDCAD";
sinput string pair1="AUDUSD";
sinput string pair2="USDCAD";
input double tp_pip=0.0005;
input double ar_pip=0.0015;
input double volume=0.05;
input int maxOpenPostitions=5;
input double sl_pip=0.0005;
//+------------------------------------------------------------------+
//#include <Trade\Trade.mqh>
ENUM_POSITION_TYPE last_pos_type;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   printf("versions 1.0.2 ");
   EventSetTimer(1);
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
//if(!PositionSelect("AUDCAD"))
   OpenPosition();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPosition()
  {

   int digits=(int)SymbolInfoInteger(mainPair,SYMBOL_DIGITS);

   double price_mainPair_ask = SymbolInfoDouble(mainPair, SYMBOL_ASK);
   double price_mainPair_bid = SymbolInfoDouble(mainPair, SYMBOL_BID);
   double price_pair1_ask = SymbolInfoDouble(pair1, SYMBOL_ASK);
   double price_pair1_bid = SymbolInfoDouble(pair1, SYMBOL_BID);
   double price_pair2_ask = SymbolInfoDouble(pair2, SYMBOL_ASK);
   double price_pair2_bid = SymbolInfoDouble(pair2, SYMBOL_BID);


   double x_bid = (price_pair1_bid * price_pair2_bid);
   double x_ask = (price_pair1_ask * price_pair2_ask);


// checkForClose();
   int openPositions=PositionsTotal();

   if(x_bid-price_mainPair_ask>ar_pip && openPositions<=maxOpenPostitions)// && x_bid-xc_bid<0.0005 && x_bid-xc_bid>-0.0005 
     {
      //  checkForClose(mainPair);
      // printf("openPositions : "+ openPositions);
      MqlTradeRequest request1={0};
      MqlTradeResult result1={0};
      request1.symbol = mainPair;
      request1.volume = volume;
      request1.type=ORDER_TYPE_BUY;
      request1.action= TRADE_ACTION_DEAL;
      request1.price = price_mainPair_ask;
      request1.tp=NormalizeDouble(x_bid-tp_pip,digits);
      request1.sl=NormalizeDouble(price_mainPair_bid-sl_pip,digits);

      if(!OrderSend(request1,result1))
         PrintFormat("OrderSend error %d",GetLastError());
      else
        {
         last_pos_type=POSITION_TYPE_BUY;

        }
     }
   else if(x_ask-price_mainPair_bid<(-1*ar_pip) && openPositions<=maxOpenPostitions) //&& x_bid-xc_bid<0.0005 && x_bid-xc_bid>-0.0005
     {
      //   printf("openPositions : "+ openPositions);
      //checkForClose(mainPair);
      MqlTradeRequest request1={0};
      MqlTradeResult result1={0};
      request1.symbol = mainPair;
      request1.volume = volume;
      request1.type=ORDER_TYPE_SELL;
      request1.action= TRADE_ACTION_DEAL;
      request1.price = price_mainPair_bid;
      request1.tp=NormalizeDouble(x_ask+tp_pip,digits);
      //  request1.sl=NormalizeDouble(price_mainPair_bid+sl_pip,digits);

      if(!OrderSend(request1,result1))
         PrintFormat("OrderSend error %d",GetLastError());
      else
        {
         last_pos_type=POSITION_TYPE_SELL;
        }
     }
  }
//+------------------------------------------------------------------+
void updateStopLoss()
  {
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal();

   for(int i=0; i<total; i++)
     {
      double price=PositionGetDouble(POSITION_PRICE_OPEN);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double price_mainPair_ask = SymbolInfoDouble(mainPair, SYMBOL_ASK);
      double price_mainPair_bid = SymbolInfoDouble(mainPair, SYMBOL_BID);
      int ref=1;

      if((type==POSITION_TYPE_BUY && price_mainPair_bid>price) || (type==POSITION_TYPE_SELL && price_mainPair_bid<price))
        {
         ulong  position_ticket=PositionGetTicket(i);// ticket of the position
         string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol 
         int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places
       //  ulong  magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position
         //double vol=PositionGetDouble(POSITION_VOLUME);    // volume of the position
                                                              // double sl=PositionGetDouble(POSITION_SL);  // Stop Loss of the position
          double tp=PositionGetDouble(POSITION_TP);  // Take Profit of the position


         ZeroMemory(request);
         ZeroMemory(result);
         //--- setting the operation parameters
         request.action  =TRADE_ACTION_SLTP; // type of trade operation
         request.position=position_ticket;   // ticket of the position
         request.symbol=position_symbol;
         if(type==POSITION_TYPE_BUY)
            request.sl=NormalizeDouble(price_mainPair_bid-sl_pip,digits);
         else
            request.sl=NormalizeDouble(price_mainPair_bid+sl_pip,digits);                // Stop Loss of the position
          request.tp      =tp;                // Take Profit of the position
         // request.magic=EXPERT_MAGIC;         // MagicNumber of the position
         //--- output information about the modification
         PrintFormat("Modify #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
         //--- send the request
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   updateStopLoss();
  }
//+------------------------------------------------------------------+
