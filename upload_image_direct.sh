#!/bin/sh

#=======================================================================================
# File Name: upload_image_direct.sh
# Description: Do testing repeatedly about how long direct_upload API takes
# Requirement:
# - Platform: Mac, Linux
# - Environment Variables: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_AUTH_TOKEN
# - Command: curl, perl, jq
#=======================================================================================

if [ $# != 4 ] && [ $# != 5 ]; then
  echo
  echo "$0 <Image Path> <Repeat Number> <Interval> <Mode> [Delete Option]"
  echo
  echo "  Image Path: Local file path for the input image"
  echo "  Repeat Number: The number to repeat file upload"
  echo "  Interval: Seconds for each interval in the loop"
  echo "  Mode: Choose 'general' or 'batch' for API call (general: call general API, batch: use batch API)"
  echo "  Delete Option: Put 'N' if you want to keep the uploaded files (default is 'Y')"
  echo
  exit 1
fi

FILEPATH=$1
NUM=$2
INTERVAL=$3
DATETIME=$( date "+%Y%m%d%H%M%S" )
OUTPUTFILE_1="direct_${DATETIME}_1.txt"
OUTPUTFILE_2="direct_${DATETIME}_2.txt"
LOGFILE="direct_${DATETIME}.log"
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

if [ $4 = "batch" ]; then
  BATCH="Y"
elif [ $4 = "general" ]; then
  BATCH="N"
else
  echo
  echo "$0 <Image Path> <Repeat Number> <Interval> <Mode> [Delete Option]"
  echo
  echo "  Mode needs to be 'batch' or 'general'"
  echo
  exit 1
fi

if [ $# = 5 ]; then
  if [ $5 != "Y" ] && [ $5 != "N" ]; then
    echo
    echo "$0 <Image Path> <Repeat Number> <Interval> [Delete Option]"
    echo
    echo "  Delete Option needs to be 'Y' or 'N'"
    echo
    exit 1
  else
    DELETE=$5
  fi
fi

TOTAL=0

#======= Start Logging =======

echo "FILEPATH = ${FILEPATH}" | tee -a ${LOGFILE}
echo "NUM = ${NUM}" | tee -a ${LOGFILE}
echo "INTERVAL = ${INTERVAL}" | tee -a ${LOGFILE}
echo "BATCH = ${BATCH}" | tee -a ${LOGFILE}
echo "DELETE = ${DELETE}" | tee -a ${LOGFILE}
echo "OUTPUTFILE_1 = ${OUTPUTFILE_1}"
echo "OUTPUTFILE_2 = ${OUTPUTFILE_2}"
echo "LOGIFLE = ${LOGFILE}"
echo

#======= Output Result (Header) =======

echo "Date Time, Count, Elapsed Time, Result" > ${OUTPUTFILE_1}
echo "Date Time, Count, Elapsed Time, Result" > ${OUTPUTFILE_2}

COUNT=1

while :
do

  echo "COUNT = $COUNT" | tee -a ${LOGFILE}

  #======= Get Batch Token =======

  if [ $BATCH = "Y" ]; then

    COMMAND="curl \
    --url https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/images/v1/batch_token \
    --header 'Authorization: Bearer ${CF_AUTH_TOKEN}'"

    echo "COMMAND = $COMMAND" | tee -a ${LOGFILE}

    RESPONSE=$(eval ${COMMAND} 2> /dev/null)

    SUCCESS=$(echo $RESPONSE | jq '.success')
    BATCH_TOKEN=$(echo $RESPONSE | jq '.result.token')
    BATCH_TOKEN=$(echo ${BATCH_TOKEN} | tr -d '"')

    echo "RESPONSE =  $RESPONSE" | tee -a ${LOGFILE}
  fi

  #======= Get Upload URL =======

  STIME="-"
  SDATETIME="-"
  RESPONSE="-"
  SUCCESS="-"
  RESULT="-"
  ETIME="-"
  ELAPSE="-"

  echo

  if [ $BATCH = "Y" ]; then
    COMMAND="curl --request POST \
      --url https://batch.imagedelivery.net/images/v2/direct_upload \
      --header 'Authorization: Bearer ${BATCH_TOKEN}' \
      --form 'requireSignedURLs=true' \
      --form 'metadata={\"key\":\"value\"}'"
  else
    COMMAND="curl --request POST \
      --url https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/images/v2/direct_upload \
      --header 'Authorization: Bearer ${CF_AUTH_TOKEN}' \
      --form 'requireSignedURLs=true' \
      --form 'metadata={\"key\":\"value\"}'"
  fi

  echo "COMMAND = $COMMAND" | tee -a ${LOGFILE}

  STIME=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)' )
  SDATETIME=$( date "+%Y/%m/%d %H:%M:%S" )

  RESPONSE=$(eval ${COMMAND} 2> /dev/null)

  CUSTOM_ID=$(echo $RESPONSE | jq '.result.id')
  CUSTOM_ID=$(echo $CUSTOM_ID | tr -d '"')
  UPLOAD_URL=$(echo $RESPONSE | jq '.result.uploadURL')
  UPLOAD_URL=$(echo ${UPLOAD_URL} | tr -d '"')

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
    echo "${SDATETIME}, ${COUNT}/${NUM}, ${ELAPSE}, ${RESULT}" >> ${OUTPUTFILE_1}
  else
    echo "${SDATETIME}, ${COUNT}, ${ELAPSE}, ${RESULT}" >> ${OUTPUTFILE_1}
  fi


  #======= Upload Image =======

  STIME="-"
  SDATETIME="-"
  RESPONSE="-"
  SUCCESS="-"
  RESULT="-"
  ETIME="-"
  ELAPSE="-"

  COMMAND="curl --request POST \
<<<<<<< HEAD
  --url https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/images/v2/direct_upload \
  --header 'Authorization: Bearer ${CLOUDFLARE_AUTH_TOKEN}' \
  --form 'requireSignedURLs=true' \
  --form 'metadata={\"key\":\"value\"}'"
=======
    --url ${UPLOAD_URL} \
    --form 'file=@${FILEPATH}'"
>>>>>>> 6eeb1182ddcbe1e95782d38b95513c78ca6c4a27

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
    echo "${SDATETIME}, ${COUNT}/${NUM}, ${ELAPSE}, ${RESULT}" >> ${OUTPUTFILE_2}
  else
    echo "${SDATETIME}, ${COUNT}, ${ELAPSE}, ${RESULT}" >> ${OUTPUTFILE_2}
  fi


  #======= Delete Image =======

  IMAGE_ID=$(echo $RESPONSE | jq '.result.id')
  echo "IMAGE_ID = ${IMAGE_ID}" | tee -a ${LOGFILE}

  RESPONSE="-"

  if [ ${DELETE} = "Y" ]; then

    COMMAND="curl --request DELETE \
    --url https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/images/v1/${IMAGE_ID} \
    --header 'Authorization: Bearer ${CLOUDFLARE_AUTH_TOKEN}' \
    --header 'Content-Type: appklication/json'"

    echo "COMMAND = $COMMAND" | tee -a ${LOGFILE}

    RESPONSE=$(eval ${COMMAND} 2> /dev/null)

    echo "RESPONSE = $RESPONSE" | tee -a ${LOGFILE}
  fi
<<<<<<< HEAD
=======

  #======= Break from the loop =======
  COUNT=`expr $COUNT + 1`

  if [ $NUM -ne 0 ]; then
    if [ $NUM -lt $COUNT ]; then
      break
    fi
  fi

  sleep $INTERVAL
>>>>>>> 6eeb1182ddcbe1e95782d38b95513c78ca6c4a27
done
