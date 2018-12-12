#!/usr/bin/env bash

#uploads application file to IBM Object Storage

#these variables must be available in environment
#IBMCLOUD_API_KEY
IBMCLOUD_ENDPOINT_URL=https://api.eu-de.bluemix.net

export AWS_DEFAULT_REGION=ams03-standard
export COS_ENDPOINT_URL=https://s3.ams03.objectstorage.softlayer.net
echo "Uploading image to IBM Cloud Object Storage..."

#login to IBM Cloud
ibmcloud login -a $IBMCLOUD_ENDPOINT_URL --apikey $IBMCLOUD_API_KEY
#if you already have Object Storage change this name
__cos_instance_name=my-object-storage
__cos_key_name=my-object-storage-key

#check if service exists
ibmcloud resource service-instances | grep ${__cos_instance_name}
rv=$?
if [ $rv -ne 0 ]; then
    #object storage service does does not exist (probably), so create it
    ibmcloud resource service-instance-create ${__cos_instance_name} cloud-object-storage lite global
    ibmcloud resource service-key-create ${__cos_key_name} Writer --instance-name $__cos_instance_name -p {\"HMAC\":true}
fi

#get service key
__key_file=key.txt
ibmcloud resource service-key ${__cos_key_name} > ${__key_file}

export AWS_ACCESS_KEY_ID=$(cat $__key_file | grep access_key_id | awk '{print $2}')
export AWS_SECRET_ACCESS_KEY=$(cat $__key_file | grep secret_access_key | awk '{print $2}')

set -e

#bucket name must be unique
#this create globally unique identifier
__uuid=$(python -c "import uuid;print(str(uuid.uuid4()))")
#__bucket_name=s3://icpcamdevopsdemo
__bucket_name=s3://${__uuid}

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
