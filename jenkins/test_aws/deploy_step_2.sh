#!/usr/bin/env bash

set -o errexit

source jenkins/test_aws/variables.sh

# read varible from file
export DOCKER_IMAGE_TAR_FILE=$(cat DOCKER_IMAGE_TAR_FILE)

#upload file to object storage
#and store download url to file DOWNLOAD_URL.txt
sh ${__work_dir}/upload_to_object_storage.sh

