//+------------------------------------------------------------------+
//|                                                        Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
#include<Trade\Trade.mqh>
//+------------------------------------------------------------------+
//input ENUM_TIMEFRAMES timeFrame=PERIOD_H4;
input double volume=0.05;
//input double bandsPeriod=20;
//input double tpPip=0.0050;
//input double slPipBuy=0.0050;
//input double slPipSell=0.0050;
//input double EntryCond=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

//  EventSetTimer(getTimeFrameSecond(timeFrame));
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(isNewBar())
      HN();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+


void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
void HN()
  {

   int digits=(int)SymbolInfoInteger("EURUSD",SYMBOL_DIGITS);

   int numberOfcandel=300;

   MqlRates ratesEURUSD[];
   CopyRates("EURUSD",Period(),0,numberOfcandel,ratesEURUSD);
   MqlRates ratesUSDJPY[];
   CopyRates("USDJPY",Period(),0,numberOfcandel,ratesUSDJPY);
   MqlRates ratesGBPUSD[];
   CopyRates("GBPUSD",Period(),0,numberOfcandel,ratesGBPUSD);
   MqlRates ratesUSDCAD[];
   CopyRates("USDCAD",Period(),0,numberOfcandel,ratesUSDCAD);
   MqlRates ratesUSDAUD[];
   CopyRates("USDAUD",Period(),0,numberOfcandel,ratesUSDAUD);
   MqlRates ratesUSDCHF[];
   CopyRates("USDCHF",Period(),0,numberOfcandel,ratesUSDCHF);
   MqlRates ratesEURJPY[];
   CopyRates("EURJPY",Period(),0,numberOfcandel,ratesEURJPY);

   MqlRates ratesEURGBP[];
   CopyRates("EURGBP",Period(),0,numberOfcandel,ratesEURGBP);
   MqlRates ratesEURCHF[];
   CopyRates("EURCHF",Period(),0,numberOfcandel,ratesEURCHF);

   MqlRates ratesEXY[300];

   for(int i=0;i<numberOfcandel;i++)
     {
      ratesEXY[i].time= ratesEURUSD[i].time;
      ratesEXY[i].open=(34.38805726 *pow(ratesEURUSD[i].open,0.3424)*pow(ratesEURJPY[i].open,0.2052)*pow(ratesEURGBP[i].open,0.3316)*pow(ratesEURCHF[i].open,0.1206));
      ratesEXY[i].high=(34.38805726 *pow(ratesEURUSD[i].high,0.3424)*pow(ratesEURJPY[i].high,0.2052)*pow(ratesEURGBP[i].high,0.3316)*pow(ratesEURCHF[i].high,0.1206));
      ratesEXY[i].low=(34.38805726 *pow(ratesEURUSD[i].low,0.3424)*pow(ratesEURJPY[i].low,0.2052)*pow(ratesEURGBP[i].low,0.3316)*pow(ratesEURCHF[i].low,0.1206));
      ratesEXY[i].close=(34.38805726 *pow(ratesEURUSD[i].close,0.3424)*pow(ratesEURJPY[i].close,0.2052)*pow(ratesEURGBP[i].close,0.3316)*pow(ratesEURCHF[i].close,0.1206));
      ratesEXY[i].tick_volume=(34.38805726 *pow(ratesEURUSD[i].tick_volume,0.3424)*pow(ratesEURJPY[i].tick_volume,0.2052)*pow(ratesEURGBP[i].tick_volume,0.3316)*pow(ratesEURCHF[i].tick_volume,0.1206));
      ratesEXY[i].real_volume=(34.38805726 *pow(ratesEURUSD[i].real_volume,0.3424)*pow(ratesEURJPY[i].real_volume,0.2052)*pow(ratesEURGBP[i].real_volume,0.3316)*pow(ratesEURCHF[i].real_volume,0.1206));
      ratesEXY[i].spread=(34.38805726 *pow(ratesEURUSD[i].spread,0.3424)*pow(ratesEURJPY[i].spread,0.2052)*pow(ratesEURGBP[i].spread,0.3316)*pow(ratesEURCHF[i].spread,0.1206));
     }

   ArrayGetAsSeries(ratesEXY);
   CustomRatesUpdate("HN_EXY",ratesEXY);

   int exySHandler=iMA("HN_EXY",Period(),12,0,MODE_EMA,PRICE_CLOSE);
   int exyLHandler=iMA("HN_EXY",Period(),32,0,MODE_EMA,PRICE_CLOSE);
   int dxySHandler=iMA("_DXY",Period(),12,0,MODE_EMA,PRICE_CLOSE);
   int dxyLHandler=iMA("_DXY",Period(),32,0,MODE_EMA,PRICE_CLOSE);

   double  exyS[],exyL[],dxyS[],dxyL[],diffEXY[],diffDXY[];

   CopyBuffer(exySHandler,0,0,1,exyS);
   CopyBuffer(exyLHandler,0,0,1,exyL);
   CopyBuffer(dxySHandler,0,0,1,dxyS);
   CopyBuffer(dxyLHandler,0,0,1,dxyL);

   ArraySetAsSeries(exyS,true);
   ArraySetAsSeries(exyL,true);
   ArraySetAsSeries(dxyS,true);
   ArraySetAsSeries(dxyL,true);

   if(exyS[0]-exyL[0]>0 && dxyS[0]-dxyL[0]<0)
     {//buy 
      if(PositionsTotal()<1)
        {
         MqlTradeRequest request1={0};
         MqlTradeResult result1={0};
         request1.symbol = "EURUSD";
         request1.volume = volume;
         request1.type=ORDER_TYPE_BUY;
         request1.action=TRADE_ACTION_DEAL;
         //request1.price = price;

         if(!OrderSend(request1,result1))
            PrintFormat("OrderSend error %d",GetLastError());
        }
     }
   else if(exyS[0]-exyL[0]<0 && dxyS[0]-dxyL[0]>0)
     {      //sell
      if(PositionsTotal()<1)
        {
         MqlTradeRequest request1={0};
         MqlTradeResult result1={0};
         request1.symbol = "EURUSD";
         request1.volume = volume;
         request1.type=ORDER_TYPE_SELL;
         request1.action=TRADE_ACTION_DEAL;
         //request1.price = price;

         if(!OrderSend(request1,result1))
            PrintFormat("OrderSend error %d",GetLastError());
        }
     }
   else
     {
      for(int i=0; i<PositionsTotal(); i++)
        {
         if(PositionSelect("EURUSD"))
           {
            CTrade trade;
            trade.PositionClose("EURUSD");
           }
        }
     }

//Print(exyS[0],"    ",exyL[0],"    ",dxyS[0],"    ",dxyL[0]);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openPosition(string pair,double vol,ENUM_ORDER_TYPE orderType,double price,double tp,double sl)
  {
   MqlTradeRequest request1={0};
   MqlTradeResult result1={0};
   request1.symbol = pair;
   request1.volume = vol;
   request1.type=orderType;
   request1.action= TRADE_ACTION_DEAL;
   request1.price = price;
   request1.tp=tp;
   request1.sl=sl;

   if(!OrderSend(request1,result1))
     {
      PrintFormat("OrderSend error %d",GetLastError());

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getTimeFrameSecond(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1: return 60;break;
      case PERIOD_M2: return 60*2;break;
      case PERIOD_M3: return 60*3;break;
      case PERIOD_M4: return 60*4;break;
      case PERIOD_M5: return 60*5;break;
      case PERIOD_M6: return 60*6;break;
      case PERIOD_M10: return 60*10;break;
      case PERIOD_M12: return 60*12;break;
      case PERIOD_M15: return 60*15;break;
      case PERIOD_M20: return 60*20;break;
      case PERIOD_M30: return 60*30;break;

      case PERIOD_H1: return 360;break;
      case PERIOD_H2: return 360*2;break;
      case PERIOD_H3: return 360*3;break;
      case PERIOD_H4: return 360*4;break;
      case PERIOD_H6: return 360*6;break;
      case PERIOD_H8: return 360*8;break;
      case PERIOD_H12: return 360*12;break;

      case PERIOD_D1: return 360*24;break;
      case PERIOD_W1: return 360*24*7;break;
      case PERIOD_MN1: return 360*24*30;break;
     }
   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar()
  {
   static datetime last_time=0;
   datetime lastbar_time=SeriesInfoInteger("EURUSD",Period(),SERIES_LASTBAR_DATE);
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
