
#source this file to set up variables
#source cam_apiu_setup.sh


export CAM_BEARER_TOKEN=$(curl -k -X POST -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d "grant_type=password&username=${CAM_USER}&password=${CAM_PASSWORD}&scope=openid" ${ICP_URL}/idprovider/v1/auth/identitytoken 2> /dev/null | python -c "import sys, json; print json.load(sys.stdin)['access_token']")

export CAM_TENANT_ID=$(curl -k -X GET -H "Authorization: Bearer ${CAM_BEARER_TOKEN}" ${CAM_URL}/cam/tenant/api/v1/tenants/getTenantOnPrem 2> /dev/null | python -c "import sys, json; print json.load(sys.stdin)['id']")

export ICP_NAMESPACE=$(curl -k -X GET -H "Authorization: Bearer ${CAM_BEARER_TOKEN}" ${CAM_URL}/cam/tenant/api/v1/tenants/getTenantOnPrem 2> /dev/null | python -c "import sys, json; print json.load(sys.stdin)['namespaces'][0]['uid']")

export CAM_TEAM_ID=$(curl -k -X GET -H "Authorization: Bearer ${CAM_BEARER_TOKEN}" ${CAM_URL}/cam/tenant/api/v1/tenants/getTenantOnPrem 2> /dev/null | python -c "import sys, json; print json.load(sys.stdin)['namespaces'][0]['teamId']")

