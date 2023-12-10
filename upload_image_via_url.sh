#!/bin/sh

#=======================================================================================
# File Name: upload_image_via_url.sh
# Description: Do testing repeatedly about how long image upload via URL takes
# Requirement:
# - Platform: Mac, Linux
# - Environment Variables: CF_ACCOUNT_ID, CF_AUTH_TOKEN
# - Command: curl, perl, jq
#=======================================================================================

if [ $# != 3 ] && [ $# != 4 ]; then
  echo
  echo "$0 <Image Path> <Repeat Number> <Interval> [Delete Option]"
  echo
  echo "  Image Path (URL): URL of the input image"
  echo "  Repeat Number: The number to repeat file upload (0: infinite loop)"
  echo "  Interval: Seconds for each interval in the loop"
  echo "  Delete Option: Put 'N' if you want to keep the uploaded files (default is 'Y')"
  echo
  exit 1
fi

URL=$1
NUM=$2
INTERVAL=$3
DATETIME=$( date "+%Y%m%d%H%M%S" )
OUTPUTFILE="indirect_${DATETIME}.txt"
LOGFILE="indirect_${DATETIME}.log"
REPORTLOG
DELETE="Y"

if [ $NUM = 0 ]; then
  if [ $INTERVAL -lt 60 ]; then
    echo
    echo "$0 <Image Path> <Repeat Number> <Interval> [Delete Option]"
    echo
    echo "  Interval needs to be more than 10 seconds for infinite loop (NUM = 0)"
    echo
    exit 1
  fi
fi

if [ $# = 4 ]; then
  if [ $4 != "Y" ] && [ $4 != "N" ]; then
    echo
    echo "$0 <Image Path> <Repeat Number> <Interval> [Delete Option]"
    echo
    echo "  Delete Option needs to be 'Y' or 'N'"
    echo
    exit 1
  else
    DELETE=$4
  fi
fi

TOTAL=0

echo "URL = ${URL}" | tee -a ${LOGFILE}
echo "NUM = ${NUM}" | tee -a ${LOGFILE}
echo "DELETE = ${DELETE}" | tee -a ${LOGFILE}
echo "OUTPUTFILE = ${OUTPUTFILE}"
echo "LOGIFLE = ${LOGFILE}"
echo

#======= Output Result (Header) =======

echo "Date Time, Count, Elapsed Time, Result" > ${OUTPUTFILE}

COUNT=1

while :
do

  echo "COUNT = $COUNT" | tee -a ${LOGFILE}

  #======= Upload Image =======

  STIME="-"
  SDATETIME="-"
  RESPONSE="-"
  SUCCESS="-"
  RESULT="-"
  ETIME="-"
  ELAPSE="-"

  echo

  COMMAND="curl --request POST \
  --url https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/images/v1 \
  --header 'Authorization: Bearer ${CF_AUTH_TOKEN}' \
  --form 'url=${URL}' \
  --form 'metadata={\"key\":\"value\"}' \
  --form 'requireSignedURLs=false'"

  echo "COMMAND = $COMMAND" | tee -a ${LOGFILE}

  STIME=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)' )
  SDATETIME=$( date "+%Y/%m/%d %H:%M:%S" )

  RESPONSE=$(eval ${COMMAND} 2> /dev/null)

  ETIME=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)' )
  ELAPSE=$((${ETIME}-${STIME}))
  TOTAL=$((${TOTAL}+${ELAPSE}))
  SUCCESS=$(echo $RESPONSE | jq '.success')

  if [ ${SUCCESS} = "true" ]; then
    RESULT="SUCCESS";
  else
    RESULT="ERROR";
  fi

  echo "RESPONSE = $RESPONSE" | tee -a ${LOGFILE}
  echo "SDATETIME = $SDATETIME" | tee -a ${LOGFILE}
  echo "STIME = $STIME"
  echo "ETIME = $ETIME"
  echo "ELAPSE = $ELAPSE"
  echo

  if [ $NUM -ne 0 ]; then
    echo "${SDATETIME}, ${COUNT}/${NUM}, ${ELAPSE}, ${RESULT}" >> ${OUTPUTFILE}
  else
    echo "${SDATETIME}, ${COUNT}, ${ELAPSE}, ${RESULT}" >> ${OUTPUTFILE}
  fi


  #======= Delete Image =======

  IMAGE_ID=$(echo $RESPONSE | jq '.result.id')
  echo "IMAGE_ID = ${IMAGE_ID}" | tee -a ${LOGFILE}

  RESPONSE="-"

  if [ ${DELETE} = "Y" ]; then

    COMMAND="curl --request DELETE \
    --url https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/images/v1/${IMAGE_ID} \
    --header 'Authorization: Bearer ${CF_AUTH_TOKEN}' \
    --header 'Content-Type: appklication/json'"

    echo "COMMAND = $COMMAND" | tee -a ${LOGFILE}

    RESPONSE=$(eval ${COMMAND} 2> /dev/null)

    echo "RESPONSE = $RESPONSE" | tee -a ${LOGFILE}
  fi


  #======= Break from the loop =======
  COUNT=`expr $COUNT + 1`

  if [ $NUM -ne 0 ]; then
    if [ $NUM -lt $COUNT ]; then
      break
    fi
  fi

  sleep $INTERVAL
done
