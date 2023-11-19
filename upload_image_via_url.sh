#!/bin/sh

if [ $# != 2 ] && [ $# != 3 ]; then
  echo
  echo "$0 <Image Path> <Repeat Number> [Delete Option]"
  echo
  echo "  Image Path (URL): URL of the input image"
  echo "  Repeat Number: The number to repeat file upload"
  echo "  Delete Option: Put 'N' if you want to keep the uploaded files (default is 'Y')"
  echo
  exit 1
fi

URL=$1
NUM=$2
DATETIME=$( date "+%Y%m%d%H%M%S" )
OUTPUTFILE="${DATETIME}.txt"
LOGFILE="${DATETIME}.log"
REPORTLOG
DELETE="Y"

if [ $# = 3 ]; then
  if [ $3 != "Y" ] && [ $3 != "N" ]; then
    echo
    echo "$0 <Image Path> <Repeat Number> <Result File Name> [Delete Option]"
    echo
    echo "  Delete Option needs to be 'Y' or 'N'"
    echo
    exit 1
  else
    DELETE=$3
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


for ((i=0; i<${NUM}; i++))
do

  COUNT=$(($i+1))
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

  echo "${SDATETIME}, ${COUNT} / ${NUM}, ${ELAPSE}, ${RESULT}" >> ${OUTPUTFILE}


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
done