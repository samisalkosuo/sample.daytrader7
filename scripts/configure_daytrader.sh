#!/bin/bash

#start server background 
/opt/ibm/wlp/bin/server start daytrader7Sample 

#create database tables
>&2 echo "Creating tables..." 
curl http://localhost:9082/config?action=buildDBTables 2> /dev/null

#stop server background
/opt/ibm/wlp/bin/server stop daytrader7Sample 

#start server background
/opt/ibm/wlp/bin/server start daytrader7Sample 

#configure settings
curl -X POST -d  action=updateConfig \
-d  DisplayOrderAlerts=on \
-d  EnableLongRun=on \
-d  EnablePublishQuotePriceChange=on \
-d  marketSummaryInterval=20 \
-d  MaxQuotes=2000 \
-d  MaxUsers=10 \
-d  OrderProcessingMode=0 \
-d  percentSentToWebsocket=10 \
-d  primIterations=1 \
-d  RunTimeMode=0 \
-d  WebInterface=0 \
http://localhost:9082/config 2> /dev/null

#populate database
>&2 echo "Populating tables..."
curl http://localhost:9082/config?action=buildDB 2> /dev/null

#stop server background
/opt/ibm/wlp/bin/server stop daytrader7Sample 
