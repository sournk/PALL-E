//+------------------------------------------------------------------+
//|                                                       PALL-E.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Trade\AccountInfo.mqh>

#include "Include\DKStdLib\Common\DKStdLib.mqh"
#include "Include\DKStdLib\Logger\DKLogger.mqh"
#include "Include\DKStdLib\License\DKLicense.mqh";
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"

#include "CDKAdvIndicatorSuperTrend.mqh";
#include "CDKAdvIndicatorRSI.mqh";
#include "CPallEBot.mqh";

#property script_show_inputs

input     group                    "01. TRADING SETTINGS"
input     bool                     InpTSBuyFirstEnabled                  = false;                               // 1.TS.BFE: BUY grid First order Enabled
input     bool                     InpTSBuyNextEnabled                   = false;                               // 1.TS.BNE: BUY grid Next order Enabled
input     bool                     InpTSSellFirstEnabled                 = false;                               // 1.TS.SFE: SELL grid First order Enabled
input     bool                     InpTSSellNextEnabled                  = false;                               // 1.TS.SNE: SELL grid Next order Enabled
input     bool                     InpTSTwoGridsAtOneTime                = false;                               // 1.TS.TGE: Two Grids Enabled at one time
input     uint                     InpTSSlippage                         = 2;                                   // 1.TS.SLP: Max Slippage allowed, point
input     ENUM_MM_TYPE             InpTSMMType                           = ENUM_MM_TYPE_FIXED_LOT;              // 1.TS.MMT: Money Managmnent Type
input     double                   InpTSMMValue                          = 0.01;                                // 1.TS.MMV: Money Managmnent Value
input     ulong                    InpTSMagicBuy                         = 202405201;                           // 1.TS.MGC: Magic Buy
input     ulong                    InpTSMagicSell                        = 202405202;                           // 1.TS.MGC: Magic Sell

input     group                    "02. GRID SETTINGS"
input     uint                     InpGSMaxTrades                        = 20;                                  // 2.GS.MT: Max grid Trades number
input     double                   InpGSLotMultiplierDefault             = 1.60;                                // 2.GS.LMD: Grid Lot Multiplier Default
input     string                   InpGSLotMultiplierCustom              = "";                                  // 2.GS.LMC: Grid Lot Multiplier Custom
input     uint                     InpGSStepPntDefault                   = 100;                                 // 2.GS.GSD: Grid Step distance Default, point
input     string                   InpGSStepPntCustom                    = "";                                  // 2.GS.GSC: Grid Step distance Custom, point
input     uint                     InpGSTPPntDefault                     = 100;                                 // 2.GS.TPD: Take Profit distance Default, point
input     string                   InpGSTPPntCustom                      = "";                                  // 2.GS.TPC: Take Profit distance Custom, point

input     group                    "INDICATOR: SUPERTREND-1"
input     ENUM_TIMEFRAMES          InpIndST1TF                            = PERIOD_M1;                          // ST1.TF: TimeFrame
input     int                      InpIndST1Period                        = 50;                                 // ST1.PE: Period
input     ENUM_APPLIED_PRICE       InpIndST1Price                         = PRICE_TYPICAL;                      // ST1.PR: Price
input     int                      InpIndST1AtrDevPeriod                  = 5;                                  // ST1.DP: ATR / Standard Deviation Period
input     enUseWhat                InpIndST1UseWhat                       = use_atr;                            // ST1.CM: Calculation Method
input     uint                     InpIndST1BarStart                      = 0;                                  // ST1.BS: Get trend Starting from Bar (0-current)
input     uint                     InpIndST1BarCount                      = 2;                                  // ST1.BC: Bar Count with same value to get trend
input     string                   InpIndST1GridSize                      = "";                                 // ST1.GS: Applies to the Grid Size

input     group                    "INDICATOR: SUPERTREND-2"
input     ENUM_TIMEFRAMES          InpIndST2TF                            = PERIOD_M5;                          // ST2.TF: TimeFrame
input     int                      InpIndST2Period                        = 50;                                 // ST2.PE: Period
input     ENUM_APPLIED_PRICE       InpIndST2Price                         = PRICE_TYPICAL;                      // ST2.PR: Price
input     int                      InpIndST2AtrDevPeriod                  = 5;                                  // ST2.DP: ATR / Standard Deviation Period
input     enUseWhat                InpIndST2UseWhat                       = use_atr;                            // ST2.CM: Calculation Method
input     uint                     InpIndST2BarStart                      = 0;                                  // ST2.BS: Get trend Starting from Bar (0-current)
input     uint                     InpIndST2BarCount                      = 2;                                  // ST2.BC: Bar Count with same value to get trend
input     string                   InpIndST2GridSize                      = "";                                 // ST2.GS: Applies to the Grid Size

