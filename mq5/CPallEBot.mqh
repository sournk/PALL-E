//+------------------------------------------------------------------+
//|                                                    CPallEBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>
#include <Arrays\ArrayDouble.mqh>

#include "Include\DKStdLib\Common\DKStdLib.mqh"
#include "Include\DKStdLib\Logger\DKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "Include\DKStdLib\NewBarDetector\DKNewBarDetector.mqh"

#include "CPallEGrid.mqh";
#include "CDKAdvIndicator.mqh";
#include "CDKAdvIndicatorSuperTrend.mqh";
#include "CDKAdvIndicatorRSI.mqh";
#include "CDKAdvIndicatorADX.mqh";
#include "CDKAdvIndicatorZigZag.mqh";


class CPallEBot {
protected:
  DKNewBarDetector         NewBarDetector;
public:
  CDKSymbolInfo            Sym;
  ENUM_POSITION_TYPE       Dir;
  string                   CommentPrefix;
  ulong                    MagicBuy;
  ulong                    MagicSell;

  bool                     BuyFirstEnabled;
  bool                     BuyNextEnabled;
  bool                     SellFirstEnabled;
  bool                     SellNextEnabled;
  bool                     TwoGridsAtOneTime;

  uint                     MaxTrades;
  ENUM_MM_TYPE             MMType;
  double                   MMValue;
  double                   GridLossMax;  
  
  double                   LotMultiplierDefault;
  string                   LotMultiplierCustom;
  bool                     LotMultiplierToFullVolume;

  uint                     StepDefault;
  string                   StepCustom;
  
  uint                     TakeProfitDefault;
  string                   TakeProfitCustom;
  
  uint                     DelayDefaultMin;                                 // 2.GS.DPD: Delay between Pos Default, min
  string                   DelayCustomMin;                                  // 2.GS.DPC: Delay between Pos Custom, min  
  
  CHashMap<uint, string>   GridSizeIndListMap;

  // Must be set direclty
  DKLogger                 logger;

  CPallEGrid               grid_buy;
  CPallEGrid               grid_sell;

  CDKTrade                 TradeBuy;
  CDKTrade                 TradeSell;

  CDKAdvIndicatorRSI*      CPallEBot::InitIndicatorRSI(const ENUM_TIMEFRAMES _tf, const int _ma_period, const ENUM_APPLIED_PRICE _applied_price, 
                                                       const double _sell_value, const double _buy_value,
                                                       const uint _bar_start, const uint _bar_count);
                                                       
  CDKAdvIndicatorSuperTrend* CPallEBot::InitIndicatorST(const ENUM_TIMEFRAMES _tf, const int _period, const ENUM_APPLIED_PRICE _applied_price, 
                                                        const int _atr_dev_period, const enUseWhat _use_what,
                                                        const uint _bar_start, const uint _bar_count,
                                                        const uint _min_angle);
  CDKAdvIndicatorMATrend* CPallEBot::InitIndicatorMATrend(const ENUM_TIMEFRAMES _tf, const int _ma_period, 
                                                          const uint _bar_start, const uint _bar_count);
  CDKAdvIndicatorADXTrend* CPallEBot::InitIndicatorADXTrend(const ENUM_TIMEFRAMES _tf, const int _ma_period, const int _adx_trernd_line, 
                                                            const uint _bar_start, const uint _bar_count);
  CDKAdvIndicatorZigZagTrend* CPallEBot::InitIndicatorZigZagTrend(const ENUM_TIMEFRAMES _tf, const int _depth, const int _deviation, const int _backstep, const bool _strict,
                                                                  const uint _bar_start, const uint _bar_count);
                                                            
                                                             
  void                     CPallEBot::AddIndicator(CDKAdvIndicator* _ind, const string _applied_to_grid_size);
  CDKAdvIndicator*         CPallEBot::GetIndicatorByIndex(const int _idx);
                                                        

  void                     CPallEBot::SetLotMultiplier(CPallEGrid& _grid, CHashMap<uint, double>& _hash);
  void                     CPallEBot::SetStep(CPallEGrid& _grid, CHashMap<uint, double>& _hash);
  void                     CPallEBot::SetTakeProfit(CPallEGrid& _grid, CHashMap<uint, double>& _hash);
  void                     CPallEBot::SetDelay(CPallEGrid& _grid, CHashMap<uint, double>& _hash);
  void                     CPallEBot::SetFilterIndicators(CPallEGrid& _grid, CHashMap<uint, double>& _hash);
  void                     CPallEBot::Parse(string _str, CHashMap<uint, double>& _hash);
  void                     CPallEBot::Init();
  
  void                     CPallEBot::ShowComment();
  

