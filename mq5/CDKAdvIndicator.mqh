//+------------------------------------------------------------------+
//|                                              CDKAdvIndicator.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Object.mqh>
#include "Include\DKStdLib\Common\DKStdLib.mqh";

class CDKAdvIndicator : public CObject {
public:
  string                   Name;
  string                   IndSymbol;
  ENUM_TIMEFRAMES          TF;

  uint                     BarStart;
  uint                     BarCount;

  
  void virtual   CDKAdvIndicator::Init();
  
  string virtual CDKAdvIndicator::GetDescription();
  string         CDKAdvIndicator::GetTrendDescription(const int _trend);
  
  int virtual    CDKAdvIndicator::GetTrend();
};

void CDKAdvIndicator::Init() {
}

string CDKAdvIndicator::GetDescription() {
  return StringFormat("%s:%s",
                      Name,
                      TimeframeToString(TF));
  //return StringFormat("%s:%s/%d-%d",
  //                    Name,
  //                    TimeframeToString(TF),
  //                    BarStart,
  //                    BarCount);
}

string CDKAdvIndicator::GetTrendDescription(const int _trend) {
  if (_trend < 0) return "SELL";
  if (_trend > 0) return "BUY";
  
  return "NO";
}

int CDKAdvIndicator::GetTrend() {
  return 0;
}