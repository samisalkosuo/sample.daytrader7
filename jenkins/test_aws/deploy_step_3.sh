#!/usr/bin/env bash

set -o errexit

source jenkins/test_aws/variables.sh

#Deploy service via CAM

#CAM USER, CAM_PASSWORD
#are set as Jenkins credentials
#CAM_URL and ICP_URL
#are set as Jenkins global environment variables

echo "Setting up CAM API..."
source ${__work_dir}/cam_api_setup.sh 

__service_name=${CAM_SERVICE_NAME}
echo "Deploying service ${__service_name}..."
__app_download_url=$(cat DOWNLOAD_URL.txt)
echo "App download URL: ${__app_download_url}" 
python ${__work_dir}/deploy_service.py ${__service_name} ${__app_download_url}

__service_id=$(cat SERVICE_ID)
__instance_id=$(cat INSTANCE_ID)

echo "Service ID ${__service_id} Instance ID ${__instance_id}" 

echo "Getting status..."
python ${__work_dir}/get_service_status.py ${__service_id} ${__instance_id} 2> /dev/null
cat DEPLOYMENT_STATUS
__status=$(cat DEPLOYMENT_STATUS)

#sleep a moment before continuing
#to make sure that DayTrader (database) has finished initialization
sleep 10

echo "Deployment status: " ${__status}

if [[ "${__status}" == "error" ]] ; then
    echo "Error during deployment, check CAM logs"
    exit 1
fi 

if [[ "${__status}" == "active" ]] ; then
    echo "Deployment is active"
    ipAddress=$(cat IP_ADDRESS)
    echo "IP address: " $ipAddress
    
    exit 0
fi 
