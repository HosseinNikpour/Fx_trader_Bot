//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//  change from arb1
//
//  1. don't trade in jan ,feb , apr 
//  2. in dec vol*1.5
//  3. close after 4 days                           |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

input double tp_pip=0.0005;
input double ar_pip=0.0015;
//input double volume=1;
int  buyNum =0; 
int  sellNum =0; 
double vol=1;

string mainCurr="EURJPY",curr1="EURUSD",curr2="USDJPY";

 ENUM_POSITION_TYPE last_pos_type;
int OnInit()
  {
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
void OnTick()
  {
  vol=0.5;
      MqlDateTime Time;
      TimeCurrent(Time);
    //  if(Time.mon==12)vol=2;
      
      //if(Time.mon!=5){
         checkForStatics();
         OpenPosition();
     // }
  }
void OnTimer()
  {

  }

void checkForStatics()
{
   
     for(int i=0; i<PositionsTotal(); i++){
     if(PositionSelect(mainCurr)){
         ResetLastError(); // Reset the last error
         ENUM_POSITION_TYPE pos_type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
          MqlDateTime positionMDT,currentMDT;
        
         datetime positionTime =PositionGetInteger(POSITION_TIME);
         datetime currentTime=TimeCurrent();
         TimeToStruct(positionTime,positionMDT);
         TimeToStruct(currentTime,currentMDT);
         int diff=currentMDT.day - positionMDT.day;

         if(pos_type!=last_pos_type){
            CTrade trade;
            trade.PositionClose(Symbol());
        }
     }
   }
}

void OpenPosition()
   {
   
   double price_AUDCAD_ask = SymbolInfoDouble(mainCurr, SYMBOL_ASK);
   double price_AUDCAD_bid = SymbolInfoDouble(mainCurr, SYMBOL_BID);
   double price_AUDUSD_ask = SymbolInfoDouble(curr1, SYMBOL_ASK);
   double price_AUDUSD_bid = SymbolInfoDouble(curr1, SYMBOL_BID);
   double price_USDCAD_ask = SymbolInfoDouble(curr2, SYMBOL_ASK);
   double price_USDCAD_bid = SymbolInfoDouble(curr2, SYMBOL_BID);
   
   int    digits=(int)SymbolInfoInteger(mainCurr,SYMBOL_DIGITS);
 
   
   double x_bid=(price_USDCAD_bid*price_AUDUSD_bid);
   double x_ask=(price_USDCAD_ask*price_AUDUSD_ask);
   
     buyNum=PositionsTotal();
     sellNum=PositionsTotal();
       if( x_bid-price_AUDCAD_ask>ar_pip &&buyNum<1)
      {  
         
         //if(x_bid-price_AUDCAD_ask<0.0018)vol*=0.2;
         //else if(x_bid-price_AUDCAD_ask<0.0021)vol*=0.3;
         //else if(x_bid-price_AUDCAD_ask<0.0023)vol*=0.5;
         //else vol*=0.23;
         
         MqlTradeRequest request1={0};
         MqlTradeResult  result1={0};
         request1.symbol   =mainCurr;
         request1.volume   =vol;
         request1.type     =ORDER_TYPE_BUY;
         request1.action   =TRADE_ACTION_DEAL;
         request1.price    =price_AUDCAD_ask; 
         //request.deviation=5;  
         request1.tp=NormalizeDouble(x_bid-tp_pip,digits);

         if(!OrderSend(request1,result1))
            PrintFormat("OrderSend error %d",GetLastError());
         else{
            last_pos_type=POSITION_TYPE_BUY;
            buyNum+=1;
            }
       }
       else  if( x_ask-price_AUDCAD_bid<(-1*ar_pip)&&sellNum<1)
      {
         
         //if(x_ask-price_AUDCAD_bid>-0.0018)vol*=0.2;
         //else if(x_ask-price_AUDCAD_bid>-0.0021)vol*=0.3;
         //else if(x_ask-price_AUDCAD_bid>-0.0023)vol*=0.5;
         //else vol*=0.23;
         MqlTradeRequest request1={0};
         MqlTradeResult  result1={0};
         request1.symbol   =mainCurr;
         request1.volume   =vol;
         request1.type     =ORDER_TYPE_SELL;
         request1.action   =TRADE_ACTION_DEAL;
         request1.price    =price_AUDCAD_bid; 
         //request.deviation=5;  
         request1.tp=NormalizeDouble(x_ask+tp_pip,digits);
        
         if(!OrderSend(request1,result1))
            PrintFormat("OrderSend error %d",GetLastError());
         else{
            last_pos_type=POSITION_TYPE_SELL;
            sellNum+=1;
            }
       }
     
   }