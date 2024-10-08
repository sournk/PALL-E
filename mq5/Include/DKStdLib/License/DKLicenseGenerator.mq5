//+------------------------------------------------------------------+
//|                                                     Research.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"
#property version   "1.00"
#property description "DK License Key Generator Tool"

#property script_show_inputs

#include <Trade\AccountInfo.mqh>
#include "DKLicense.mqh"
         
          
input     group                    "1. CREATE NEW LICENSE KEY"
input     long                     InpAccount;                                             // License for Account Number 
input     datetime                 InpExpiryDate;                                          // Licence Expiration Date (excluded) and time is ignored
input     string                   InpLicenseSalt;                                         // Salt

input     group                    "2. CHECK LICENSE KEY"
input     string                   InpLicenseToCheck;                                      // License Key Just To Check
          

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  if (InpLicenseSalt == "") {
    Print("Wrong salt");
    return;
  }

  if (InpAccount > 0) {
    Print(StringFormat("License key for %I64u account with %s expiry date is in the next line:", 
                       InpAccount, TimeToString(InpExpiryDate, TIME_DATE)));
    Print(LicenseToString(InpAccount, InpExpiryDate, InpLicenseSalt)); 
  }
  else{
    CAccountInfo account;
    bool res = IsLicenseValid(InpLicenseToCheck, account.Login(), InpLicenseSalt);
    Print(StringFormat("License Key `%s` check result is %s", 
                       InpLicenseToCheck,
                       (res) ? "VALID" : "INVALID"));
  }
}
  