  // Event Handlers
  void                     CPallEBot::OnTick(void);
  void                     CPallEBot::OnTimer(void);
  
  void                     CPallEBot::CPallEBot(void);
  void                     CPallEBot::~CPallEBot(void);
};

//+------------------------------------------------------------------+
//| Update current grid status
//+------------------------------------------------------------------+
void CPallEBot::ShowComment() {
  if (MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) return;

  string comment = "\n";
  comment += TimeToString(TimeCurrent()) + "\n\n";
  comment += "BUY GRID: " + grid_buy.GetDescription() + "\n";  
  comment += "SELL GRID: " + grid_sell.GetDescription() + "\n";  
  
  Comment(comment);
}

//+------------------------------------------------------------------+
//| Create CDKAdvIndicatorSuperTrend with ind inputs
//+------------------------------------------------------------------+
CDKAdvIndicatorSuperTrend* CPallEBot::InitIndicatorST(const ENUM_TIMEFRAMES _tf, const int _period, const ENUM_APPLIED_PRICE _applied_price, 
                                                      const int _atr_dev_period, const enUseWhat _use_what,
                                                      const uint _bar_start, const uint _bar_count,
                                                      const uint _min_angle) {
  CDKAdvIndicatorSuperTrend* ind = new CDKAdvIndicatorSuperTrend;
  ind.IndSymbol = _Symbol;
  ind.TF = _tf;
  ind.BarStart = _bar_start;
  ind.BarCount = _bar_count;
  
  ind.IndPeriod = _period;
  ind.AppliedPrice = _applied_price;
  ind.AtrDevPeriod = _atr_dev_period;
  ind.UseWhat = _use_what;
  ind.MinAngle = _min_angle;

  ind.Init();
  
  return ind;
}

//+------------------------------------------------------------------+
//| Create CDKAdvIndicatorRSI with ind inputs
//+------------------------------------------------------------------+
CDKAdvIndicatorRSI* CPallEBot::InitIndicatorRSI(const ENUM_TIMEFRAMES _tf, const int _ma_period, const ENUM_APPLIED_PRICE _applied_price, 
                                                const double _sell_value, const double _buy_value,
                                                const uint _bar_start, const uint _bar_count) {
  CDKAdvIndicatorRSI* ind = new CDKAdvIndicatorRSI;
  ind.IndSymbol = _Symbol;
  ind.TF = _tf;
  ind.BarStart = _bar_start;
  ind.BarCount = _bar_count;
    
  ind.MAPeriod = _ma_period;
  ind.AppliedPrice = _applied_price;
  ind.SellValue = _sell_value;
  ind.BuyValue = _buy_value;
  ind.Init();
  
  return ind;
}

//+------------------------------------------------------------------+
//| Create CDKAdvIndicatorMATrend with ind inputs
//+------------------------------------------------------------------+
CDKAdvIndicatorMATrend* CPallEBot::InitIndicatorMATrend(const ENUM_TIMEFRAMES _tf, const int _ma_period, 
                                                        const uint _bar_start, const uint _bar_count) {
  CDKAdvIndicatorMATrend* ind = new CDKAdvIndicatorMATrend;
  ind.IndSymbol = _Symbol;
  ind.TF = _tf;
  ind.BarStart = _bar_start;
  ind.BarCount = _bar_count;
    
  ind.MAPeriod = _ma_period;
  ind.Init();
  
  return ind;
}

//+------------------------------------------------------------------+
//| Create CDKAdvIndicatorADXTrend with ind inputs
//+------------------------------------------------------------------+
CDKAdvIndicatorADXTrend* CPallEBot::InitIndicatorADXTrend(const ENUM_TIMEFRAMES _tf, const int _ma_period, const int _adx_trernd_line, 
                                                          const uint _bar_start, const uint _bar_count) {
  CDKAdvIndicatorADXTrend* ind = new CDKAdvIndicatorADXTrend;
  ind.IndSymbol = _Symbol;
  ind.TF = _tf;
  ind.BarStart = _bar_start;
  ind.BarCount = _bar_count;
    
  ind.MAPeriod = _ma_period;
  ind.ADXTrendLine = _adx_trernd_line;
  ind.Init();
  
  return ind;
}

//+------------------------------------------------------------------+
//| Create CDKAdvIndicatorZigZagTrend with ind inputs
//+------------------------------------------------------------------+
CDKAdvIndicatorZigZagTrend* CPallEBot::InitIndicatorZigZagTrend(const ENUM_TIMEFRAMES _tf, const int _depth, const int _deviation, const int _backstep, const bool _strict,
                                                                const uint _bar_start, const uint _bar_count){
  CDKAdvIndicatorZigZagTrend* ind = new CDKAdvIndicatorZigZagTrend;
  ind.IndSymbol = _Symbol;
  ind.TF = _tf;
  ind.BarStart = _bar_start;
  ind.BarCount = _bar_count;
    
  ind.Depth = _depth;
  ind.Deviation = _deviation;
  ind.Backstep = _backstep;
  ind.Strict = _strict;
  ind.Init();
  
  return ind;
}

