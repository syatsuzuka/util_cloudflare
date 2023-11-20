#!/bin/sh

#=======================================================================================
# File Name: list_logpush_jobs.sh
# Description: Listup registered logpush jobs
# Requirement:
# - Platform: Mac, Linux
# - Environment Variables: CF_EMAIL, CF_APIKEY, CF_ACCOUNT_ID
# - Command: curl
#=======================================================================================

if [ $# != 0 ]; then
  echo
  echo "$0"
  echo
  exit 1
fi

#======= Parameter Set =======

EMAIL=${CF_EMAIL}
APIKEY=${CF_APIKEY}
ACCOUNT_ID=${CF_ACCOUNT_ID}
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
