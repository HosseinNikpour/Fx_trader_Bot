//+------------------------------------------------------------------+
//|   base on v 1.0.1 
//|   add password and expired Date                    
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
 //input string password="";
 //datetime d4=D'01.06.2019';
 #include <Trade\Trade.mqh>

 ENUM_POSITION_TYPE last_pos_type[3];
int OnInit()
  {
  printf("versions final ");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
  }

void OnTick()
  {
  

    
      OpenPosition( "AUDCAD","AUDUSD","USDCAD",0.0006, 0.0015,0.01,5,0);
      OpenPosition( "NZDCAD","NZDUSD","USDCAD",0.0002, 0.0015,0.01,5,1);
      OpenPosition( "NZDCHF","NZDUSD","USDCHF",0.0002, 0.0015,0.01,7,2);
   
  }

void OpenPosition(string mainPair,string pair1,string pair2,double tp_pip,double ar_pip,double volume,int maxOpenPostitions,int pairIndex)
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
   
   checkForClose(mainPair,pairIndex);
   int openPositions=PositionsTotal();
 
   if(x_bid>0&&x_bid-price_mainPair_ask>ar_pip&& openPositions<= maxOpenPostitions)
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
      else{
        last_pos_type[pairIndex] = POSITION_TYPE_BUY;
      }
     }
   else if(x_ask>0&&x_ask-price_mainPair_bid<(-1*ar_pip) && openPositions<= maxOpenPostitions) 
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
      else{
        last_pos_type[pairIndex] = POSITION_TYPE_SELL;
      }
     }
  }
//+------------------------------------------------------------------+
void checkForClose(string mainPair,int pairIndex){
 for(int i=0; i<PositionsTotal(); i++){
     if(PositionSelect(mainPair)){
         ResetLastError(); 
         ENUM_POSITION_TYPE pos_type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(pos_type!=last_pos_type[pairIndex]){
            CTrade trade;
            trade.PositionClose(mainPair);
        }
     }
   }

}
