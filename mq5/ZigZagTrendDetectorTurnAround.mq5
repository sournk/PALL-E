//=====================================================================
// Èíäèêàòîð òðåíäà.
//=====================================================================
#property copyright  "Dima S."
#property link       "dimascub@mail.com"
#property version    "1.01"
#property description "Èíäèêàòîð òðåíäà íà îñíîâå èíäèêàòîðà ZigZag."
//---------------------------------------------------------------------
#property indicator_separate_window
//---------------------------------------------------------------------
#property indicator_applied_price PRICE_CLOSE
#property indicator_minimum    -1.4
#property indicator_maximum    +1.4
//---------------------------------------------------------------------
#property indicator_buffers  2
#property indicator_plots    1
//---------------------------------------------------------------------
#property indicator_type1    DRAW_HISTOGRAM
#property indicator_color1   Black
#property indicator_width1  2
//---------------------------------------------------------------------
// Âíåøíèå çàäàâàåìûå ïàðàìåòðû:
//---------------------------------------------------------------------
input int   ExtDepth=12;
input int   ExtDeviation= 5;
input int   ExtBackstep = 3;
input int   ExtSkipExtreme = 3;
//---------------------------------------------------------------------
double   TrendBuffer[];
double   ZigZag[];   
//---------------------------------------------------------------------
int      indicator_handle=0;
//---------------------------------------------------------------------
// Îáðàáîò÷èê ñîáûòèÿ èíèöèàëèçàöèè:
//---------------------------------------------------------------------
int OnInit() {
// Îòîáðàæàåìûé èíäèêàòîðíûé áóôåð:
  SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
  PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtDepth);
  PlotIndexSetString(0,PLOT_LABEL,"ZigZagTrendDetector( "
                     +(string)ExtDepth+", "
                     +(string)ExtDeviation+", "
                     +(string) ExtBackstep+" )");

// Áóôåðû äëÿ õðàíåíèÿ ïåðåëîìîâ çèã-çàãà:
  SetIndexBuffer(1,ZigZag,INDICATOR_CALCULATIONS);

// Ñîçäàäèì õýíäë âíåøíåãî èíäèêàòîðà äëÿ äàëüíåéøåãî îáðàùåíèÿ ê íåìó:
  ResetLastError();
  indicator_handle=iCustom(Symbol(),PERIOD_CURRENT,"Examples\\ZigZag",ExtDepth,ExtDeviation,ExtBackstep);
  if(indicator_handle==INVALID_HANDLE) {
    Print("Îøèáêà èíèöèàëèçàöèè ZigZag, Êîä = ",GetLastError());
    return(-1);     // âîçâðàòèì íåíóëåâîé êîä - èíèöèàëèçàöèÿ ïðîøëà íåóäà÷íî
  }

  return(0);
}
//---------------------------------------------------------------------
// Îáðàáîò÷èê ñîáûòèÿ äåèíèöèàëèçàöèè èíäèêàòîðà:
//---------------------------------------------------------------------
void OnDeinit(const int _reason) {
// Óäàëèì õýíäë èíäèêàòîðà çèã-çàãà:
  if(indicator_handle!=INVALID_HANDLE) {
    IndicatorRelease(indicator_handle);
  }
}
//---------------------------------------------------------------------
// Îáðàáîò÷èê ñîáûòèÿ íåîáõîäèìîñòè ïåðåñ÷åòà èíäèêàòîðà:
//---------------------------------------------------------------------
int OnCalculate(const int _rates_total,
                const int _prev_calculated,
                const int _begin,
                const double &_price[]) {
  int   start,i;

// Åñëè ÷èñëî áàðîâ íà ýêðàíå ìåíüøå, ÷åì ÷èñëî áàð äëÿ ïîñòðîåíèÿ ïåðåëîìà çèã-çàãà, òî ðàñ÷åòû íåâîçìîæíû:
  if(_rates_total<ExtDepth) {
    return(0);
  }

// Îïðåäåëèì íà÷àëüíûé áàð äëÿ ðàñ÷åòà èíäèêàòîðíîãî áóôåðà:
  if(_prev_calculated==0) {
    start=ExtDepth;
  } else {
    start=_prev_calculated-1;
  }

// Ñêîïèðóåì âåðõíèå è íèæíèå ïåðåëîìû çèã-çàãà â áóôåðû:
  CopyBuffer(indicator_handle,0,0,_rates_total-_prev_calculated,ZigZag);

// Öèêë ðàñ÷åòà çíà÷åíèé èíäèêàòîðíîãî áóôåðà:
  for(i=start; i<_rates_total; i++) {
    TrendBuffer[i]=TrendDetector(i-ExtSkipExtreme);
  }

  return(_rates_total);
}

//---------------------------------------------------------------------
// Îïðåäåëÿåò íàïðàâëåíèå òåêóùåãî òðåíäà:
//---------------------------------------------------------------------
// Âîçâðàùàåò:
//  -1 - òðåíä âíèç;
//  +1 - òðåíä ââåðõ;
//   0 - òðåíä íå îïðåäåëåí;
//---------------------------------------------------------------------
double   ZigZagExt[2];
//---------------------------------------------------------------------
int TrendDetector(int _shift) {
  int ext_count= 0;
  for(int i=_shift; i>=0; i--) {
    if(ZigZag[i]>0) {
      ZigZagExt[ext_count]=ZigZag[i];
      ext_count++;
    }
    if(ext_count>=2) break;
  }

  if(ext_count!=2) 
    return 0;

  int trend_direction = 0;
  if(ZigZagExt[0]>ZigZagExt[1])
    trend_direction = +1;
  if(ZigZagExt[0]<ZigZagExt[1])
    trend_direction = -1;

  return trend_direction;
}