input     group                    "INDICATOR: SUPERTREND-3"
input     ENUM_TIMEFRAMES          InpIndST3TF                            = PERIOD_M30;                         // ST3.TF: TimeFrame
input     int                      InpIndST3Period                        = 50;                                 // ST3.PE: Period
input     ENUM_APPLIED_PRICE       InpIndST3Price                         = PRICE_TYPICAL;                      // ST3.PR: Price
input     int                      InpIndST3AtrDevPeriod                  = 5;                                  // ST3.DP: ATR / Standard Deviation Period
input     enUseWhat                InpIndST3UseWhat                       = use_atr;                            // ST3.CM: Calculation Method
input     uint                     InpIndST3BarStart                      = 0;                                  // ST3.BS: Get trend Starting from Bar (0-current)
input     uint                     InpIndST3BarCount                      = 2;                                  // ST3.BC: Bar Count with same value to get trend
input     string                   InpIndST3GridSize                      = "";                                 // ST3.GS: Applies to the Grid Size

input     group                    "INDICATOR: SUPERTREND-4"
input     ENUM_TIMEFRAMES          InpIndST4TF                            = PERIOD_H1;                          // ST4.TF: TimeFrame
input     int                      InpIndST4Period                        = 50;                                 // ST4.PE: Period
input     ENUM_APPLIED_PRICE       InpIndST4Price                         = PRICE_TYPICAL;                      // ST4.PR: Price
input     int                      InpIndST4AtrDevPeriod                  = 5;                                  // ST4.DP: ATR / Standard Deviation Period
input     enUseWhat                InpIndST4UseWhat                       = use_atr;                            // ST4.CM: Calculation Method
input     uint                     InpIndST4BarStart                      = 0;                                  // ST4.BS: Get trend Starting from Bar (0-current)
input     uint                     InpIndST4BarCount                      = 2;                                  // ST4.BC: Bar Count with same value to get trend
input     string                   InpIndST4GridSize                      = "";                                 // ST4.GS: Applies to the Grid Size

input     group                    "INDICATOR: RSI-1"
input     ENUM_TIMEFRAMES          InpIndRSI1TF                           = PERIOD_M15;                         // RSI1.TF: TimeFrame
input     int                      InpIndRSI1MAPeriod                     = 14;                                 // RSI1.PE: Period
input     ENUM_APPLIED_PRICE       InpIndRSI1Price                        = PRICE_CLOSE;                        // RSI1.PR: Applied Price
input     double                   InpIndRSI1SellValue                    = 60.0;                               // RSI1.SV: Trend is SELL when RSI less than
input     double                   InpIndRSI1BuyValue                     = 40.0;                               // RSI1.BV: Trend is BUY when RSI greater than
input     uint                     InpIndRSI1BarStart                     = 0;                                  // RSI1.BS: Get trend Starting from Bar (0-current)
input     uint                     InpIndRSI1BarCount                     = 1;                                  // RSI1.BC: Bar Count with same value to get trend
input     string                   InpIndRSI1GridSize                     = "";                                 // RSI1.GS: Applies to the Grid Size

input     group                    "INDICATOR: RSI-2"
input     ENUM_TIMEFRAMES          InpIndRSI2TF                           = PERIOD_H1;                          // RSI2.TF: TimeFrame
input     int                      InpIndRSI2MAPeriod                     = 14;                                 // RSI2.PE: Period
input     ENUM_APPLIED_PRICE       InpIndRSI2Price                        = PRICE_CLOSE;                        // RSI2.PR: Applied Price
input     double                   InpIndRSI2SellValue                    = 60.0;                               // RSI2.SV: Trend is SELL when RSI less than
input     double                   InpIndRSI2BuyValue                     = 40.0;                               // RSI2.BV: Trend is BUY when RSI greater than
input     uint                     InpIndRSI2BarStart                     = 0;                                  // RSI2.BS: Get trend Starting from Bar (0-current)
input     uint                     InpIndRSI2BarCount                     = 1;                                  // RSI2.BC: Bar Count with same value to get trend
input     string                   InpIndRSI2GridSize                     = "";                                 // RSI2.GS: Applies to the Grid Size

