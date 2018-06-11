import requests
import json
import os
import uuid
import sys

#deploy service to AWS using CAM

service_name=sys.argv[1]
app_download_url=sys.argv[2]

CAM_BEARER_TOKEN=os.environ['CAM_BEARER_TOKEN']

if CAM_BEARER_TOKEN == "":
    print("Not initialized.")
    print("Execute: source cam_api_setup.sh")
    exit(1)

CAM_TENANT_ID=os.environ['CAM_TENANT_ID']
ICP_NAMESPACE=os.environ['ICP_NAMESPACE']
CAM_TEAM_ID=os.environ['CAM_TEAM_ID']
ICP_URL=os.environ['ICP_URL']
CAM_URL=os.environ['CAM_URL']

#services
parameters={"tenantId":CAM_TENANT_ID, "ace_orgGuid":CAM_TEAM_ID, "cloudOE_spaceGuid":ICP_NAMESPACE}
head = {"Authorization": "bearer " + CAM_BEARER_TOKEN, 'Accept':'application/json'}
ret = requests.get(CAM_URL + "/cam/composer/api/v1/service",
                     headers=head,
                     params=parameters,
                     verify=False)

services=ret.json()
for service in services:    
    serviceName=service['name']
    serviceId=service['id']
    print("%s: %s" % (serviceName,serviceId))
    if serviceName == service_name:
        print("Deploying %s..." % serviceName)

        url=CAM_URL + "/cam/composer/api/v1/Service/%s/ServiceInstances?tenantId=%s&ace_orgGuid=%s&cloudOE_spaceGuid=%s" % (serviceId,CAM_TENANT_ID,CAM_TEAM_ID, ICP_NAMESPACE)
        print("Making POST request to %s..." % url)
        uuid=str(uuid.uuid4())

        data = {
            'name': "Deployment: %s" % uuid,
            "owner": "nobody",
            "instance_plan": "Standard",
            "instance_parameters": {
               "app_download_url": app_download_url
            }
        }
        headers = {"Authorization": "bearer " + CAM_BEARER_TOKEN,'Content-type': 'application/json', 'Accept':'application/json'}
        ret = requests.post(url, data=json.dumps(data), headers=headers,verify=False)
        response = ret.json()
        print(json.dumps(response, indent=2, sort_keys=True))

        print("Service ID: %s Instance ID: %s" % (response['serviceId'],response['id']))
        #find instance id using uuid and get services instances call



