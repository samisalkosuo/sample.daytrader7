#!/bin/bash

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
__icp_image_name=${__docker_registry}/{$__namespace}/${__image_name}
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
#ICP config TODO: add to Jenkins env variables
kubectl config set-cluster cluster.local --server=https://169.50.29.32:8010 --insecure-skip-tls-verify=true
kubectl config set-context cluster.local-context --cluster=cluster.local
kubectl config set-credentials admin --token=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoiYnV4Z2k1cm42MmdrZnZiZDdpNWciLCJyZWFsbU5hbWUiOiJjdXN0b21SZWFsbSIsInVuaXF1ZVNlY3VyaXR5TmFtZSI6ImFkbWluIiwiaXNzIjoiaHR0cHM6Ly9teWNsdXN0ZXIuaWNwOjk0NDMvb2lkYy9lbmRwb2ludC9PUCIsImF1ZCI6IjRiOTU5MWJkNjc3ZjI1M2I3NGE1MGU1NDEzODRiOWNmIiwiZXhwIjoxNTI4ODIyNzc3LCJpYXQiOjE1Mjg3OTM5NzcsInN1YiI6ImFkbWluIiwidGVhbVJvbGVNYXBwaW5ncyI6W119.EBxld4Ddi68kjjtWOv2hovv-4917EsNDYsR48YyW19VAQVfPClb2tvjMxArkOHve6xxsXsLXAFK_98n98N6CDTybIRzveNSlh60imFiBzWjDdej-D3JPtrRj7AhzYRvxGFuma8E0Ojjc_Dtl1bfqpQXygG8dbEaiJTBUL1HXCYO7zyqlJ_9WrqjQU_bOSaffieaYYfZhY2-E9as8UnfiIsXBcl7O1zay_s9vFpowuHnbUTAi1pX17GenxwhP8s3VOHqXyYRnVgKSTs_eYXJr9THDCbMCJOQSS36veQUizfgTswKPn567AC06JN4T1q4YBHD0IIHrdMMGJapwMH-IzQ
kubectl config set-context cluster.local-context --user=admin --namespace=default
kubectl config use-context cluster.local-context


#TODO: update apps in place instead of deleting
echo "Deleting existing deployments..."
__app_name=daytrader
kubectl delete Deployment ${__app_name}
kubectl delete ingress ${__app_name}
kubectl delete service ${__app_name}

echo "Creating kube deployment..."
kubectl run ${__app_name} --image=${__icp_image_name} --port 9443 --expose=true

#set work dir because jenkins executes this from parent dir
__work_dir=jenkins

echo "Creating ingress..."
#name 'daytrader' is hardcoded in yaml file
kubectl create -f daytrader_ingress.yaml

__ingress_ip=$(kubectl get ing --namespace default daytrader -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo https://${__ingress_ip}/daytrader/ > ICP_APP_URL
