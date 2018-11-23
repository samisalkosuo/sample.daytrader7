#!/bin/bash

set -o errexit

source build.env

__docker_image_name=${APP_NAME}:${VERSION}
docker build -t ${__docker_image_name} .
docker tag ${__docker_image_name} ${APP_NAME}:latest