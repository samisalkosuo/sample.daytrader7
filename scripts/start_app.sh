#!/bin/bash


#change occurrences of string in file
function changeString {
	if [[ $# -ne 3 ]]; then
    	echo "$FUNCNAME ERROR: Wrong number of arguments. Requires FILE FROMSTRING TOSTRING."
    	return 1
	fi

	local SED_FILE=$1
	local FROMSTRING=$2
	local TOSTRING=$3
	local TMPFILE=$SED_FILE.tmp

	#get file owner and permissions
	local USER=$(stat -c %U $SED_FILE)
	local GROUP=$(stat -c %G $SED_FILE)
	local PERMISSIONS=$(stat -c %a $SED_FILE)

	#escape to and from strings
	FROMSTRINGESC=$(echo $FROMSTRING | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	TOSTRINGESC=$(echo $TOSTRING | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')

	sed -e "s/$FROMSTRINGESC/$TOSTRINGESC/g" $SED_FILE  > $TMPFILE && mv $TMPFILE $SED_FILE

  #set original owner and permissions
	chown $USER:$GROUP $SED_FILE
	chmod $PERMISSIONS $SED_FILE
	if [ ! -f $TMPFILE ]; then
	    return 0
 	else
	 	echo "$FUNCNAME ERROR: Something went wrong."
	 	return 2
	fi
} 

#
if [[ "$REMOTE_DB_IP_ADDRESS" == "" ]] ; then
    echo "Using embedded database"
    #copy embedded db config
    cp /opt/ibm/wlp/usr/servers/daytrader7Sample/embedded_db.xml /opt/ibm/wlp/usr/servers/daytrader7Sample/db_config.xml

    #configure Daytrader app
    echo "Configuring database..."
    if [[ "$SHOWOUTPUT" == "" ]] ; then
    sh ./configure_daytrader.sh > /dev/null
    else
    sh ./configure_daytrader.sh
    fi  
    echo "Configuring database... Done."
else
    echo "Using remote database on $REMOTE_DB_IP_ADDRESS"
    __config_file=/opt/ibm/wlp/usr/servers/daytrader7Sample/db_config.xml
    cp /opt/ibm/wlp/usr/servers/daytrader7Sample/remote_db.xml $__config_file
    changeString $__config_file REMOTE_DB_IP_ADDRESS $REMOTE_DB_IP_ADDRESS
fi  

#start server
/opt/ibm/wlp/bin/server run daytrader7Sample
