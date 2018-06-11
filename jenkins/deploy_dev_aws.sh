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

#CAM USER, CAM_PASSWORD, CAM_URL and ICP_URL
#are set as Jenkins global environment variables
echo "CAM_USER: ${CAM_USER}"
echo "CAM_PASSWORD: ${CAM_PASSWORD}"
echo "CAM_URL: ${CAM_URL}"
echo "ICP_URL: ${ICP_URL}"

#hardcoded template name
export CAM_SERVICE_NAME="Ubuntu@Frankfurt_v3"

#set work dir because jenkins executes this from .. dir
__work_dir=jenkins

echo "Setting up CAM API..."
source ${__work_dir}/cam_api_setup.sh 

__service_name=Ubuntu@Frankfurt_v3
echo "Deploying service ${__service_name}..."
python ${__work_dir}/deploy_service.py ${__service_name} ${__app_download_url}

__service_id=$(cat SERVICE_ID)
__instance_id=$(cat INSTANCE_ID)

echo "Service ID ${__service_id} Instance ID ${__instance_id}" 

#sleep a moment before continuing
echo "Getting status..."
sleep 3
python ${__work_dir}/get_service_status.py ${__service_id} ${__instance_id}
__status=$(cat DEPLOYMENT_STATUS)

echo "Deployment status: " ${__status}

