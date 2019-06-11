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
input    int counter=3;
input double x=0.3;
double SupportTemp[],ResistanceTemp[];//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ResistanceBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SupportBuffer,INDICATOR_DATA);
//SetIndexBuffer(2,ResistanceBuffer2,INDICATOR_DATA);
//SetIndexBuffer(3,SupportBuffer2,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//PlotIndexSetInteger(2,PLOT_ARROW,159);
//PlotIndexSetInteger(3,PLOT_ARROW,159);
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

   ArrayResize(ResistanceTemp,rates_total);
   ArrayResize(SupportTemp,rates_total);
//ArrayResize(ResistanceTemp2,rates_total);
//ArrayResize(SupportTemp2,rates_total);

   string lastPostionType="";
   int lastPostionSIndex=0,lastPostionRIndex=0;

   for(int i=counter;i<rates_total-counter;i++)
     {
      ResistanceBuffer[i]=NULL;
      SupportBuffer[i]=NULL;
      ResistanceTemp[i]=NULL;
      SupportTemp[i]=NULL;
      //ResistanceBuffer2[i]=NULL;
      //SupportBuffer2[i]=NULL;
      //ResistanceTemp2[i]=NULL;
      //SupportTemp2[i]=NULL;

      int cond1Counter=0,cond2Counter=0,cond3Counter=0,cond6Counter=0,cond5Counter=0,cond4Counter=0;

      for(int j=0;j<counter;j++)
        {
         if(high[i]>high[i-(j+1)])cond1Counter++;
         if(high[i]>high[i+(j+1)])cond1Counter++;

         if(low[i-(j+1)]<low[i-j]) cond2Counter++;//baraye saghf poshtesh low ha ba laye ham basshan
         if(high[i-j]>high[i+(j+1)]) cond3Counter++;//baraye saghf badesh low ha ba laye ham basshan

         if(low[i]<low[i-(j+1)])cond4Counter++;
         if(low[i]<low[i+(j+1)])cond4Counter++;

         if(high[i-(j+1)]>high[i-j]) cond5Counter++;//baraye KAF poshtesh High ha ba laye ham basshan
         if(low[i-j]<low[i+(j+1)]) cond6Counter++;//baraye KAF poshtesh High ha ba laye ham basshan
        }

      if(cond1Counter==counter*2 && cond2Counter>=counter*x && cond3Counter>=counter*x)
        {
         // ResistanceTemp[i]=high[i];
         if(lastPostionType!="R")
           {
            //  printf("inside RRRRR");
            lastPostionRIndex=i;
            lastPostionType="R";
            // ResistanceBuffer[i]=high[i]; 
            ResistanceTemp[i]=high[i];
           }
         else
           {
            if(high[i]>ResistanceTemp[lastPostionRIndex])
              {

               ResistanceTemp[i]=high[i];
               ResistanceTemp[lastPostionRIndex]=NULL;
               lastPostionRIndex=i;
              }

           }
        }

      //==============================================================================================================

      if(cond4Counter==counter*2 && cond5Counter>=counter*x && cond6Counter>=counter*x)
        {
         //   SupportTemp[i]=low[i];
         if(lastPostionType!="S")
           {
            //    printf("inside SSSS");
            lastPostionSIndex=i;
            lastPostionType="S";

            // SupportBuffer[i]=low[i];

            SupportTemp[i]=low[i];
           }
         else
           {
           // Print(time[i],"    now :",low[i],"   perv: ",SupportTemp[lastPostionSIndex],low[i]<SupportTemp[lastPostionSIndex]);
            if(low[i]<SupportTemp[lastPostionSIndex])
              {

               SupportTemp[i]=low[i];
               SupportTemp[lastPostionSIndex]=NULL;
               lastPostionSIndex=i;

              }

           }
        }
     }

   (ArrayCopy(SupportBuffer,SupportTemp));
   (ArrayCopy(ResistanceBuffer,ResistanceTemp));
//(ArrayCopy(SupportBuffer2,SupportTemp2));
//(ArrayCopy(ResistanceBuffer2,ResistanceTemp2));
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