//+------------------------------------------------------------------+
//| And indicator to filter for grid size
//+------------------------------------------------------------------+
void CPallEBot::AddIndicator(CDKAdvIndicator* _ind, string _applied_to_grid_size) {
  StringReplace(_applied_to_grid_size, " ", "");
  string grid_size[];
  StringSplit(_applied_to_grid_size, StringGetCharacter(";", 0), grid_size);
  for (int i=0; i<ArraySize(grid_size); i++){
    string intervals[];
    StringSplit(grid_size[i], StringGetCharacter("-", 0), intervals);
    int idx_from = (int)StringToInteger(intervals[0]);
    int idx_to = (int)StringToInteger(intervals[0]);
    if (ArraySize(intervals) == 2)
      idx_to = (int)StringToInteger(intervals[1]);
      
    for (int j=idx_from; j<=idx_to; j++) {
      grid_buy.SetFilterIndicator(j, _ind);
      grid_sell.SetFilterIndicator(j, _ind);
    }
  }
}

//+------------------------------------------------------------------+
//| Set Custom Lot Muliplier
//+------------------------------------------------------------------+
void CPallEBot::SetLotMultiplier(CPallEGrid& _grid, CHashMap<uint, double>& _hash) {
  double val=0.0;
  for (uint i=0; i<=MaxTrades; i++) 
    if (_hash.TryGetValue(i, val)) 
      _grid.SetRatio(i, val);
    else 
      _grid.SetRatio(i, LotMultiplierDefault);
}

//+------------------------------------------------------------------+
//| Set Custom Step
//+------------------------------------------------------------------+
void CPallEBot::SetStep(CPallEGrid& _grid, CHashMap<uint, double>& _hash) {
  double val=0.0;
  for (uint i=0; i<=MaxTrades; i++) 
    if (_hash.TryGetValue(i, val)) 
      _grid.SetStep(i, (int)val);
    else 
      _grid.SetStep(i, StepDefault);
}

//+------------------------------------------------------------------+
//| Set Custom TP
//+------------------------------------------------------------------+
void CPallEBot::SetTakeProfit(CPallEGrid& _grid, CHashMap<uint, double>& _hash) {
  double val=0.0;
  for (uint i=0; i<=MaxTrades; i++) 
    if (_hash.TryGetValue(i, val)) 
      _grid.SetTakeProfit(i, (int)val);
    else 
      _grid.SetTakeProfit(i, TakeProfitDefault);
}

//+------------------------------------------------------------------+
//| Set Custom Delay
//+------------------------------------------------------------------+
void CPallEBot::SetDelay(CPallEGrid& _grid, CHashMap<uint, double>& _hash) {
  double val=0.0;
  for (uint i=0; i<=MaxTrades; i++) 
    if (_hash.TryGetValue(i, val)) 
      _grid.SetDelay(i, (int)val);
    else 
      _grid.SetDelay(i, DelayDefaultMin);
}

//+------------------------------------------------------------------+
//| Set Filter Indicators
//+------------------------------------------------------------------+
void CPallEBot::SetFilterIndicators(CPallEGrid& _grid, CHashMap<uint, double>& _hash) {
  double val=0.0;
  for (uint i=0; i<=MaxTrades; i++) 
    if (_hash.TryGetValue(i, val)) {
      CDKAdvIndicator* ind = GetIndicatorByIndex((int)val);
      if (ind != NULL)
        _grid.SetFilterIndicator(i, ind);
    }
}

//+------------------------------------------------------------------+
//| Parse string with list of custom values and put them to the _hash
//+------------------------------------------------------------------+
void CPallEBot::Parse(string _str, CHashMap<uint, double>& _hash) {
  _hash.Clear();
  StringReplace(_str, " ", "");
  
  uint start_idx = -1;
  uint finish_idx = -1;
  string chunk[];
  StringSplit(_str, StringGetCharacter(";", 0), chunk);
  for (int i=0; i<ArraySize(chunk); i++) {
    string grid_size[];
    StringSplit(chunk[i], StringGetCharacter("=", 0), grid_size);  
    if (ArraySize(grid_size) != 2) continue;
    
    if (StringFind(grid_size[0], "-") >= 0) {
      string interval[];
      StringSplit(grid_size[0], StringGetCharacter("-", 0), interval);
      if (ArraySize(interval) != 2) continue;
      
      start_idx = (uint)StringToInteger(interval[0]);
      finish_idx = (uint)StringToInteger(interval[1]);
    }
    else {
      start_idx = (uint)StringToInteger(grid_size[0]);
      finish_idx = (uint)StringToInteger(grid_size[0]);
    }
    
    for (uint j=start_idx; j<=finish_idx; j++)
      _hash.TrySetValue(j, StringToDouble(grid_size[1]));
  }
}

