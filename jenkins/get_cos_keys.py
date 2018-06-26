

import sys
import json

inputstring=[]
for line in sys.stdin:
    inputstring.append(line)

jsonstring="".join(inputstring)

if sys.argv[1]=="access":
  print(json.loads(jsonstring)['cos_hmac_keys']['access_key_id'])


if sys.argv[1]=="secret":
  print(json.loads(jsonstring)['cos_hmac_keys']['secret_access_key'])
  