input     group                    "INDICATOR: ADX-1"
input     ENUM_TIMEFRAMES          InpIndADX1TF                            = PERIOD_M30;                        // ADX1.TF: TimeFrame
input     int                      InpIndADX1Period                        = 14;                                // ADX1.PE: Period
input     int                      InpIndADX1ADXTrendLine                  = 20;                                // ADX1.TL: ADX Trend Line
input     uint                     InpIndADX1BarStart                      = 0;                                 // ADX1.BS: Get trend Starting from Bar (0-current)
input     uint                     InpIndADX1BarCount                      = 2;                                 // ADX1.BC: Bar Count with same value to get trend
input     string                   InpIndADX1GridSize                      = "";                                // ADX1.GS: Applies to the Grid Size

input     group                    "INDICATOR: ADX-2"
input     ENUM_TIMEFRAMES          InpIndADX2TF                            = PERIOD_H1;                        // ADX2.TF: TimeFrame
input     int                      InpIndADX2Period                        = 14;                                // ADX2.PE: Period
input     int                      InpIndADX2ADXTrendLine                  = 20;                                // ADX2.TL: ADX Trend Line
input     uint                     InpIndADX2BarStart                      = 0;                                 // ADX2.BS: Get trend Starting from Bar (0-current)
input     uint                     InpIndADX2BarCount                      = 2;                                 // ADX2.BC: Bar Count with same value to get trend
input     string                   InpIndADX2GridSize                      = "";                                // ADX2.GS: Applies to the Grid Size

input     group                    "INDICATOR: ADX-3"
input     ENUM_TIMEFRAMES          InpIndADX3TF                            = PERIOD_H4;                         // ADX3.TF: TimeFrame
input     int                      InpIndADX3Period                        = 14;                                // ADX3.PE: Period
input     int                      InpIndADX3ADXTrendLine                  = 20;                                // ADX3.TL: ADX Trend Line
input     uint                     InpIndADX3BarStart                      = 0;                                 // ADX3.BS: Get trend Starting from Bar (0-current)
input     uint                     InpIndADX3BarCount                      = 2;                                 // ADX3.BC: Bar Count with same value to get trend
input     string                   InpIndADX3GridSize                      = "";                                // ADX3.GS: Applies to the Grid Size

input     group                    "11. MISC"
sinput    LogLevel                 InpLL                                 = LogLevel(INFO);                      // 11.LL: Log Level
          string                   InpBP                                 = "PALLE";
          uint                     COMMENT_UPDATE_DELAY_SEC              = 60;                                  // Ipdate comment delay

CPallEBot                          bot;
CDKSymbolInfo                      symbol_info;
DKLogger                           logger;

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| BOT'S LOGIC
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void InitTrade(CTrade& _trade, const long _magic, const ulong _slippage) {
   _trade.SetExpertMagicNumber(_magic);
   _trade.SetMarginMode();
   _trade.SetTypeFillingBySymbol(Symbol());
   _trade.SetDeviationInPoints(_slippage);  
}

void InitLogger(DKLogger& _logger) {
  _logger.Name = InpBP;
  _logger.Level = InpLL;
  _logger.Format = "%name%:[%level%] %message%";
}

