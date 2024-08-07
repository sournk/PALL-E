//+------------------------------------------------------------------+
//|                                           CDKAdvIndicatorRSI.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Object.mqh>
#include "Include\DKStdLib\Common\DKStdLib.mqh";
#include "CDKAdvIndicator.mqh";


class CDKAdvIndicatorRSI : public CDKAdvIndicator {
protected:
  int m_handle;
public:
  int                      MAPeriod;
  ENUM_APPLIED_PRICE       AppliedPrice;
  
  double                   SellValue;
  double                   BuyValue;
  
  void   CDKAdvIndicatorRSI::Init();
  void  ~CDKAdvIndicatorRSI() { IndicatorRelease(m_handle); };
  
  //string CDKAdvIndicatorRSI::GetDescription();
  
  int    CDKAdvIndicatorRSI::GetTrend();
};

void CDKAdvIndicatorRSI::Init() {
  Name = "RSI";
  m_handle = iRSI(IndSymbol, TF, MAPeriod, AppliedPrice);
}

//string CDKAdvIndicatorRSI::GetDescription() {
//  return StringFormat("%s:%s/%d-%d/%d/%s/S<%.1f/B>%.1f",
//                      Name,
//                      TimeframeToString(TF),
//                      BarStart,
//                      BarCount,
//                      
//                      MAPeriod,
//                      AppliedPriceToSrting(AppliedPrice),
//                      SellValue,
//                      BuyValue);
//}

int CDKAdvIndicatorRSI::GetTrend() {
  double buffer_trend[];
  ArraySetAsSeries(buffer_trend, true);
  
  int trend = 0;
  int copied = CopyBuffer(m_handle, 0, BarStart, BarCount, buffer_trend); 
  if (copied > 0) {
    if (buffer_trend[0] > BuyValue)  trend = +1;
    if (buffer_trend[0] < SellValue) trend = -1;
    datetime dt_0 = iTime(IndSymbol, TF, 0);
    for(uint i = 1; i < BarCount; i++) {
      datetime dt_i = iTime(IndSymbol, TF, i);
      int new_trend = 0;
      if (buffer_trend[0] > BuyValue)  new_trend = +1;
      if (buffer_trend[0] < SellValue) new_trend = -1;    
      
      if (trend != new_trend) return 0;
    }            
  }  

  return trend;
}