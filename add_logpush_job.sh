#!/bin/sh

#=======================================================================================
# File Name: add_logpush_job.sh
# Description: Add an account level logpush job for R2
# Requirement:
# - Platform: Mac, Linux
# - Environment Variables: CLOUDFLARE_EMAIL, CLOUDFLARE_APIKEY, CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_AUTH_TOKEN
#     R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY
# - Command: curl
#=======================================================================================

if [ $# != 3 ]; then
  echo
  echo "$0 <Dataset Name> <Bucket Name> <Job Name>"
  echo
  echo "  Dataset Name: name of dataset (i.e. zero_trust_network_sessions)"
  echo "  Bucket Name: name of R2 bucket"
  echo "  Job Name: name of logpush job"
  echo
  exit 1
fi

#======= Parameter Set =======

DATASET=$1
BUCKET_NAME=$2
LP_NAME=$3

EMAIL=${CLOUDFLARE_EMAIL}
APIKEY=${CLOUDFLARE_APIKEY}
ACCOUNT_ID=${CLOUDFLARE_ACCOUNT_ID}
API_TYPE='accounts'
DEST_BUCK="r2://${BUCKET_NAME}/{DATE}?account-id=${ACCOUNT_ID}&access-key-id=${R2_ACCESS_KEY_ID}&secret-access-key=${R2_SECRET_ACCESS_KEY}"
OWNER_CHALL=''

echo
echo "EMAIL = ${EMAIL}"
echo "ACCOUNT_ID = ${ACCOUNT_ID}"
echo "DEST_BUCK = ${DEST_BUCK}"

#======= Get Fieldnames =======

FIELDS=$(curl -s \
-H "X-Auth-Email: $EMAIL" \
-H "X-Auth-Key: $APIKEY" \
"https://api.cloudflare.com/client/v4/${API_TYPE}/${ACCOUNT_ID}/logpush/datasets/${DATASET}/fields" | jq -r '.result | keys | join(",")')

echo "FIELDS = ${FIELDS}"


#======= Run Command =======
COMMAND="curl -s \"https://api.cloudflare.com/client/v4/$API_TYPE/$ACCOUNT_ID/logpush/jobs\" -X POST -d ' 
{ 
  \"name\": \"$LP_NAME\", 
  \"logpull_options\": \"fields='$FIELDS'\", 
  \"destination_conf\": \"$DEST_BUCK\", 
  \"ownership_challenge\": \"$OWNER_CHALL\", 
  \"dataset\": \"$DATASET\", 
  \"enabled\": true 
}'  
-H \"X-Auth-Email: $EMAIL\" \
-H \"X-Auth-Key: $APIKEY\""

echo "COMMAND = ${COMMAND}"

eval ${COMMAND}
