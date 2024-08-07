//+------------------------------------------------------------------+
//|                                           CDKAdvIndicatorADX.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Object.mqh>
#include "Include\DKStdLib\Common\DKStdLib.mqh";
#include "CDKAdvIndicator.mqh";


class CDKAdvIndicatorADXTrend : public CDKAdvIndicator {
protected:
  int m_handle;
public:
  int                      MAPeriod;
  int                      ADXTrendLine;
  
  void   CDKAdvIndicatorADXTrend::Init();
  void  ~CDKAdvIndicatorADXTrend() { IndicatorRelease(m_handle); };
  
  //string CDKAdvIndicatorADXTrend::GetDescription();
  
  int    CDKAdvIndicatorADXTrend::GetTrend();
};

void CDKAdvIndicatorADXTrend::Init() {
  Name = "AXD";
  m_handle = iCustom(IndSymbol, TF, "ADXTrendDetector", MAPeriod, ADXTrendLine);
}

//string CDKAdvIndicatorADXTrend::GetDescription() {
//  return StringFormat("%s:%s/%d-%d/%d/%d",
//                      Name,
//                      TimeframeToString(TF),
//                      BarStart,
//                      BarCount,
//                      
//                      MAPeriod,
//                      ADXTrendLine
//                      );
//}

int CDKAdvIndicatorADXTrend::GetTrend() {
  double buffer_trend[];
  ArraySetAsSeries(buffer_trend, true);
  
  int trend = 0;
  int copied = CopyBuffer(m_handle, 0, BarStart, BarCount, buffer_trend); 
  if (copied > 0) {
    trend = (int)buffer_trend[0];
    datetime dt_0 = iTime(IndSymbol, TF, 0);
    for(uint i=1; i < BarCount; i++) {
      datetime dt_i = iTime(IndSymbol, TF, i);
      int new_trend = (int)buffer_trend[i];
      if (trend != new_trend) return 0;
    }            
  }  

  return trend;
}