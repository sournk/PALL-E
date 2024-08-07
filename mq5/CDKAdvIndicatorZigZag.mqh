//+------------------------------------------------------------------+
//|                                        CDKAdvIndicatorZigZag.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Object.mqh>
#include "Include\DKStdLib\Common\DKStdLib.mqh";
#include "CDKAdvIndicator.mqh";


class CDKAdvIndicatorZigZagTrend : public CDKAdvIndicator {
protected:
  int m_handle;
public:
  int                      Depth;
  int                      Deviation;
  int                      Backstep;
  bool                     Strict;
  
  void   CDKAdvIndicatorZigZagTrend::Init();
  void  ~CDKAdvIndicatorZigZagTrend() { IndicatorRelease(m_handle); };
  
  //string CDKAdvIndicatorADXTrend::GetDescription();
  
  int    CDKAdvIndicatorZigZagTrend::WrapStrict(const double _val);
  int    CDKAdvIndicatorZigZagTrend::GetTrend();
};

void CDKAdvIndicatorZigZagTrend::Init() {
  Name = "ZZ";
  m_handle = iCustom(IndSymbol, TF, "ZigZagTrendDetector", Depth, Deviation, Backstep);
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

int CDKAdvIndicatorZigZagTrend::WrapStrict(const double _val) {
  if (!Strict) {
    if (_val > 0.0) return +1;
    if (_val < 0.0) return -1;
    return 0;
  }
  
  if (_val > +0.5) return +1;
  if (_val < -0.5) return -1;
  return 0;  
}

int CDKAdvIndicatorZigZagTrend::GetTrend() {
  double buffer_trend[];
  ArraySetAsSeries(buffer_trend, true);
  
  int trend = 0;
  int copied = CopyBuffer(m_handle, 0, BarStart, BarCount, buffer_trend); 
  if (copied > 0) {
    trend = WrapStrict(buffer_trend[0]);
    datetime dt_0 = iTime(IndSymbol, TF, 0);
    for(uint i=1; i < BarCount; i++) {
      datetime dt_i = iTime(IndSymbol, TF, i);
      int new_trend = WrapStrict(buffer_trend[i]);
      if (trend != new_trend) return 0;
    }            
  }  

  return trend;
}