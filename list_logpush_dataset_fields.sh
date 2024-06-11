#!/bin/sh

#=======================================================================================
# File Name: list_logpush_dataset_fields.sh
# Description: Listup dataset field
# Requirement:
# - Platform: Mac, Linux
# - Environment Variables: CLOUDFLARE_EMAIL, CLOUDFLARE_APIKEY, CLOUDFLARE_ACCOUNT_ID
# - Command: curl
#=======================================================================================

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

EMAIL=${CLOUDFLARE_EMAIL}
APIKEY=${CLOUDFLARE_APIKEY}
ACCOUNT_ID=${CLOUDFLARE_ACCOUNT_ID}
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
