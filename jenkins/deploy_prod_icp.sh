#!/bin/bash

set -o errexit

#Deploy Daytrader app to ICP

__image_name=$1

#echo "CAM_USER: ${CAM_USER}"
#echo "CAM_PASSWORD: ${CAM_PASSWORD}"
#echo "CAM_URL: ${CAM_URL}"
#echo "ICP_URL: ${ICP_URL}"

echo "Deploying ${__image_name} to ICP..."

__docker_registry=mycluster.icp:8500
__namespace=default

#login to icp
docker login ${__docker_registry} -u $CAM_USER -p $CAM_PASSWORD

#remember to add docker registry certificate 
#https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.3/manage_images/configuring_docker_cli.html
#tag and push image
__icp_image_name=${__docker_registry}/$__namespace/${__image_name}
docker tag ${__image_name} ${__icp_image_name}
echo "Pushing ${__image_name} to ICP..."
docker push ${__icp_image_name}

#TODO: helm chart for liberty
#https://www.ibm.com/support/knowledgecenter/en/was_beta_liberty/com.ibm.websphere.wlp.nd.multiplatform.doc/ae/twlp_icp_helm_way.html
#https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.3/app_center/create_helm_cli.html?pos=2
#https://medium.com/ibm-cloud/build-test-deploy-to-ibm-cloud-private-icp-continuous-delivery-with-jenkins-container-7a7a0000b0ec
#bx pr login -a ${ICP_URL} --skip-ssl-validation -u $CAM_USER -p $CAM_PASSWORD -c id-mycluster-account
#bx pr cluster-config mycluster

#Deploy docker image using kubectl

#Login to ICP
#echo 1 selects the first available account
echo 1 | bx pr login -a ${ICP_URL} --skip-ssl-validation -u ${CAM_USER} -p ${CAM_PASSWORD}

#configure kubectl 
bx pr cluster-config mycluster

#TODO: update apps in place instead of deleting

echo "Deleting existing deployments..."
__app_name=daytrader
kubectl delete ingress ${__app_name} || true
kubectl delete service ${__app_name} || true
kubectl delete Deployment ${__app_name} || true

echo "Creating kube deployment..."
kubectl run ${__app_name} --image=${__icp_image_name} --port 9443 --expose=true --env="REMOTE_DB_IP_ADDRESS=${DAYTRADER_DB_IP}"

#set work dir because jenkins executes this from parent dir
__work_dir=jenkins

echo "Creating ingress..."
#name 'daytrader' is hardcoded in yaml file
kubectl create -f ${__work_dir}/daytrader_ingress.yaml

#sleep to make sure that ingress is created and docker container is running
sleep 5

#__ingress_ip=$(kubectl get ing --namespace default daytrader -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
#echo "Ingress IP: " ${__ingress_ip}
__ingress_ip=${ICP_PROXY_IP}
echo https://${__ingress_ip}/daytrader/ > ICP_APP_URL
