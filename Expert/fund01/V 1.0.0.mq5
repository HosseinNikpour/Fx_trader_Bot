//+------------------------------------------------------------------+
//|                                                       fund01.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
input string mainPair="AUDCAD";  
input string pair1="AUDUSD";

input string pair2="USDCAD";  

input double tp_pip=0.0005;
input double ar_pip=0.0015;
input double vol=0.05;   
      sinput string mainPair2="AUDCAD";                       
//+------------------------------------------------------------------+
 #include <Trade\Trade.mqh>
 ENUM_POSITION_TYPE last_pos_type;
int OnInit()
  {
  printf("versions 1.0.0 ");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
  }

void OnTick()
  {
   //if(!PositionSelect("AUDCAD"))
      OpenPosition();
   
  }

void OpenPosition()
  {

   int digits=(int)SymbolInfoInteger(mainPair,SYMBOL_DIGITS);


   double price_mainPair_ask = SymbolInfoDouble(mainPair, SYMBOL_ASK);
   double price_mainPair_bid = SymbolInfoDouble(mainPair, SYMBOL_BID);
   double price_pair1_ask = SymbolInfoDouble(pair1, SYMBOL_ASK);
   double price_pair1_bid = SymbolInfoDouble(pair1, SYMBOL_BID);
   double price_pair2_ask = SymbolInfoDouble(pair2, SYMBOL_ASK);
   double price_pair2_bid = SymbolInfoDouble(pair2, SYMBOL_BID);
   //double price_cPair1_ask = SymbolInfoDouble(cPair1, SYMBOL_ASK);
   //double price_cPair1_bid = SymbolInfoDouble(cPair1, SYMBOL_BID);
   //double price_cPair2_ask = SymbolInfoDouble(cPair2, SYMBOL_ASK);
   //double price_cPair2_bid = SymbolInfoDouble(cPair2, SYMBOL_BID);
 
  
if(isPair1Revese)
{
    x_bid = (1/price_pair1_bid * price_pair2_bid);
    x_ask = (1/price_pair1_ask * price_pair2_ask);
}  
   
   double x_bid = (price_pair1_bid * price_pair2_bid);
   double x_ask = (price_pair1_ask * price_pair2_ask);
   //double xc_bid = ((1/price_cPair1_bid) * price_cPair2_bid);
   //double xc_ask = ((1/price_cPair1_ask) * price_cPair2_ask);
   
   checkForClose();
   
   if(x_bid-price_mainPair_ask>ar_pip)// && x_bid-xc_bid<0.0005 && x_bid-xc_bid>-0.0005 
     {
   //  checkForClose(mainPair);
      
      MqlTradeRequest request1={0};
      MqlTradeResult result1={0};
      request1.symbol = mainPair;
      request1.volume = vol;
      request1.type=ORDER_TYPE_BUY;
      request1.action= TRADE_ACTION_DEAL;
      request1.price = price_mainPair_ask;
      request1.tp=NormalizeDouble(x_bid-tp_pip,digits);

      if(!OrderSend(request1,result1))
         PrintFormat("OrderSend error %d",GetLastError());
      else{
        last_pos_type = POSITION_TYPE_BUY;
      ////  buyNum += 1;
      }
     }
   else if(x_ask-price_mainPair_bid<(-1*ar_pip) ) //&& x_bid-xc_bid<0.0005 && x_bid-xc_bid>-0.0005
     {
//checkForClose(mainPair);
      MqlTradeRequest request1={0};
      MqlTradeResult result1={0};
      request1.symbol = mainPair;
      request1.volume = vol;
      request1.type=ORDER_TYPE_SELL;
      request1.action= TRADE_ACTION_DEAL;
      request1.price = price_mainPair_bid;
      request1.tp=NormalizeDouble(x_ask+tp_pip,digits);

      if(!OrderSend(request1,result1))
         PrintFormat("OrderSend error %d",GetLastError());
      else{
        last_pos_type = POSITION_TYPE_SELL;
      }
     }
  }
//+------------------------------------------------------------------+
void checkForClose(){
 for(int i=0; i<PositionsTotal(); i++){
     if(PositionSelect(mainPair)){
         ResetLastError(); 
         ENUM_POSITION_TYPE pos_type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(pos_type!=last_pos_type){
            CTrade trade;
            trade.PositionClose(Symbol());
        }
     }
   }

}
