//+------------------------------------------------------------------+
//|                                                   CPallEGrid.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Arrays\ArrayObj.mqh>
#include <Generic\HashMap.mqh>
#include <Trade\AccountInfo.mqh>

#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"
#include "Include\DKStdLib\TradingManager\CDKGridOneDirStepPos.mqh"

#include "CDKAdvIndicator.mqh";

struct CPallEGridInitializer {
  CDKSymbolInfo         Sym;
  ENUM_POSITION_TYPE    Dir;
  string                CommentPrefix;
  ulong                 Magic;

  bool                  FirstEnabled;
  bool                  NextEnabled;

  uint                  MaxTrades;
  ENUM_MM_TYPE          MMType;
  double                MMValue;
  double                LotMultiplier;
  bool                  RatioToFullVolume;

  uint                  Step;
  uint                  TakeProfit;
  uint                  Delay;
  
  double                GridLossMax;

  CDKTrade              Trade;
};

class CPallEGrid : public CDKGridOneDirStepPos {
 protected:
  CPallEGridInitializer Initializer;

  double                m_MMValue;
  double                m_GridMaxLoss;

  CHashMap<uint, CArrayObj*> FilterMap;

  int                   CPallEGrid::GetTrendByIndicatorArray(CArrayObj* _arr, string& _log);
 public:
  double                CPallEGrid::GetBaseVolumeForNextPosition();
  void                  CPallEGrid::Init(CPallEGridInitializer& _initializer);

  ulong                 CPallEGrid::OpenNext(const bool aIgnoreEntryCheck = false);
  bool                  CPallEGrid::CheckEntry();
  
  bool                  CPallEGrid::CheckMaxSLAndCloseGrid();

  double                CPallEGrid::SetInitialLot();
  bool                  CPallEGrid::SetFirstEnabled(const bool _first_enabled) { Initializer.FirstEnabled = _first_enabled; return Initializer.FirstEnabled; }

  uint                  CPallEGrid::SetFilterIndicator(const uint _grid_size, CDKAdvIndicator* _ind);

  bool                  CPallEGrid::HasFilterTrend(const uint _grid_size);
  int                   CPallEGrid::GetFilterTrend(const uint _grid_size, string& _log);

  void                  CPallEGrid::SetTakeProfitByATR();
  bool                  CPallEGrid::SetTPFromAverage();
  bool                  CPallEGrid::SetTPFromBreakEven();
  
  string                CPallEGrid::GetDescription();
};


