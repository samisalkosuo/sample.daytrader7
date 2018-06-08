#!/bin/bash

set -o errexit

__ver=$(cat VERSION) 
__tar_name=${APP_NAME}-${__ver}.tar
echo "Version: ${__ver}"
echo "tar and gzip source"

tar -cf ${__tar_name} docker-build-cache/ lib/ pom.xml Dockerfile daytrader-ee7-ejb/ daytrader-ee7-web/ daytrader-ee7-wlpcfg/ daytrader-ee7/ 
gzip ${__tar_name}

__gz_name=${__tar_name}.gz

echo "move ${__gz_name} to HTTP file server path: ${FILE_SERVER_PATH}"
mv ${__gz_name} ${FILE_SERVER_PATH}/

__download_url=${HTTP_FILE_SERVER}/${__gz_name}

__app_download_url=${HTTP_FILE_SERVER}/${__gz_name}

echo "Source package: ${__app_download_url}"

echo ${__app_download_url} > DOWNLOAD_URL.txt
