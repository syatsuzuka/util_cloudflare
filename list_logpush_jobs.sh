#!/bin/sh

#=======================================================================================
# File Name: list_logpush_jobs.sh
# Description: Listup registered logpush jobs
# Requirement:
# - Platform: Mac, Linux
# - Environment Variables: CLOUDFLARE_EMAIL, CLOUDFLARE_APIKEY, CLOUDFLARE_ACCOUNT_ID
# - Command: curl
#=======================================================================================

if [ $# != 0 ]; then
  echo
  echo "$0"
  echo
  exit 1
fi

#======= Parameter Set =======

EMAIL=${CLOUDFLARE_EMAIL}
APIKEY=${CLOUDFLARE_APIKEY}
ACCOUNT_ID=${CLOUDFLARE_ACCOUNT_ID}
API_TYPE='accounts'

echo
echo "EMAIL = ${EMAIL}"
echo "ACCOUNT_ID = ${ACCOUNT_ID}"

#======= Run Command =======
COMMAND="curl -s \"https://api.cloudflare.com/client/v4/$API_TYPE/$ACCOUNT_ID/logpush/jobs\" -X GET \
-H \"X-Auth-Email: $EMAIL\" \
-H \"X-Auth-Key: $APIKEY\" | jq ."

echo "COMMAND = ${COMMAND}"

eval ${COMMAND}
