//+------------------------------------------------------------------+
//|                                                         emad.mq5 |
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
input float vol=1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum andicatorType
  {
   MACD,
   CCI,
   RSI,
   SMA,
   EMA,
   WMA,
   Stoch,
   william,
   BB,
   Ichi,
   AD
  };
input andicatorType typ;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   EventSetTimer(3600*24);
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
   if(pub_is_new_candle(_Symbol,0)==true)

     {
      MqlDateTime Time;
      TimeCurrent(Time);
      // if(Time.day!=1 &&Time.day!=2)
        {
         switch(typ)
           {
            case Ichi:
               CrossIchi();
               break;
            case SMA:
               CrossMoving(12,26,MODE_SMA);
               break;
            case WMA:
               CrossMoving(12,26,MODE_LWMA);
               break;
            case EMA:
               CrossMoving(12,26,MODE_EMA);
               break;
            case Stoch:
               CrossStoch(5,3);
               break;
            case RSI:
               RSI();
               break;
            case CCI:
               CCI();
               break;
            case william:
               william();
               break;
            case MACD:
               MACD();
               break;
            case BB:
               BB();
               break;
            case AD:
               AD();
               break;
           }
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

  }
//+------------------------------------------------------------------+
void CrossMoving(int shortPeriod,int longPeriod,ENUM_MA_METHOD method)
  {
   double  maS[],maL[];
   int  maHandleS,maHandleL;

   maHandleS=iMA(Symbol(),0,shortPeriod,0,method,PRICE_CLOSE);
   maHandleL=iMA(Symbol(),0,longPeriod ,0,method,PRICE_CLOSE);

   CopyBuffer(maHandleS,0,0,2,maS);
   CopyBuffer(maHandleL,0,0,2,maL);

   ArraySetAsSeries(maS,true);
   ArraySetAsSeries(maL,true);

   if(maS[0]>=maL[0] && maS[1]<maL[1])
     {
      openingPosition(ORDER_TYPE_BUY);
     }
   else if(maS[0]<=maL[0] &&maS[1]>maL[1])
     {
      //printf("aaaaaaaaaaaaaaaa");
      //printf("maS[0] "+maS[0]);
      //printf("maS[1] "+maS[1]);
      //printf("maL[0] "+maL[0]);
      //printf("maL[1] "+maL[1]);
      // openingPosition(ORDER_TYPE_SELL);
      checkForClose();
     }
  }
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

void MACD()
  {
   double  maS[],maL[];
   int  macdHandleS;

   macdHandleS=iMACD(Symbol(),0,12,26,9,PRICE_CLOSE);

   CopyBuffer(macdHandleS,0,0,2,maS);
   CopyBuffer(macdHandleS,1,0,2,maL);

   ArraySetAsSeries(maS,true);
   ArraySetAsSeries(maL,true);

   if(maS[0]>=maL[0] && maS[1]<maL[1])
      openingPosition(ORDER_TYPE_BUY);

   else if(maS[0]<=maL[0] && maS[1]>maL[1])
     {
      // openingPosition(ORDER_TYPE_SELL);
      checkForClose();
     }
  }
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
void BB()
  {
   double  maS[],maL[],low,close;
   int  BBHandleS,BBHandleL;

   BBHandleS=iBands(Symbol(),0,20,0,2,PRICE_CLOSE);
   BBHandleL=iBands(Symbol(),0,20,0,2,PRICE_CLOSE);
   low=iLow(Symbol(),PERIOD_CURRENT,0);
   close=iClose(Symbol(),PERIOD_CURRENT,0);

   CopyBuffer(BBHandleS,0,0,2,maL);
   CopyBuffer(BBHandleL,2,0,2,maS);

   ArraySetAsSeries(maS,true);
   ArraySetAsSeries(maL,true);

//printf("maS[0]   "+maS[0]);
//printf("maL[0]   "+maL[0]);
   printf("Low[0]   "+low);

   if(low<=maS[0])
      openingPosition(ORDER_TYPE_BUY);

   else if(close>=maL[0])
     {
      // openingPosition(ORDER_TYPE_SELL);
      checkForClose();
     }
  }
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

void AD()
  {
   double  maS[],maL[],low0,low1,close0,close1;
   int   ADHandleS;

   ADHandleS=iAD(Symbol(),0,VOLUME_TICK);
   low0=iLow(Symbol(),PERIOD_CURRENT,0);
   low1=iLow(Symbol(), PERIOD_CURRENT,1);
   close0=iClose(Symbol(),PERIOD_CURRENT,0);
   close1=iClose(Symbol(), PERIOD_CURRENT,1);

   CopyBuffer(ADHandleS,0,0,2,maS);

   ArraySetAsSeries(maS,true);
   printf("Low[0]   "+low0);
   printf("Low[1]   "+low1);
   printf("maS[0]   "+maS[0]);
   printf("maS[1]   "+maS[1]);

   if(maS[0]>=maS[1] && low0>low1)
      openingPosition(ORDER_TYPE_BUY);

   else if(low0<=close0 || maS[0]>=maS[1])
     {
      // openingPosition(ORDER_TYPE_SELL);
      checkForClose();
     }
  }
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------


void CrossIchi()
  {
   double  maS[],maL[];
   int  iHandle;

   iHandle=iIchimoku(Symbol(),0,9,26,52);

   CopyBuffer(iHandle,0,1,2,maS);
   CopyBuffer(iHandle,1,1,2,maL);

   ArraySetAsSeries(maS,true);
   ArraySetAsSeries(maL,true);

//printf("maS[0]   "+maS[0]);
//printf("maS[1]   "+maS[1]);
//printf("maL[0]   "+maL[0]);
//printf("maL[1]   "+maL[1]);
   if(maS[0]>=maL[0] && maS[1]<maL[1])
      openingPosition(ORDER_TYPE_BUY);
   else if(maS[0]<=maL[0] && maS[1]>maL[1])
     {
      // openingPosition(ORDER_TYPE_SELL);
      checkForClose();
     }
  }
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

void CrossStoch(int kPeriod,int dPeriod)
  {
   double  maS[],maL[];
   int  StochHandle;

   StochHandle=iStochastic(Symbol(),0,kPeriod,dPeriod,3,MODE_SMA,STO_LOWHIGH);

   CopyBuffer(StochHandle,MAIN_LINE,1,2,maS);
   CopyBuffer(StochHandle,SIGNAL_LINE,1,2,maL);

   ArraySetAsSeries(maS,true);
   ArraySetAsSeries(maL,true);

// printf("maS[0]   "+maS[0]);
// printf("maS[1]   "+maS[1]);
// printf("maL[0]   "+maL[0]);
//printf("maL[1]   "+maL[1]);
   if(maS[0]>=maL[0] && maS[1]<maL[1])
      openingPosition(ORDER_TYPE_BUY);
   else if(maS[0]<=maL[0] && maS[1]>maL[1])
     {
      // openingPosition(ORDER_TYPE_SELL);
      checkForClose();
     }
  }
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
void RSI()
  {
   double  maS[],maL[];
   int  RSIHandle;

   RSIHandle=iRSI(Symbol(),0,14,PRICE_CLOSE);

   CopyBuffer(RSIHandle,MAIN_LINE,1,2,maS);

   ArraySetAsSeries(maS,true);

   if(maS[1]<30 && maS[0]>=30)
      openingPosition(ORDER_TYPE_BUY);
   else if(maS[0]>=70)
     {
      // openingPosition(ORDER_TYPE_SELL);
      checkForClose();
     }
  }
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

void william()
  {
   double  maS[],maL[];
   int  WHandle;

   WHandle=iWPR(Symbol(),0,14);

   CopyBuffer(WHandle,MAIN_LINE,1,2,maS);

   ArraySetAsSeries(maS,true);

   if(maS[1]<-80 && maS[0]>=-80)
      openingPosition(ORDER_TYPE_BUY);
   else if(maS[0]>=-20)
     {
      //openingPosition(ORDER_TYPE_SELL);
      checkForClose();
     }
  }
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

void CCI()
  {
   double  maS[],maL[];
   int CCIHandle;

   CCIHandle=iCCI(Symbol(),0,14,PRICE_CLOSE);

   CopyBuffer(CCIHandle,MAIN_LINE,1,2,maS);

   ArraySetAsSeries(maS,true);

   if(maS[1]<-100 && maS[0]>=-100)
      openingPosition(ORDER_TYPE_BUY);
   else if(maS[0]>=100)
     {
      // openingPosition(ORDER_TYPE_SELL);
      checkForClose();
     }
  }
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

void openingPosition(ENUM_ORDER_TYPE orderType)
  {
   MqlTradeRequest request1={0};
   MqlTradeResult result1={0};
   request1.symbol = Symbol();
   request1.volume = vol;
   request1.type=orderType;
   request1.action=TRADE_ACTION_DEAL;
   request1.type_filling=2;

   if(!OrderSend(request1,result1))
      PrintFormat("OrderSend error %d",GetLastError());
  }
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

void checkForClose()
  {
   printf("inside Close"+PositionsTotal());
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal(); // number of open positions   
//--- iterate over all open positions
   for(int i=total-1; i>=0; i--)
     {
      //--- parameters of the order
      ulong  position_ticket=PositionGetTicket(i);                                      // ticket of the position
      string position_symbol=PositionGetString(POSITION_SYMBOL);                        // symbol 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);              // number of decimal places
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // MagicNumber of the position
      double volume=PositionGetDouble(POSITION_VOLUME);                                 // volume of the position
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // type of the position
      //--- output information about the position
      PrintFormat("#%I64u %s  %s  %.2f  %s [%I64d]",
                  position_ticket,
                  position_symbol,
                  EnumToString(type),
                  volume,
                  DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                  magic);
      //--- if the MagicNumber matches
      if(magic==0)
        {
         //--- zeroing the request and result values
         ZeroMemory(request);
         ZeroMemory(result);
         //--- setting the operation parameters
         request.action   =TRADE_ACTION_DEAL;        // type of trade operation
         request.position =position_ticket;          // ticket of the position
         request.symbol   =position_symbol;          // symbol 
         request.volume   =volume;                   // volume of the position
         request.deviation=5;                        // allowed deviation from the price
         request.magic=0;
         request.type_filling=2;             // MagicNumber of the position
         //--- set the price and order type depending on the position type
         if(type==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
           }
         else
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }
         //--- output information about the closure
         PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
         //--- send the request
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // if unable to send the request, output the error code
         //--- information about the operation   
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         //---
        }
     }
//CTrade trade;
///trade.PositionClose(Symbol());

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool pub_is_new_candle(string pSymbol,ENUM_TIMEFRAMES pTime)
  {
   bool res=false;
   static datetime old_time;
   datetime new_time[];ArraySetAsSeries(new_time,true);
   if(CopyTime(pSymbol,pTime,0,1,new_time)==-1) return(false);
   if(old_time!=new_time[0])
     {
      res=true;
      old_time=new_time[0];
     }
   return(res);
  }
//+------------------------------------------------------------------+
