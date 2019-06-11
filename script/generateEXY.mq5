//+------------------------------------------------------------------+
//|                                                  generateEXY.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int numberOfcandel=1000;
//---
   int filehandle=FileOpen("test23.prn",FILE_READ|FILE_WRITE|FILE_CSV);
   FileSeek(filehandle,0,SEEK_END);
   MqlRates ratesEURUSD[];
   CopyRates("EURUSD",PERIOD_M1,0,numberOfcandel,ratesEURUSD);
   MqlRates ratesUSDJPY[];
   CopyRates("USDJPY",PERIOD_M1,0,numberOfcandel,ratesUSDJPY);
   MqlRates ratesGBPUSD[];
   CopyRates("GBPUSD",PERIOD_M1,0,numberOfcandel,ratesGBPUSD);
   MqlRates ratesUSDCAD[];
   CopyRates("USDCAD",PERIOD_M1,0,numberOfcandel,ratesUSDCAD);
   MqlRates ratesUSDAUD[];
   CopyRates("USDAUD",PERIOD_M1,0,numberOfcandel,ratesUSDAUD);
   MqlRates ratesUSDCHF[];
   CopyRates("USDCHF",PERIOD_M1,0,numberOfcandel,ratesUSDCHF);
   MqlRates ratesEURJPY[];
   CopyRates("EURJPY",PERIOD_M1,0,numberOfcandel,ratesEURJPY);
//     MqlRates ratesEURJPY[];
//int copied=CopyRates("EURJPY",Period(),0,10000,ratesEURJPY);
   MqlRates ratesEURGBP[];
   CopyRates("EURGBP",PERIOD_M1,0,numberOfcandel,ratesEURGBP);
   MqlRates ratesEURCHF[];
   CopyRates("EURCHF",PERIOD_M1,0,numberOfcandel,ratesEURCHF);

   MqlRates ratesEXY[1000];

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

      //FileWrite(filehandle,TimeToString(ratesEURUSD[i].time,TIME_DATE),TimeToString(ratesEURUSD[i].time,TIME_SECONDS),
      //          (34.38805726 *pow(ratesEURUSD[i].open,0.3424)*pow(ratesEURJPY[i].open,0.2052)*pow(ratesEURGBP[i].open,0.3316)*pow(ratesEURCHF[i].open,0.1206)),
      //          (34.38805726 *pow(ratesEURUSD[i].high,0.3424)*pow(ratesEURJPY[i].high,0.2052)*pow(ratesEURGBP[i].high,0.3316)*pow(ratesEURCHF[i].high,0.1206)),
      //          (34.38805726 *pow(ratesEURUSD[i].low,0.3424)*pow(ratesEURJPY[i].low,0.2052)*pow(ratesEURGBP[i].low,0.3316)*pow(ratesEURCHF[i].low,0.1206)),
      //          (34.38805726 *pow(ratesEURUSD[i].close,0.3424)*pow(ratesEURJPY[i].close,0.2052)*pow(ratesEURGBP[i].close,0.3316)*pow(ratesEURCHF[i].close,0.1206)),
      //          (34.38805726 *pow(ratesEURUSD[i].tick_volume,0.3424)*pow(ratesEURJPY[i].tick_volume,0.2052)*pow(ratesEURGBP[i].tick_volume,0.3316)*pow(ratesEURCHF[i].tick_volume,0.1206)),
      //          (34.38805726 *pow(ratesEURUSD[i].real_volume,0.3424)*pow(ratesEURJPY[i].real_volume,0.2052)*pow(ratesEURGBP[i].real_volume,0.3316)*pow(ratesEURCHF[i].real_volume,0.1206)),
      //          (34.38805726 *pow(ratesEURUSD[i].spread,0.3424)*pow(ratesEURJPY[i].spread,0.2052)*pow(ratesEURGBP[i].spread,0.3316)*pow(ratesEURCHF[i].spread,0.1206))
      //          );
     }

  }
//+------------------------------------------------------------------+
