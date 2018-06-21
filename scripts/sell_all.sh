#!/usr/bin/env bash

#This script sells everything in users portfolia

if [[ "$1" == "" ]] ; then
    echo "Daytrader URL not specified"
    echo "Usage $0 <DAYTRADER_URL> <USER_ID>"
    exit 1
fi   

if [[ "$2" == "" ]] ; then
    echo "User ID not specified"
    echo "Usage $0 <DAYTRADER_URL> <USER_ID>"
    exit 1
fi

__user=$2
__password=xxx
__daytrader_url=$1
__cookiefile=daytrader_cookiefile.txt

echo "Selling all holding of user ${__user}..."

#login
curl -k -c ${__cookiefile} -X POST -d action=login -d uid=uid:${__user} -d passwd=${__password} ${__daytrader_url}/app &> /dev/null

#get portfolia and sell all holdings
curl -k -b ${__cookiefile} -X GET ${__daytrader_url}/app?action=portfolio 2> /dev/null | grep action=sell | sed -n "s|.*href=\"\(.*\)\".*|curl -k -b ${__cookiefile} \"${__daytrader_url}/\1\"|p"  | sh &> /dev/null

rm -f ${__cookiefile}

echo "All holdings sold."
