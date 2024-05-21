//+------------------------------------------------------------------+
//|                                        4AdvGrid-MT5-Research.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"
#property version   "1.00"

#include <Generic\HashMap.mqh>
#include "CDKAdvIndicator.mqh";

struct st1 {
  int field1;
};

struct st2 {
  int field1;
  int field2;
};

double GetPointValue2(string symbol)
  {
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double tickValue=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   double tickSize=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double pointValue=tickValue*(point/tickSize);
   return (pointValue);
  }
  
  
void InvestigateSuperTrend() {
  int handle_iCustom = iCustom(_Symbol, _Period, "SuperTrend", 
                                    2,
                                    PRICE_TYPICAL,
                                    2,
                                    1);
  
  //SetIndexBuffer(0, val, INDICATOR_DATA);
  //SetIndexBuffer(1, valc, INDICATOR_COLOR_INDEX);
  //SetIndexBuffer(2, trend, INDICATOR_CALCULATIONS);
  //SetIndexBuffer(3, ade, INDICATOR_CALCULATIONS);
  //SetIndexBuffer(4, ma, INDICATOR_CALCULATIONS);
  //SetIndexBuffer(5, price, INDICATOR_CALCULATIONS);                                    
                                    
  double buffer_val[];
  ArraySetAsSeries(buffer_val, true);
  double buffer_valc[];
  ArraySetAsSeries(buffer_valc, true);
  double buffer_trend[];
  ArraySetAsSeries(buffer_trend, true);
  
  
  int   fistBar  =  (int)ChartGetInteger(ChartID(), CHART_FIRST_VISIBLE_BAR);
  
  int count = 1000;   
  int start_pos = fistBar - count;  
  int copied = CopyBuffer(handle_iCustom, 0, start_pos, count, buffer_val);
  CopyBuffer(handle_iCustom, 1, start_pos, count, buffer_valc);
  CopyBuffer(handle_iCustom, 2, start_pos, count, buffer_trend);
  
  for(int i = 0; i < count; i++) {
    if(buffer_trend[i] != 0.0) {
      Print(StringFormat("(%d) %s: val=%f valc=%f trend=%f", 
                         i + start_pos, TimeToString(iTime(_Symbol, _Period, i + start_pos)), buffer_val[i], buffer_valc[i], buffer_trend[i]));
    }
  }    
  
  Print("firstBar: " + IntegerToString(fistBar));  
  Print("firstBar: " + iTime(_Symbol, _Period, fistBar));  
  
  
  double value = 0;
 
  CHashMap <uint, double>  m_ratio; 
  m_ratio.TrySetValue(0, 2.0);
  if (m_ratio.TryGetValue(0, value))
    Print(value);  
  
  
  m_ratio.TrySetValue(0, 0.5);
  if (m_ratio.TryGetValue(0, value))
    Print(value);  
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {

//input int                inpPeriod       = 50;            // Period
//input ENUM_APPLIED_PRICE inpPrice        = PRICE_TYPICAL; // Price
//input int                inpAtrDevPeriod = 5;             // Atr / standard deviation period
//input enUseWhat          inpUseWhat      = use_atr;       // Calculation method

//  double buffer_trend[];
//  ArraySetAsSeries(buffer_trend, true);
//  
//  int start_pos = 0;
//  int count = 1000;
//  int copied = CopyBuffer(handle_iCustom, 2, start_pos, count, buffer_trend);
//  
//  //for(int i = 0; i < count; i++) {
//  //  if(buffer_trend[i] != 0.0) {
//  //    Print(i, " ", buffer_trend[i]);
//  //  }
//  //}              
//
//  CDKAdvIndicator* ind = new CDKAdvIndicator;
//  ind.IndSymbol = _Symbol;
//  ind.TF = PERIOD_M15;
//  ind.IndPeriod = 50;
//  ind.Price = PRICE_TYPICAL;
//  ind.AtrDevPeriod = 5;
//  ind.UseWhat = 1;
//  ind.BarStart = 0;
//  ind.BarCount = 1;
//  ind.Init();
//  Print(ind.GetTrend());
//  
//  delete ind;
//  
//  ind = new CDKAdvIndicator;
//  ind.IndSymbol = _Symbol;
//  ind.TF = PERIOD_M15;
//  ind.IndPeriod = 50;
//  ind.Price = PRICE_TYPICAL;
//  ind.AtrDevPeriod = 5;
//  ind.UseWhat = 1;
//  ind.BarStart = 0;
//  ind.BarCount = 1;  
//  ind.Init();
//  
//  Print(ind.GetTrend());
  
  InvestigateSuperTrend();

}
//+------------------------------------------------------------------+
