#!/bin/bash

set -o errexit

#Deploy Daytrader app to ICP

__image_name=$1


#TODO: helm chart for liberty
#https://www.ibm.com/support/knowledgecenter/en/was_beta_liberty/com.ibm.websphere.wlp.nd.multiplatform.doc/ae/twlp_icp_helm_way.html
#https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.3/app_center/create_helm_cli.html?pos=2
#https://medium.com/ibm-cloud/build-test-deploy-to-ibm-cloud-private-icp-continuous-delivery-with-jenkins-container-7a7a0000b0ec
#bx pr login -a ${ICP_URL} --skip-ssl-validation -u $CAM_USER -p $CAM_PASSWORD -c id-mycluster-account
#bx pr cluster-config mycluster

source jenkins/prod_icp/variables.sh

#Deploy docker image using kubectl

#Login to ICP and set default account id and default namespae
cloudctl login -a ${ICP_URL} --skip-ssl-validation -u ${CAM_USER} -p ${CAM_PASSWORD} -c id-mycluster-account -n default

#configure kubectl 
#cloudctl cluster-config mycluster

#TODO: update apps in place instead of deleting
#TODO: Helm chart

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
kubectl create -f ${__work_dir}/prod_icp/daytrader_ingress.yaml

#sleep to make sure that ingress is created and docker container is running
sleep 10

#__ingress_ip=$(kubectl get ing --namespace default daytrader -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
#echo "Ingress IP: " ${__ingress_ip}
__ingress_ip=${ICP_PROXY_IP}
echo https://${__ingress_ip}/daytrader/ > ICP_APP_URL
