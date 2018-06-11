import requests
import json
import os
import uuid
import sys
import time

service_id=sys.argv[1]
instance_id=sys.argv[2]

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
ret = requests.get(CAM_URL + "/cam/composer/api/v1/ServiceInstances",
                     headers=head,
                     params=parameters,
                     verify=False)

serviceInstances=ret.json()

status=""
while status!="active" and status!="error":
    #print(json.dumps(serviceInstances, indent=2, sort_keys=True))
    print("Getting status... ", end='')
    for instance in serviceInstances:
        if instance["ServiceID"]==service_id and instance["id"]==instance_id:
            status=instance["Status"]
            print(status)
            if status != None:
                status = status.lower()
    time.sleep(5)
        #print(instance["Status"])
        #print("Name: %s ServiceID: %s Instance ID: %s Status: %s" % (instance["name"],instance["ServiceID"],instance["id"],instance["Status"]))

with open('DEPLOYMENT_STATUS', 'w') as f:
    print(status, file=f)
