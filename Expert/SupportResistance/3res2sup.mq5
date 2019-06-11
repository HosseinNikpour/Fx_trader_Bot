//+------------------------------------------------------------------+
//|                                                     3res2sup.mq5 |
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

input double volume=0.01;
input double tp_pip=0.0005;
input double sl_pip=0.0005;
//+------------------------------------------------------------------+
double Support1=-1,Support2=-1,Support3=-1,Resistance1=-1,Resistance2=-1,Resistance3=-1;
double rsiSupport1=-1,rsiSupport2=-1,rsiSupport3=-1,rsiResistance1=-1,rsiResistance2=-1,rsiResistance3=-1;
int Support1Index,Support2Index,Support3Index,Resistance1Index,Resistance2Index,Resistance3Index;
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
   if(isNewBar())
     {
      checkOrderForClose();
      findSupportResistance();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void findSupportResistance()
  {
   int digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);

   int numberOfCandels=100;
   double SupportTemp[100],ResistanceTemp[100];

   int counter=3;
   double x=0.3;

   MqlRates rates[];
   int copied=CopyRates(Symbol(),Period(),0,numberOfCandels,rates);

   string lastPostionType="";
   int lastPostionSIndex=0,lastPostionRIndex=0;

   for(int i=3;i<numberOfCandels-3;i++)
     {
      ResistanceTemp[i]=-1;
      SupportTemp[i]=-1;
      int cond1Counter=0,cond2Counter=0,cond3Counter=0,cond6Counter=0,cond5Counter=0,cond4Counter=0;

      for(int j=0;j<counter;j++)
        {
         if(rates[i].high>rates[i-(j+1)].high)cond1Counter++;
         if(rates[i].high>rates[i+(j+1)].high)cond1Counter++;

         if(rates[i-(j+1)].low<rates[i-j].low) cond2Counter++;//baraye saghf poshtesh low ha ba laye ham basshan
         if(rates[i-j].high>rates[i+(j+1)].high) cond3Counter++;//baraye saghf badesh low ha ba laye ham basshan

         if(rates[i].low<rates[i-(j+1)].low)cond4Counter++;
         if(rates[i].low<rates[i+(j+1)].low)cond4Counter++;

         if(rates[i-(j+1)].high>rates[i-j].high) cond5Counter++;//baraye KAF poshtesh High ha ba laye ham basshan
         if(rates[i-j].low<rates[i+(j+1)].low) cond6Counter++;//baraye KAF poshtesh High ha ba laye ham basshan
        }

      if(cond1Counter==counter*2 && cond2Counter>=counter*x && cond3Counter>=counter*x)
        {
         if(lastPostionType!="R")
           {
            lastPostionRIndex=i;
            lastPostionType="R";
            ResistanceTemp[i]=rates[i].high;
           }
         else
           {
            if(rates[i].high>ResistanceTemp[lastPostionRIndex])
              {
               ResistanceTemp[i]=rates[i].high;
               ResistanceTemp[lastPostionRIndex]=NULL;
               lastPostionRIndex=i;
              }
           }
        }
      //==============================================================================================================
      if(cond4Counter==counter*2 && cond5Counter>=counter*x && cond6Counter>=counter*x)
        {
         if(lastPostionType!="S")
           {
            lastPostionSIndex=i;
            lastPostionType="S";
            SupportTemp[i]=rates[i].low;
           }
         else
           {
            if(rates[i].low<SupportTemp[lastPostionSIndex])
              {
               SupportTemp[i]=rates[i].low;
               SupportTemp[lastPostionSIndex]=NULL;
               lastPostionSIndex=i;
              }
           }
        }
     }

   Support1=-1;Support2=-1;Support3=-1;Resistance1=-1;Resistance2=-1;Resistance3=-1;
   rsiSupport1=-1;rsiSupport2=-1;rsiSupport3=-1;rsiResistance1=-1;rsiResistance2=-1;rsiResistance3=-1;
   Support1Index=-1;Support2Index=-1;Support3Index=-1;Resistance1Index=-1;Resistance2Index=-1;Resistance3Index=-1;

   for(int i=numberOfCandels-4;i>=0;i--)
     {
      if(SupportTemp[i]>0)
        {
         if(Support1<0) {Support1=SupportTemp[i];Support1Index=i;}
         else if(Support2<0) {Support2=SupportTemp[i];Support2Index=i;}
         else if(Support3<0) {Support3=SupportTemp[i];Support3Index=i;}
        }
      if(ResistanceTemp[i]>0)
        {
         if(Resistance1<0){Resistance1=ResistanceTemp[i];Resistance1Index=i;}
         else  if(Resistance2<0){Resistance2=ResistanceTemp[i];Resistance2Index=i;}
         else  if(Resistance3<0){Resistance3=ResistanceTemp[i];Resistance3Index=i;}
        }
     }

   if(OrdersTotal()<1)
     {
      double  values[];
      if((Support1<Support2 && Support2<Support3) && (Resistance1<Resistance2))//&& 
        {
         if(Resistance1<Support3)//check macdi
           {
            int  macdHandle=iMACD(Symbol(),0,12,26,9,PRICE_CLOSE);
            CopyBuffer(macdHandle,MAIN_LINE,1,100,values);
            ArraySetAsSeries(values,true);
           }
         else//rsi
           {
            int  RSIHandle=iRSI(Symbol(),0,14,PRICE_CLOSE);
            CopyBuffer(RSIHandle,MAIN_LINE,1,100,values);
            ArraySetAsSeries(values,true);
           }

         if((values[98-Support1Index]>values[98-Support2Index]))
           {
            MqlTradeRequest request1={0};
            MqlTradeResult result1={0};
            request1.symbol = Symbol();
            request1.volume = volume;
            request1.type=ORDER_TYPE_BUY_STOP;
            request1.action=TRADE_ACTION_PENDING;
            request1.type_filling=ORDER_FILLING_FOK;
            request1.price=NormalizeDouble(Resistance1,digits);
            request1.tp=NormalizeDouble(Resistance2-tp_pip,digits);
            request1.sl=NormalizeDouble(Support1-sl_pip,digits);

            if(!OrderSend(request1,result1))
              {
               PrintFormat("OrderSend error %d",GetLastError());
               Print("BUY     price : ",request1.price,"    tp : "+request1.tp,"    sl:  ",request1.sl);
              }
           }
        }
      else if((Resistance1>Resistance2 && Resistance2>Resistance3) && (Support1>Support2) )//&& 
        {
        if(Support1>Resistance3)//check macdi
           {
            int  macdHandle=iMACD(Symbol(),0,12,26,9,PRICE_CLOSE);
            CopyBuffer(macdHandle,MAIN_LINE,1,100,values);
            ArraySetAsSeries(values,true);
           }
         else//rsi
           {
            int  RSIHandle=iRSI(Symbol(),0,14,PRICE_CLOSE);
            CopyBuffer(RSIHandle,MAIN_LINE,1,100,values);
            ArraySetAsSeries(values,true);
           }
           
           if(values[98-Resistance1Index]<values[98-Resistance2Index]){
         MqlTradeRequest request1={0};
         MqlTradeResult result1={0};
         request1.symbol = Symbol();
         request1.volume = volume;
         request1.type=ORDER_TYPE_SELL_STOP;
         request1.action=TRADE_ACTION_PENDING;
         request1.type_filling=ORDER_FILLING_IOC;
         request1.price=NormalizeDouble(Support1,digits);
         request1.tp=NormalizeDouble(Support2-tp_pip,digits);
         request1.sl=NormalizeDouble(Resistance1+sl_pip,digits);
         // request1.deviation=8;

         if(!OrderSend(request1,result1))
           {
            PrintFormat("OrderSend error %d",GetLastError());
            Print("SELL     price : ",request1.price,"    tp : "+request1.tp,"    sl:  ",request1.sl);
           }
        }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar()
  {
   static datetime last_time=0;
   datetime lastbar_time=SeriesInfoInteger(Symbol(),Period(),SERIES_BARS_COUNT);
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
void checkOrderForClose()
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      ulong ticket=OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if((ENUM_ORDER_TYPE) OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_STOP)
           {
            if(iClose(Symbol(),Period(),0)<OrderGetDouble(ORDER_SL))
              {
               CTrade *trade=new CTrade();
               trade.OrderDelete(ticket);
               delete trade;
              }

           }
         else if((ENUM_ORDER_TYPE) OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_STOP)
           {
            if(iClose(Symbol(),Period(),0)>OrderGetDouble(ORDER_SL))
              {
               CTrade *trade=new CTrade();
               trade.OrderDelete(ticket);
               delete trade;
              }

           }
        }
     }
  }
//+------------------------------------------------------------------+
void checkPositionForClose()
  {
   for(int i=0; i<PositionsTotal(); i++)
     {
      if(PositionSelect(Symbol()))
        {
         if(((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) && Resistance1<Resistance2)
           {
            CTrade trade;
            trade.PositionClose(Symbol());
           }
         else if(((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) && Support1>Support2)
           {
            CTrade trade;
            trade.PositionClose(Symbol());
           }
        }
     }
  }
//+------------------------------------------------------------------+
