#!/bin/sh 

#=======================================================================================
# File Name: log_query.sh
# Description: Query logs from R2
# Requirement:
# - Platform: Mac, Linux
# - Environment Variables: CF_EMAIL, CF_APIKEY, CF_ACCOUNT_ID, CF_AUTH_TOKEN
#     R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY
# - Command: curl
#=======================================================================================

if [ $# != 3 ] && [ $# != 4 ]; then
  echo
  echo "$0 <Bucket Name> <Prefix> <Start Time> [End Time]"
  echo
  echo "  Bucket Name: name of R2 bucket"
  echo "  Prefix: prefix in R2 bucket"
  echo "  Start Time: Start Time for query (i.e. 2023-05-04T16:00:00Z)"
  echo "  End Time: End Time for query. Default time is now (i.e. 2023-05-06T16:00:00Z)"
  echo
  exit 1
fi

BUCKET_NAME=$1
PREFIX=$2
START_TIME="2023-01-01T00:00:00Z"
END_TIME=`date -u "+%Y-%m-%dT%H:%M:%SZ"`

if [ -n "$3" ]; then
  START_TIME=$3
fi

if [ -n "$4" ]; then
  END_TIME=$4
fi

#======= Ouptut Param =======

echo 1>&2
echo "BUCKET_NAME = ${BUCKET_NAME}" 1>&2
echo "PREFIX = ${PREFIX}" 1>&2
echo "START_TIME = ${START_TIME}" 1>&2
echo "END_TIME = ${END_TIME}" 1>&2

#======= Run Command =======

COMMAND="curl -s -g -X GET  \"https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/logs/retrieve?start=${START_TIME}&end=${END_TIME}&bucket=${BUCKET_NAME}&prefix=${PREFIX}\" \
-H \"X-Auth-Email: ${CF_EMAIL}\" \
-H \"X-Auth-Key: ${CF_APIKEY}\" \
-H \"R2-Access-Key-Id: ${R2_ACCESS_KEY_ID}\" \
-H \"R2-Secret-Access-Key: ${R2_SECRET_ACCESS_KEY}\" | jq ."

echo "COMMAND = $COMMAND" 1>&2

echo 1>&2
eval ${COMMAND}
