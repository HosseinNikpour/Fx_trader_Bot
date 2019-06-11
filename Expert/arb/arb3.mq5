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
//  3. close after 4 days 
//  4. stop loss                           |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

input double tp_pip=0.0005;
input double ar_pip=0.0015;
input double sl_pip=2;

int  buyNum =0; 
int  sellNum =0; 
double vol=0.01;
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
  vol=0.01;
      MqlDateTime Time;
      TimeCurrent(Time);
      //if(Time.mon==12)vol=1.5;
      
     // if(Time.mon!=1&&Time.mon!=2&&Time.mon!=4){
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
     if(PositionSelect("AUDCAD")){
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
   
   double price_AUDCAD_ask = SymbolInfoDouble("AUDCAD", SYMBOL_ASK);
   double price_AUDCAD_bid = SymbolInfoDouble("AUDCAD", SYMBOL_BID);
   double price_AUDUSD_ask = SymbolInfoDouble("AUDUSD", SYMBOL_ASK);
   double price_AUDUSD_bid = SymbolInfoDouble("AUDUSD", SYMBOL_BID);
   double price_USDCAD_ask = SymbolInfoDouble("USDCAD", SYMBOL_ASK);
   double price_USDCAD_bid = SymbolInfoDouble("USDCAD", SYMBOL_BID);
   
   int    digits=(int)SymbolInfoInteger("AUDCAD",SYMBOL_DIGITS);
 
   
   double x_bid=(price_USDCAD_bid*price_AUDUSD_bid);
   double x_ask=(price_USDCAD_ask*price_AUDUSD_ask);
   
     buyNum=PositionsTotal();
     sellNum=PositionsTotal();
     double diff_ask= x_bid-price_AUDCAD_ask;
     double diff_bid=x_ask-price_AUDCAD_bid;
       if(diff_ask>ar_pip &&buyNum<1)
      {  
         
     
         MqlTradeRequest request1={0};
         MqlTradeResult  result1={0};
         request1.symbol   ="AUDCAD";
         request1.volume   =vol;
         request1.type     =ORDER_TYPE_BUY;
         request1.action   =TRADE_ACTION_DEAL;
         request1.price    =price_AUDCAD_ask; 
         //request.deviation=5;  
         request1.tp=NormalizeDouble(x_bid-tp_pip,digits);
         request1.sl=NormalizeDouble(price_AUDCAD_ask-(diff_ask*sl_pip),digits);
         if(!OrderSend(request1,result1))
            PrintFormat("OrderSend error %d",GetLastError());
         else{
            last_pos_type=POSITION_TYPE_BUY;
            buyNum+=1;
            }
       }
       else  if(diff_bid<(-1*ar_pip)&&sellNum<1)
      {
         
               
         MqlTradeRequest request1={0};
         MqlTradeResult  result1={0};
         request1.symbol   ="AUDCAD";
         request1.volume   =vol;
         request1.type     =ORDER_TYPE_SELL;
         request1.action   =TRADE_ACTION_DEAL;
         request1.price    =price_AUDCAD_bid; 
         //request.deviation=5;  
         request1.tp=NormalizeDouble(x_ask+tp_pip,digits);
         request1.tp=NormalizeDouble(price_AUDCAD_bid+(diff_bid*sl_pip),digits);
         if(!OrderSend(request1,result1))
            PrintFormat("OrderSend error %d",GetLastError());
         else{
            last_pos_type=POSITION_TYPE_SELL;
            sellNum+=1;
            }
       }
     
   }