//+------------------------------------------------------------------+
//| Init
//+------------------------------------------------------------------+
void CPallEGrid::Init(CPallEGridInitializer& _initializer) {
  Initializer = _initializer;
  m_GridMaxLoss = _initializer.GridLossMax;
  FilterMap.Clear();

  CDKGridOneDirStepPos::Init(Initializer.Sym.Name(), Initializer.Dir, Initializer.MaxTrades,
                             0.01, // Initial Lot
                             Initializer.Step, Initializer.LotMultiplier, Initializer.RatioToFullVolume, Initializer.TakeProfit, Initializer.Delay,
                             0,  // SL distance
                             Initializer.CommentPrefix,
                             Initializer.Magic, Initializer.Trade);                             
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPallEGrid::SetInitialLot() {
  double m_init_lots_prev = m_init_lots;
  double price = (m_dir == POSITION_TYPE_BUY) ? m_symbol.Ask() : m_symbol.Bid();
  m_init_lots = CalculateLotSuper(m_symbol.Name(), Initializer.MMType, Initializer.MMValue, price, 0);

  if (m_init_lots != m_init_lots_prev)
    Log(StringFormat("Changed init lot: GID=%s | LOT=%f->%f | DIR=%s | SIZE=%d/%d",
                     m_id, m_init_lots_prev, m_init_lots, GetDirectionDescription(), Size(), m_max_pos_count), DEBUG);

  return m_init_lots;
}
//
////+------------------------------------------------------------------+
////| Load: Add all open post to grid by Magic and Symbol
////+------------------------------------------------------------------+
//uint CDKGridOneDirStepPos::Load(const long aMagic) {
//  uint sizeBefore = Size();
//
//  // Put Direction to last add pos direction
//  if (CDKGridBase::Load(aMagic) > 0) {
//    CDKPositionInfo pos;
//    if (GetLast(pos)  && m_dir != pos.PositionType()) {
//      m_dir = pos.PositionType();
//      Log(StringFormat("Grid direction changed by loaded position: GRID=%s | DIR=%s", m_id, EnumToString(m_dir)), WARN);
//    }
//  }
//
//  return Size();
//}
//
////+------------------------------------------------------------------+
////| SetDirection
////+------------------------------------------------------------------+
//void CDKGridOneDirStepPos::SetDirection(const ENUM_POSITION_TYPE aDirection){
//  m_dir = aDirection;
//}
//
////+------------------------------------------------------------------+
////| GetDirection
////+------------------------------------------------------------------+
//ENUM_POSITION_TYPE CDKGridOneDirStepPos::GetDirection(){
//  return m_dir;
//}
//
////+------------------------------------------------------------------+
////| SetDefaultStep
////+------------------------------------------------------------------+
//void CDKGridOneDirStepPos::SetDefaultStep(const int aStepPoint) {
//  m_step_default = aStepPoint;
//}
//
////+------------------------------------------------------------------+
////| SetStep for specific pos in grid by idx
////+------------------------------------------------------------------+
//void CDKGridOneDirStepPos::SetStep(const uint aGridSize, const int aStepPoint) {
//  m_step.Add(aGridSize, aStepPoint);
//}
//
////+------------------------------------------------------------------+
////| GetStep
////+------------------------------------------------------------------+
//int CDKGridOneDirStepPos::GetStep(const uint aIdx) {
//  int value = 0;
//  if (m_step.TryGetValue(aIdx, value))
//    return value;
//
//  return m_step_default;
//}
//
////+------------------------------------------------------------------+
////| GetStep for last grid order
////+------------------------------------------------------------------+
//int CDKGridOneDirStepPos::GetStepLast(){
//  return GetStep(Size() - 1);
//}
//
////+------------------------------------------------------------------+
////| GetSetDefaultRatio
////+------------------------------------------------------------------+
//void CDKGridOneDirStepPos::SetDefaultRatio(const double aRatio) {
//  m_ratio_default = aRatio;
//}
//
////+------------------------------------------------------------------+
////| SetRatio
////+------------------------------------------------------------------+
//void CDKGridOneDirStepPos::SetRatio(const uint aGridSize, const double aRatio) {
//  m_ratio.Add(aGridSize, aRatio);
//}
//
////+------------------------------------------------------------------+
////| GetRatio
////+------------------------------------------------------------------+
//double CDKGridOneDirStepPos::GetRatio(const uint aIdx) {
//  double value = 0;
//  if (m_ratio.TryGetValue(aIdx, value))
//    return value;
//
//  return m_ratio_default;
//}
//
////+------------------------------------------------------------------+
////| GetRatio for last grid order
////+------------------------------------------------------------------+
//double CDKGridOneDirStepPos::GetRatioLast(){
//  return GetRatio(Size() - 1);
//}
//
////+------------------------------------------------------------------+
////| SetDefaultTakeProfit
////+------------------------------------------------------------------+
//void CDKGridOneDirStepPos::SetDefaultTakeProfit(const int aTakeProfitPoint) {
//  m_tp_default = aTakeProfitPoint;
//}
//
////+------------------------------------------------------------------+
////| SetTakeProfit
////+------------------------------------------------------------------+
//void CDKGridOneDirStepPos::SetTakeProfit(const uint aGridSize, const int aTakeProfitPoint) {
//  m_tp.Add(aGridSize, aTakeProfitPoint);
//}
//
////+------------------------------------------------------------------+
////| GetTakeProfit
////+------------------------------------------------------------------+
//int CDKGridOneDirStepPos::GetTakeProfit(const uint aIdx) {
//  int value = 0;
//  if (m_tp.TryGetValue(aIdx, value))
//    return value;
//
//  return m_tp_default;
//}
//
////+------------------------------------------------------------------+
////| GetTakeProfitLast
////+------------------------------------------------------------------+
//int CDKGridOneDirStepPos::GetTakeProfitLast(){
//  return GetTakeProfit(Size() - 1);
//}
//
//+------------------------------------------------------------------+
//| CheckEntry.
//+------------------------------------------------------------------+
bool CPallEGrid::CheckEntry() {
  if (!Initializer.NextEnabled) return false;
  if (Size() == 0 && !Initializer.FirstEnabled) return false;

  if (!CDKGridOneDirStepPos::CheckEntry()) return false;

  //Trend check
  bool res = true;
  string log_msg = "";
  bool trend_active = HasFilterTrend(Size());
  int trend = GetFilterTrend(Size(), log_msg);
  if (trend_active && trend <= 0 && m_dir == POSITION_TYPE_BUY)  res = false;
  if (trend_active && trend >= 0 && m_dir == POSITION_TYPE_SELL) res = false;  

  Log(StringFormat("%s/%d: RES=%d | GID=%s | DIR=%s | SIZE=%d/%d | %s",
                   __FUNCTION__, __LINE__,
                   trend, m_id, GetDirectionDescription(), Size(), m_max_pos_count,
                   (trend_active) ? "IND=" + log_msg : "NO_INDICATOR"
                  ),
      DEBUG);

  return res;
}

bool CPallEGrid::CheckMaxSLAndCloseGrid() {
  if(m_GridMaxLoss <= 0) return false;
  
  DKGridState state = GetState();
  if(state.Profit <= -1*m_GridMaxLoss) {
    int pos_cnt = (int)CloseAll();
    Log(StringFormat("%s/%d: POS_CNT=%d | GID=%s | DIR=%s | SIZE=%d/%d | LOSS=%f",
                   __FUNCTION__, __LINE__,
                   pos_cnt, m_id, GetDirectionDescription(), Size(), m_max_pos_count, state.Profit
                  ),
      INFO);
    return pos_cnt > 0;
  }
    
  return false;  
}

//+------------------------------------------------------------------+
//| GetBaseVolumeForNextPosition returns a base to calc next pos volume
//+------------------------------------------------------------------+
double CPallEGrid::GetBaseVolumeForNextPosition() {
  if (Size() > 0) {
    DKGridState state = GetState();
    return state.Volume;
  }
  return 0;
}

//+------------------------------------------------------------------+
//| Opens next pos
//+------------------------------------------------------------------+
ulong CPallEGrid::OpenNext(const bool aIgnoreEntryCheck = false) {
  if (!aIgnoreEntryCheck && !CheckEntry())
    return 0;

  // Check that grid has actual size
  if (Size() != OpenPosCount()) Load();
  if (Size() == 0) m_init_lots = SetInitialLot();

  return CDKGridOneDirStepPos::OpenNext(aIgnoreEntryCheck);
}

//+------------------------------------------------------------------+
//| Set TP to all grid orders from Average price
//+------------------------------------------------------------------+
bool CPallEGrid::SetTPFromAverage() {
  return CDKGridOneDirStepPos::SetTPFromAverage();
}

//+------------------------------------------------------------------+
//| Set TP to all grid orders from Breakeven price
//+------------------------------------------------------------------+
bool CPallEGrid::SetTPFromBreakEven() {
  return CDKGridOneDirStepPos::SetTPFromBreakEven();
}


//+------------------------------------------------------------------+
//| Returns grid summary text
//+------------------------------------------------------------------+
string CPallEGrid::GetDescription() {
  string res = CDKGridOneDirStepPos::GetDescription();

  // 2. Trend Info
  string trend;
  GetFilterTrend(Size(), trend);
 
  return res + StringFormat("TREND: %s \n", trend);
}

//+------------------------------------------------------------------+
//| Set Filter Indicator
//+------------------------------------------------------------------+
uint CPallEGrid::SetFilterIndicator(const uint _grid_size, CDKAdvIndicator* _ind) {
  CArrayObj* arr;
  if (!FilterMap.TryGetValue(_grid_size, arr))
    arr = new CArrayObj;

  arr.Add(_ind);
  FilterMap.TrySetValue(_grid_size, arr);

  return arr.Total();
}


//+------------------------------------------------------------------+
//| Returns compined trend of indicators assigned to grid size
//+------------------------------------------------------------------+
int CPallEGrid::GetTrendByIndicatorArray(CArrayObj* _arr, string& _log) {
  _log = "";
  int trend_first = 0;
  int trend_res = 0;

  CDKAdvIndicator* ind;
  if (_arr.Total() > 0) {
    ind = _arr.At(0);
    trend_first = ind.GetTrend();
    trend_res = trend_first;
  }

  for (int i = 0; i < _arr.Total(); i++) {
    ind = _arr.At(i);
    int trend = ind.GetTrend();
    _log += StringFormat("%s=%s; ", ind.GetDescription(), ind.GetTrendDescription(trend));
    if (trend != trend_first) trend_res = 0;
  }

  return trend_res;
}

//+------------------------------------------------------------------+
//| Returns Trend For Filter
//+------------------------------------------------------------------+
int CPallEGrid::GetFilterTrend(const uint _grid_size, string& _log) {
  CArrayObj* arr;
  if (FilterMap.TryGetValue(_grid_size, arr))
    return GetTrendByIndicatorArray(arr, _log);

  return 0;
}

//+------------------------------------------------------------------+
//| Returns Trend For Filter
//+------------------------------------------------------------------+
bool CPallEGrid::HasFilterTrend(const uint _grid_size) {
  CArrayObj* arr;
  if (FilterMap.TryGetValue(_grid_size, arr))
    return true;

  return false;
}
