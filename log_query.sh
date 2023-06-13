#!/bin/sh 

if [ $# != 2 ] && [ $# != 3 ]; then
  echo
  echo "$0 <Bucket Name> <Start Time> [End Time]"
  echo
  echo "  Bucket Name: name of R2 bucket"
  echo "  Start Time: Start Time for query (i.e. 2023-05-04T16:00:00Z)"
  echo "  End Time: End Time for query. Default time is now (i.e. 2023-05-06T16:00:00Z)"
  echo
  exit 1
fi

BUCKET_NAME=$1
START_TIME="2023-01-01T00:00:00Z"
END_TIME=`date -u "+%Y-%m-%dT%H:%M:%SZ"`

if [ -n "$2" ]; then
  START_TIME=$2
fi

if [ -n "$3" ]; then
  END_TIME=$3
fi

#======= Ouptut Param =======

echo
echo "BUCKET_NAME = ${BUCKET_NAME}"
echo "START_TIME = ${START_TIME}"
echo "END_TIME = ${END_TIME}"

#======= Run Command =======

COMMAND="curl -s -g -X GET  \"https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/logs/retrieve?start=${START_TIME}&end=${END_TIME}&bucket=${BUCKET_NAME}\" \
-H \"X-Auth-Email: ${CF_EMAIL}\" \
-H \"X-Auth-Key: ${CF_APIKEY}\" \
-H \"R2-Access-Key-Id: ${R2_ACCESS_KEY_ID}\" \
-H \"R2-Secret-Access-Key: ${R2_SECRET_ACCESS_KEY}\" | jq ."

echo "COMMAND = $COMMAND"

echo
eval ${COMMAND}
