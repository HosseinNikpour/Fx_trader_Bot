//+------------------------------------------------------------------+
//|                                            SupportResistance.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Resistance
#property indicator_label1  "Resistance"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  4
//--- plot Support
#property indicator_label2  "Support"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  4
//--- indicator buffers
double ResistanceBuffer[],SupportBuffer[];
//hn SupportTemp[],ResistanceTemp[];//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ResistanceBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SupportBuffer,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

   for(int i=3;i<rates_total-3;i++)
     {
      bool cond1=high[i]>high[i-1] && high[i]>high[i-2] && high[i]>high[i-3] && high[i]>high[i+1] && high[i]>high[i+2] && high[i]>high[i+3] && high[i]>high[i+4];
      int cond2Counter=0,cond3Counter=0,cond6Counter=0,cond5Counter=0;
      if(close[i-3]<close[i-2]) cond2Counter++;
      if(close[i-2]<close[i-1]) cond2Counter++;
      if(close[i-1]<close[i]) cond2Counter++;

      if(close[i]>close[i+1]) cond3Counter++;
      if(close[i+1]>close[i+2]) cond3Counter++;
      if(close[i+2]>close[i+3]) cond3Counter++;
      // bool cond2=close[i-3]<close[i-2]&&close[i-2]<close[i-1]&&close[i-1]<close[i] ;
      // bool cond3=close[i]>close[i+1]&&close[i+1]>close[i+2]&&close[i+2]>close[i+3] ;
      if(cond1 && cond2Counter>1 && cond3Counter>1)
        {
         ResistanceBuffer[i]=high[i];
        }

      bool cond4=low[i]<low[i-1] && low[i]<low[i-2] && low[i]<low[i-3] && low[i]<low[i+1] && low[i]<low[i+2] && low[i]<low[i+3] && low[i]<low[i+4];
      if(close[i-3]>close[i-2]) cond6Counter++;
      if(close[i-2]>close[i-1]) cond6Counter++;
      if(close[i-1]>close[i]) cond6Counter++;

      if(close[i]<close[i+1]) cond5Counter++;
      if(close[i+1]<close[i+2]) cond5Counter++;
      if(close[i+2]<close[i+3]) cond5Counter++;
      //bool cond5=close[i-3]>close[i-2]&&close[i-2]>close[i-1]&&close[i-1]>close[i];
      //bool cond6=close[i]<close[i+1]&&close[i+1]<close[i+2]&&close[i+2]<close[i+3];
      if(cond4 && cond6Counter>1 && cond5Counter>1)
        {
         SupportBuffer[i]=low[i];
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
