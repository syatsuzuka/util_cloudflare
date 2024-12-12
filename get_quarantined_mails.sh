#!/bin/sh

#=======================================================================================
# File Name: get_quarantined_emails
# Description: get a list of quarantined emails with Cloudflare Email Security's API
# Requirement:
# - Platform: Mac, Linux
# - Environment Variables: CLOUDFLARE_AREA1_PUBKEY, CLOUDFLARE_AREA1_PRIKEY
# - Command: curl
#=======================================================================================

if [ $# != 1 ] && [ $# != 2 ]; then
  echo
  echo "$0 <Since> [Limit]"
  echo
  echo "  Since: from date (i.e. 20230901)"
  echo "  Limit:  number of limit in fetch (default: 0 - no limit)"
  echo
  echo "if you want to convert from json to csv"
  echo "get_quarantined_mails.sh <Since> | jq -r '.data[]|[.subject, .from, .to[], .detection_reasons[],.is_quarantined]|@csv'"
  echo
  exit 1
fi

SINCE=$1
LIMIT=0

if [ -n "$2" ]; then
  LIMIT=$2
fi

#======= Output Param =======

echo "SINCE = ${SINCE}" 1>&2
echo "LIMIT = ${LIMIT}" 1>&2

COMMAND="curl -u ${CLOUDFLARE_AREA1_PUBKEY}:${CLOUDFLARE_AREA1_PRIKEY} https://api.area1security.com/quarantined-messages?since=${SINCE}"

if [ ${LIMIT} -ne 0 ]; then
  COMMAND="${COMMAND}&limit=${LIMIT}"
fi

COMMAND="${COMMAND} | jq ."

echo ${COMMAND} 1>&2
eval ${COMMAND}

