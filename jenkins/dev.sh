#!/bin/bash

#https://ops.tips/gists/redirect-all-outputs-of-a-bash-script-to-a-file/
set -o errexit

readonly LOG_FILE="script.log"

# Create the destination log file that we can
# inspect later if something goes wrong with the
# initialization.
touch $LOG_FILE

# Open standard out at `$LOG_FILE` for write.
# This has the effect 
exec 1>$LOG_FILE

# Redirect standard error to standard out such that 
# standard error ends up going to wherever standard
# out goes (the file).
exec 2>&1



#script for development build

__ver=$(cat VERSION)
__tar_name=${APP_NAME}-${__ver}.tar

#tar and gzip source
tar -cf ${__tar_name} docker-build-cache/ lib/ pom.xml Dockerfile daytrader-ee7-ejb/ daytrader-ee7-web/ daytrader-ee7-wlpcfg/ daytrader-ee7/

gzip ${__tar_name}

#move source to HTTP file server path
mv ${__tar_name}* ${FILE_SERVER_PATH}/