bool CheckGridSizeAndReload(CPallEGrid& _grid) {
//  if (_grid.OpenPosCount() != _grid.Size()) {
//     _grid.Log(StringFormat("OnTrade(): Open pos count not equal grid size: GID=%s | SIZE=%d | OPEN_POS_CNT=%d",
//               _grid.GetID(), _grid.Size(), _grid.OpenPosCount()), DEBUG);
//     _grid.Load();
//     return true;
//   }   
//   
  return false;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| BOT'S EVENTS
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()  {
  // Loggers init
  InitLogger(bot.logger);

  // Проверим режим счета. Нужeн ОБЯЗАТЕЛЬНО ХЕДЖИНГОВЫЙ счет
  CAccountInfo acc;
  if(acc.MarginMode() != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {
    logger.Error("Only hedging mode allowed", true);
    return(INIT_FAILED);
  }

  if(!symbol_info.Name(Symbol())) {
    logger.Error(StringFormat("Symbol %s is not available", Symbol()), true);
    return(INIT_FAILED);
  }
  
  if (InpTSMagicBuy == InpTSMagicSell) {
    logger.Error("Set different magic numbers for buy and sell grids", true);
    return(INIT_FAILED);
  }
  
  MathSrand(GetTickCount());
  
  // Grid Init
  bot.Sym = symbol_info;
  bot.CommentPrefix = bot.logger.Name;
  bot.MagicBuy = InpTSMagicBuy;
  bot.MagicSell = InpTSMagicSell;
  bot.BuyFirstEnabled = InpTSBuyFirstEnabled;
  bot.BuyNextEnabled = InpTSBuyNextEnabled;
  bot.SellFirstEnabled = InpTSSellFirstEnabled;
  bot.SellNextEnabled = InpTSSellNextEnabled;  
  bot.TwoGridsAtOneTime = InpTSTwoGridsAtOneTime;
  bot.MaxTrades = InpGSMaxTrades;
  bot.MMType = InpTSMMType;
  bot.MMValue = InpTSMMValue;
  bot.LotMultiplierDefault = InpGSLotMultiplierDefault;
  bot.LotMultiplierCustom = InpGSLotMultiplierCustom;
  bot.StepDefault = InpGSStepPntDefault;
  bot.StepCustom = InpGSStepPntCustom;
  bot.TakeProfitDefault = InpGSTPPntDefault;
  bot.TakeProfitCustom = InpGSTPPntCustom;
  InitTrade(bot.TradeBuy, InpTSMagicBuy, InpTSSlippage);
  InitTrade(bot.TradeSell, InpTSMagicSell, InpTSSlippage);
  bot.Init();
  bot.AddIndicator(bot.InitIndicatorST(InpIndST1TF, InpIndST1Period, InpIndST1Price, InpIndST1AtrDevPeriod, InpIndST1UseWhat, InpIndST1BarStart, InpIndST1BarCount), InpIndST1GridSize);
  bot.AddIndicator(bot.InitIndicatorST(InpIndST2TF, InpIndST2Period, InpIndST2Price, InpIndST2AtrDevPeriod, InpIndST2UseWhat, InpIndST2BarStart, InpIndST2BarCount), InpIndST2GridSize);
  bot.AddIndicator(bot.InitIndicatorST(InpIndST3TF, InpIndST3Period, InpIndST3Price, InpIndST3AtrDevPeriod, InpIndST3UseWhat, InpIndST3BarStart, InpIndST3BarCount), InpIndST3GridSize);
  bot.AddIndicator(bot.InitIndicatorRSI(InpIndRSI1TF, InpIndRSI1MAPeriod, InpIndRSI1Price, InpIndRSI1SellValue, InpIndRSI1BuyValue, InpIndRSI1BarStart, InpIndRSI1BarCount), InpIndRSI1GridSize);
  bot.AddIndicator(bot.InitIndicatorRSI(InpIndRSI2TF, InpIndRSI2MAPeriod, InpIndRSI2Price, InpIndRSI2SellValue, InpIndRSI2BuyValue, InpIndRSI2BarStart, InpIndRSI2BarCount), InpIndRSI2GridSize);
  bot.AddIndicator(bot.InitIndicatorADXTrend(InpIndADX1TF, InpIndADX1Period, InpIndADX1ADXTrendLine, InpIndADX1BarStart, InpIndADX1BarCount), InpIndADX1GridSize);
  bot.AddIndicator(bot.InitIndicatorADXTrend(InpIndADX2TF, InpIndADX2Period, InpIndADX2ADXTrendLine, InpIndADX2BarStart, InpIndADX2BarCount), InpIndADX2GridSize);
  
  EventSetTimer(5);
  
  return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  {
   EventKillTimer();
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  bot.OnTick();
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
  bot.OnTimer();
}
  
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()  {
  //CheckGridSizeAndReload(m_grid_main_buy);
  //CheckGridSizeAndReload(m_grid_main_sell);
  //CheckGridSizeAndReload(m_grid_lock_buy);
  //CheckGridSizeAndReload(m_grid_lock_sell);
}
//+------------------------------------------------------------------+
