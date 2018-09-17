#!/bin/bash

set -o errexit

exit 1

#install python prereqs
pip install requests
#install AWS CLI for accessing Object Storage
pip install awscli

export PATH=~/.local/bin/:$PATH

#set work dir because jenkins executes this from parent dir
__work_dir=jenkins/dev_aws

#hardcoded template name
export CAM_SERVICE_NAME="Daytrader@Frankfurt"

__ver=$(cat VERSION) 
__tar_name=${APP_NAME}.tar

__gz_name=${__tar_name}.gz

#Docker image was build in previous Jenkins stage
__docker_image_name=${APP_NAME}:latest
echo "Saving image ${__docker_image_name}..."
docker save ${__docker_image_name} > ${__tar_name}
echo "Gzipping ${__tar_name}..."
gzip ${__tar_name}

export DOCKER_IMAGE_TAR_FILE=${__gz_name}
#upload file to object storage
#and store download url to file DOWNLOAD_URL.txt
sh ${__work_dir}/upload_to_object_storage.sh

#CAM USER, CAM_PASSWORD, CAM_URL and ICP_URL
#are set as Jenkins global environment variables
echo "CAM_USER: ${CAM_USER}"
echo "CAM_PASSWORD: ${CAM_PASSWORD}"
echo "CAM_URL: ${CAM_URL}"
echo "ICP_URL: ${ICP_URL}"

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