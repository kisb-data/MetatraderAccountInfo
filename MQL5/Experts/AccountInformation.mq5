//+------------------------------------------------------------------+
//|                     Copyright 2024, kisb-data                    |
//|                     kisbalazs.data@gmail.com                     |
//+------------------------------------------------------------------+

sinput string Server="localhost";
sinput uint   Port=9090;
sinput uint   Timeout=1000;

//--- includes
#include <kisb_data\\Socket\\SocketCom.mqh>
#include <kisb_data\\Externals\\SYS_JAson.mqh>

//--- create classes
CSocket *Socket;
CJAVal  *json;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
//--- create classes
   Socket = new CSocket(Server, Port, Timeout);
   json=new CJAVal;
 
//--- create timer
   EventSetMillisecondTimer(500);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
//--- delete classes
   delete Socket;
   delete json;
//--- destroy timer
   EventKillTimer();
   
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   // Adding account information to JSON
   // Integer type account info
   json["ACCOUNT_LOGIN"] = (long)AccountInfoInteger(ACCOUNT_LOGIN);
   json["ACCOUNT_TRADE_MODE"] = (int)AccountInfoInteger(ACCOUNT_TRADE_MODE);
   json["ACCOUNT_LEVERAGE"] = (long)AccountInfoInteger(ACCOUNT_LEVERAGE);
   json["ACCOUNT_LIMIT_ORDERS"] = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   json["ACCOUNT_MARGIN_SO_MODE"] = (int)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   json["ACCOUNT_TRADE_ALLOWED"] = (bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
   json["ACCOUNT_TRADE_EXPERT"] = (bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
   json["ACCOUNT_MARGIN_MODE"] = (int)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   json["ACCOUNT_CURRENCY_DIGITS"] = (int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   json["ACCOUNT_FIFO_CLOSE"] = (bool)AccountInfoInteger(ACCOUNT_FIFO_CLOSE);
   json["ACCOUNT_HEDGE_ALLOWED"] = (bool)AccountInfoInteger(ACCOUNT_HEDGE_ALLOWED);
   
   // Double type account info
   json["ACCOUNT_BALANCE"] = AccountInfoDouble(ACCOUNT_BALANCE);
   json["ACCOUNT_CREDIT"] = AccountInfoDouble(ACCOUNT_CREDIT);
   json["ACCOUNT_PROFIT"] = AccountInfoDouble(ACCOUNT_PROFIT);
   json["ACCOUNT_EQUITY"] = AccountInfoDouble(ACCOUNT_EQUITY);
   json["ACCOUNT_MARGIN"] = AccountInfoDouble(ACCOUNT_MARGIN);
   json["ACCOUNT_MARGIN_FREE"] = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   json["ACCOUNT_MARGIN_LEVEL"] = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   json["ACCOUNT_MARGIN_SO_CALL"] = AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
   json["ACCOUNT_MARGIN_SO_SO"] = AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
   json["ACCOUNT_MARGIN_INITIAL"] = AccountInfoDouble(ACCOUNT_MARGIN_INITIAL);
   json["ACCOUNT_MARGIN_MAINTENANCE"] = AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE);
   json["ACCOUNT_ASSETS"] = AccountInfoDouble(ACCOUNT_ASSETS);
   json["ACCOUNT_LIABILITIES"] = AccountInfoDouble(ACCOUNT_LIABILITIES);
   json["ACCOUNT_COMMISSION_BLOCKED"] = AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED);
   
   // String type account info
   json["ACCOUNT_NAME"] = AccountInfoString(ACCOUNT_NAME);
   json["ACCOUNT_SERVER"] = AccountInfoString(ACCOUNT_SERVER);
   json["ACCOUNT_CURRENCY"] = AccountInfoString(ACCOUNT_CURRENCY);
   json["ACCOUNT_COMPANY"] = AccountInfoString(ACCOUNT_COMPANY);
   
   // Add position data
   for(int i=0; i<PositionsTotal(); i++)
   if(PositionSelectByTicket(PositionGetTicket(i)))
   {
      json["POSITION_MAGIC"].Add(PositionGetInteger(POSITION_MAGIC));
      json["POSITION_SYMBOL"].Add(PositionGetString(POSITION_SYMBOL));
      json["POSITION_TYPE"].Add(PositionGetInteger(POSITION_TYPE));
      json["POSITION_PROFIT"].Add(PositionGetDouble(POSITION_PROFIT));
      json["POSITION_TIME"].Add(TimeToString(PositionGetInteger(POSITION_TIME), TIME_DATE |TIME_MINUTES | TIME_SECONDS));
      json["POSITION_PRICE_OPEN"].Add(PositionGetDouble(POSITION_PRICE_OPEN));
      json["POSITION_VOLUME"].Add(PositionGetDouble(POSITION_VOLUME));
   }
                                 
   // Serialise json data
   string jsonString = json.Serialize();
   
   // Send/receive data
   string received=Socket.SendReceive(jsonString);
   
   // Reset json buffer
   json.Clear();
  }
//+------------------------------------------------------------------+
