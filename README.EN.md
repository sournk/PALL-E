# PALL-E

* Author: Denis Kislitsyn
* Version: 1.03

The PALL-E bot is the result of the evolution of the grid trading system, which was specially created in 2019 for XAUUSD. Now the bot is equipped with a flexible system of trend and volatility detection using 4 customized indicators, which the bot tracks simultaneously on many timeframes. This allows you to customize it to filter out dangerous entries and make the grid strategy less risky. However, the flexible system of settings allows you to make it more aggressive and use it to increase your deposits. 
Grid positions are built at the moments of trend changes, adapting to the current price behavior.

> ==**WARNING**==:
    1. The bot does not guarantee a profit.
    2. The bot does not guarantee 100% deposit protection.
    3. The bot can hold positions from a few minutes to several weeks.
    4. Use the bot at your own risk.

## Installation
1. Make sure that your MetaTrader 5 terminal is updated to the latest version. To test Expert Advisors, it is recommended to update the terminal to the latest beta version. To do this, run the update from the main menu `Help->Check For Updates->Latest Beta Version`. The Expert Advisor may not run on previous versions because it is compiled for the latest version of the terminal. In this case you will see messages on the `Journal` tab about it.
2. Copy the bot executable file `*.ex5` to the terminal data directory `MQL5\Experts\`.
3. Copy the `*.ex5` indicator executable file to the `MQL5/Indicators\` terminal data directory.
4. Open the pair chart.
5. Move the Expert Advisor from the Navigator window to the chart.
6. Check `Allow Auto Trading` in the bot settings.
7. Enable the auto trading mode in the terminal by clicking the `Algo Trading` button on the main toolbar.
8. Load the set of settings by clicking the `Load` button and selecting the set-file.
9. Enter the license key for your account number in the `0.LIC: License Key` parameter.

## Backtest XAUUSD | Roboforex-Pro | RealTicks

#### Conservative Settings

Testing on conservative settings from 2018 through October 2024: 3,7%/mn.
![Conservative](img/UM001.%202024-10-01-Conservative-0.03.png)
Detailed MT5 test results - [open HTML](set/XAUUSD-2024-10-01-Conservative-0.03/2024-10-01-Conservative-0.03.html).

#### Aggressive settings

This option of settings cannot be applied in any historical period. They are highly dependent on the current nature of the instrument movement. They should be reviewed regularly and **==applied only in periods when the instrument is in its standard price movement!==**
The current version of the settings is optimized for 2024: 13.6%/mn.

![Aggressive](img/UM002.%202024-10-01-Aggressive.png)
Detailed MT5 test results - [open HTML](set/XAUUSD-2024-10-01-Aggressive/2024-10-01-Aggressive.html).