#!/bin/bash

set -o errexit

LOG_FILE="script.log"
#>>${LOG_FILE} 2>&1
#script for development build

__ver=$(cat VERSION) 
__tar_name=${APP_NAME}-${__ver}.tar
echo "Version: ${__ver}"
echo "tar and gzip source"

tar -cf ${__tar_name} docker-build-cache/ lib/ pom.xml Dockerfile daytrader-ee7-ejb/ daytrader-ee7-web/ daytrader-ee7-wlpcfg/ daytrader-ee7/ 
gzip ${__tar_name}

echo "move source to HTTP file server path"
mv ${__tar_name}* ${FILE_SERVER_PATH}/
