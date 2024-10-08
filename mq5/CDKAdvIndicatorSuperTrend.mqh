//+------------------------------------------------------------------+
//|                                    CDKAdvIndicatorSuperTrend.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Object.mqh>
#include "Include\DKStdLib\Common\DKStdLib.mqh";
#include "CDKAdvIndicator.mqh";

// SuperTrend Param ENUM
enum enUseWhat  {
   use_atr, // Use ATR for calculation
   use_dev  // Use standard deviation for calculation
};

string UseWhatToSrting(enUseWhat _enum) {
  string enum_str = EnumToString(_enum);
  StringReplace(enum_str, "use_", "");
  return enum_str;
}

class CDKAdvIndicatorSuperTrend : public CDKAdvIndicator {
protected:
  int m_handle;
public:
  int                      IndPeriod;
  ENUM_APPLIED_PRICE       AppliedPrice;
  int                      AtrDevPeriod;
  enUseWhat                UseWhat;
  uint                     MinAngle;
  
  void   CDKAdvIndicatorSuperTrend::Init();
  void  ~CDKAdvIndicatorSuperTrend() { IndicatorRelease(m_handle); };
  
  //string CDKAdvIndicatorSuperTrend::GetDescription();
  
  int    CDKAdvIndicatorSuperTrend::GetTrend();
};

void CDKAdvIndicatorSuperTrend::Init() {
  Name = "ST";
  m_handle = iCustom(IndSymbol, TF, "SuperTrend", IndPeriod, AppliedPrice, AtrDevPeriod, UseWhat);                                    
}


//string CDKAdvIndicatorSuperTrend::GetDescription() {
//  return StringFormat("%s:%s/%d-%d/%d/%s/%d/%s",
//                      Name,
//                      TimeframeToString(TF),
//                      BarStart,
//                      BarCount,
//                      
//                      IndPeriod,
//                      AppliedPriceToSrting(AppliedPrice),
//                      AtrDevPeriod,
//                      UseWhatToSrting(UseWhat));
//}

int CDKAdvIndicatorSuperTrend::GetTrend() {
  double buffer_trend[];
  ArraySetAsSeries(buffer_trend, true);
  
  int trend = 0;
  // 1 - valc buffer - line color
  // 2 - trend value buffer
  // Sometimes trend is not same with line color
  // So to detect trend now we decide to use line color from valc 
  //int copied = CopyBuffer(m_handle, 2, BarStart, BarCount, buffer_trend); // 2 - trend buffer
  int copied = CopyBuffer(m_handle, 1, BarStart, BarCount, buffer_trend); // 1 - valc buffer as line color
  if (copied > 0) {
    trend = (int)buffer_trend[0];
    datetime dt_0 = iTime(IndSymbol, TF, 0);
    for(uint i = 1; i < BarCount; i++) {
      datetime dt_i = iTime(IndSymbol, TF, i);
      if (buffer_trend[i] != trend) return 0;
    }                              
  }  

  if (trend == 2) trend = -1; // 2 - red color for sell trend
  if (trend != 1 && trend != -1) trend = 0;
  
  // Check min angle
  if(trend != 0 && MinAngle > 0) {
    double st[];
    if(CopyBuffer(m_handle, 0, 0, 2, st)<2) 
      return 0;
    
    CSymbolInfo sym_info;
    if(!sym_info.Name(IndSymbol))
      return 0;
      
    double angle = MathArctan((st[1]-st[0]) / sym_info.Point());
    angle = angle*180/M_PI;
    if(angle<MinAngle)
      return 0;
  }
  
  return trend;
}