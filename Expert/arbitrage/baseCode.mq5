//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
//+------------------------------------------------------------------+
//|the original code      
//
// for sl ==> unComment line 100 & 123


                              
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

input double tp_pip = 0.0005;
input double ar_pip = 0.0015;
//input int count = 3;


//int buyNum = 0,sellNum = 0;
double vol = 1;
ENUM_POSITION_TYPE last_pos_type;

string mainPair="AUDCAD",pair1="AUDUSD",pair2="USDCAD";
//string mainPair="GBPCHF",pair1="GBPUSD",pair2="USDCHF";

int digits = (int)SymbolInfoInteger(mainPair, SYMBOL_DIGITS);



int OnInit(){
  EventSetTimer(1);
  return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason){
  EventKillTimer();
}
void OnTick(){
  vol = 1;
  MqlDateTime Time;
  TimeCurrent(Time);
 // if(Time.hour==15 )vol=5;
// if (Time.hour > 4 && Time.hour < 23){
 //if (Time.hour !=2&&Time.hour !=17){
    checkForStatics();
    OpenPosition();
 // }
}
void OnTimer(){
}

void checkForStatics(){
  for (int i = 0; i < PositionsTotal(); i++)  {
    if (PositionSelect(mainPair))    {
      ResetLastError(); // Reset the last error
      ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if (pos_type != last_pos_type)      {
        CTrade trade;
        trade.PositionClose(Symbol());
        //buyNum = 0;
       // sellNum = 0;
      }
    }
  }
}


void OpenPosition(){

  double price_mainPair_ask = SymbolInfoDouble(mainPair, SYMBOL_ASK);
  double price_mainPair_bid = SymbolInfoDouble(mainPair, SYMBOL_BID);
  double price_pair1_ask = SymbolInfoDouble(pair1, SYMBOL_ASK);
  double price_pair1_bid = SymbolInfoDouble(pair1, SYMBOL_BID);
  double price_pair2_ask = SymbolInfoDouble(pair2, SYMBOL_ASK);
  double price_pair2_bid = SymbolInfoDouble(pair2, SYMBOL_BID);

  double x_bid = (price_pair1_bid * price_pair2_bid);
  double x_ask = (price_pair1_ask * price_pair2_ask);

  // buyNum = PositionsTotal();
  // sellNum = PositionsTotal();
  if (x_bid - price_mainPair_ask > ar_pip){ //&&buyNum<count  
    if (x_bid - price_mainPair_ask < 0.0018) vol *= 0.15;
    else if (x_bid - price_mainPair_ask < 0.0021) vol *= 0.18;
    else if (x_bid - price_mainPair_ask < 0.0023) vol *= 0.21;
    else vol *= 0.23;

    MqlTradeRequest request1 = {0};
    MqlTradeResult result1 = {0};
    request1.symbol = mainPair;
    request1.volume = vol;
    request1.type = ORDER_TYPE_BUY;
    request1.action = TRADE_ACTION_DEAL;
    request1.price = price_mainPair_ask;
    request1.tp = NormalizeDouble(x_bid - tp_pip, digits);
    //request1.sl=NormalizeDouble(price_mainPair_ask-(diff_ask*sl_pip),digits);
    if (!OrderSend(request1, result1))
      PrintFormat("OrderSend error %d", GetLastError());
    else{
      last_pos_type = POSITION_TYPE_BUY;
    //  buyNum += 1;
    }
  }
  else if (x_ask - price_mainPair_bid < (-1 * ar_pip)){ //&&sellNum<count
     
    if (x_ask - price_mainPair_bid > -0.0018)  vol *= 0.15;
    else if (x_ask - price_mainPair_bid > -0.0021)  vol *= 0.18;
    else if (x_ask - price_mainPair_bid > -0.0023)  vol *= 0.21;
    else  vol *= 0.23;

    MqlTradeRequest request1 = {0};
    MqlTradeResult result1 = {0};
    request1.symbol = mainPair;
    request1.volume = vol;
    request1.type = ORDER_TYPE_SELL;
    request1.action = TRADE_ACTION_DEAL;
    request1.price = price_mainPair_bid;
    request1.tp = NormalizeDouble(x_ask + tp_pip, digits);
    //request1.tp=NormalizeDouble(price_mainPair_bid+(diff_bid*sl_pip),digits);
    if (!OrderSend(request1, result1))
      PrintFormat("OrderSend error %d", GetLastError());
    else
    {
      last_pos_type = POSITION_TYPE_SELL;
     // sellNum += 1;
    }
  }
}