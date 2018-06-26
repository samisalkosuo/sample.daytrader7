#!/usr/bin/env bash

#uploads application file to IBM Object Storage

#these variables must be available in environment
#IBMCLOUD_API_KEY
#IBMCLOUD_ORGANIZATION
#IBMCLOUD_SPACE
IBMCLOUD_ENDPOINT_URL=https://api.eu-de.bluemix.net

export AWS_DEFAULT_REGION=ams03-standard
export COS_ENDPOINT_URL=https://s3.ams03.objectstorage.softlayer.net
echo "Uploading image to IBM Cloud Object Storage..."

#login to IBM Cloud
ibmcloud login -a $IBMCLOUD_ENDPOINT_URL -o $IBMCLOUD_ORGANIZATION -s $IBMCLOUD_SPACE --apikey $IBMCLOUD_API_KEY

#if you already have Object Storage change this name
__cos_instance_name=my-object-storage
__cos_key_name=my-object-storage-key

#check if service exists
ibmcloud cf services | grep ${__cos_instance_name}
rv=$?
if [ $rv -ne 0 ]; then
    #object storage service does does not exist (probably), so create it
    ibmcloud cf create-service "cloud-object-storage" Lite ${__cos_instance_name}
    ibmcloud cf create-service-key ${__cos_instance_name} ${__cos_key_name} -c {\"HMAC\":true}
fi

#get service key
__key_file=key.txt
ibmcloud cf service-key ${__cos_instance_name} ${__cos_key_name} > ${__key_file}

pwd
ls
echo "ls .."
ls ..
cat ${__key_file}

#export AWS_ACCESS_KEY_ID=$(tail -n +4 ${__key_file} | python -c "import sys,json;print(json.load(sys.stdin)['cos_hmac_keys']['access_key_id'])")
#export AWS_SECRET_ACCESS_KEY=$(tail -n +4 ${__key_file} | python -c "import sys,json;print(json.load(sys.stdin)['cos_hmac_keys']['secret_access_key'])")
export AWS_ACCESS_KEY_ID=$(cat ${__key_file} | python jenkins/get_cos_keys.py access)
export AWS_ACCESS_KEY_ID=$(cat ${__key_file} | python jenkins/get_cos_keys.py secret)

#bucket name must be unique
__bucket_name=s3://${IBMCLOUD_ORGANIZATION}_${IBMCLOUD_SPACE}_icpcamdevopsdemo
#__uuid=$(python -c "import uuid;print(str(uuid.uuid4()))")
#__bucket_name=s3://${__uuid}

#create bucket
#this fails if bucket already exists
aws --endpoint-url ${COS_ENDPOINT_URL} s3 mb ${__bucket_name} || true

#upload file to bucket
#docker image tar file name is in environment
aws --endpoint-url ${COS_ENDPOINT_URL} s3 cp ${DOCKER_IMAGE_TAR_FILE} ${__bucket_name}

#presign to get publicly accessible URL
__public_url=$(aws --endpoint-url ${COS_ENDPOINT_URL} s3 presign ${__bucket_name}/${DOCKER_IMAGE_TAR_FILE})

echo ${__public_url} > DOWNLOAD_URL.txt

#logout from IBM Cloud
ibmcloud logout

echo "Uploading image to IBM Cloud Object Storage... Done."
