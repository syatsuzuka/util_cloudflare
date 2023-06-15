#!/bin/sh

if [ $# != 1 ]; then
  echo
  echo "$0 <Dataset Name>"
  echo
  echo "  Dataset Name: name of dataset (i.e. zero_trust_network_sessions)"
  echo
  exit 1
fi

#======= Parameter Set =======

DATASET=$1

EMAIL=${CF_EMAIL}
APIKEY=${CF_APIKEY}
ACCOUNT_ID=${CF_ACCOUNT_ID}
API_TYPE='accounts'

echo
echo "EMAIL = ${EMAIL}"
echo "ACCOUNT_ID = ${ACCOUNT_ID}"

#======= Command =======

COMMAND="curl -s \"https://api.cloudflare.com/client/v4/${API_TYPE}/${ACCOUNT_ID}/logpush/datasets/${DATASET}/fields\" \
-H \"X-Auth-Email: $EMAIL\" \
-H \"X-Auth-Key: $APIKEY\" | jq ." 

echo "COMMAND = ${COMMAND}"

eval ${COMMAND}