//+------------------------------------------------------------------+
//| Init Bot
//+------------------------------------------------------------------+
void CPallEBot::Init() {
  CPallEGridInitializer init_buy;
  CPallEGridInitializer init_sell;

  // Buy Initializer
  init_buy.Sym = Sym;
  init_buy.Dir = POSITION_TYPE_BUY;
  init_buy.CommentPrefix = StringFormat("%s.B", CommentPrefix);
  init_buy.Magic = MagicBuy;
  init_buy.FirstEnabled = BuyFirstEnabled;
  init_buy.NextEnabled = BuyNextEnabled;
  init_buy.MaxTrades = MaxTrades;
  init_buy.MMType = MMType;
  init_buy.MMValue = MMValue;
  init_buy.LotMultiplier = LotMultiplierDefault;
  init_buy.RatioToFullVolume = LotMultiplierToFullVolume;
  init_buy.Step = StepDefault;
  init_buy.TakeProfit = TakeProfitDefault;
  init_buy.GridLossMax = GridLossMax;
  init_buy.Delay = DelayDefaultMin;
  init_buy.Trade = TradeBuy;
  
  // Sell Initializer
  init_sell.Sym = Sym;
  init_sell.Dir = POSITION_TYPE_SELL;
  init_sell.CommentPrefix = StringFormat("%s.S", CommentPrefix);
  init_sell.Magic = MagicSell;
  init_sell.FirstEnabled = SellFirstEnabled;
  init_sell.NextEnabled = SellNextEnabled;
  init_sell.MaxTrades = MaxTrades;
  init_sell.MMType = MMType;
  init_sell.MMValue = MMValue;
  init_sell.LotMultiplier = LotMultiplierDefault;
  init_sell.RatioToFullVolume = LotMultiplierToFullVolume;
  init_sell.Step = StepDefault;
  init_sell.TakeProfit = TakeProfitDefault;
  init_sell.Delay = DelayDefaultMin;
  init_sell.GridLossMax = GridLossMax;
  init_sell.Trade = TradeSell;
  
  // Grids init  
  grid_buy.Init(init_buy);
  grid_sell.Init(init_sell); 
  
  grid_buy.SetLogger(GetPointer(logger));
  grid_sell.SetLogger(GetPointer(logger));
 
  // Set Custom Lot Muliplier to the grids
  CHashMap<uint, double> hash_dbl;
  Parse(LotMultiplierCustom, hash_dbl);
  SetLotMultiplier(grid_buy, hash_dbl);
  SetLotMultiplier(grid_sell, hash_dbl);
  
  // Set Custom Step to the grids
  Parse(StepCustom, hash_dbl);
  SetStep(grid_buy, hash_dbl);
  SetStep(grid_sell, hash_dbl);

  // Set Take Profit to the grids
  Parse(TakeProfitCustom, hash_dbl);
  SetTakeProfit(grid_buy, hash_dbl);
  SetTakeProfit(grid_sell, hash_dbl);
  
  // Set Delay to the grids
  Parse(DelayCustomMin, hash_dbl);
  SetDelay(grid_buy, hash_dbl);
  SetDelay(grid_sell, hash_dbl);
  
  
  NewBarDetector.AddTimeFrame(PERIOD_M1);
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CPallEBot::OnTick(void) {
  if (!NewBarDetector.CheckNewBarAvaliable(PERIOD_M1)) return;
  logger.Debug("New bar detected");
  
  ShowComment();
  
  if (grid_buy.Size() > 0 || TwoGridsAtOneTime || 
     (grid_buy.Size() <= 0 && !TwoGridsAtOneTime && grid_sell.Size() <= 0))
    grid_buy.OpenNext();
  grid_buy.SetTPFromBreakEven();
  
  if (grid_sell.Size() > 0 || TwoGridsAtOneTime || 
     (grid_sell.Size() <= 0 && !TwoGridsAtOneTime && grid_buy.Size() <= 0))
    grid_sell.OpenNext();
  grid_sell.SetTPFromBreakEven();
  
  grid_buy.CheckMaxSLAndCloseGrid();
  grid_sell.CheckMaxSLAndCloseGrid();
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CPallEBot::OnTimer(void) {
}

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CPallEBot::CPallEBot(void) {
}

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CPallEBot::~CPallEBot(void) {
  GridSizeIndListMap.Clear();
}