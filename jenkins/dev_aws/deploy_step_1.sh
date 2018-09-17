#!/usr/bin/env bash

set -o errexit

source jenkins/dev_aws/variables.sh

#install python prereqs
pip install requests
#install AWS CLI for accessing Object Storage
pip install awscli

echo "Saving image ${__docker_image_name}..."
docker save ${__docker_image_name} > ${__tar_name}
echo "Gzipping ${__tar_name}..."
gzip ${__tar_name}

export DOCKER_IMAGE_TAR_FILE=${__gz_name}

# add variable to file, to be used in the next shell script
echo ${DOCKER_IMAGE_TAR_FILE} > DOCKER_IMAGE_TAR_FILE
