#!/bin/bash

CC_BOOTSTRAP="pkc-p11xm.us-east-1.aws.confluent.cloud:9092"
CC_APIKEY="65PJKHQIEETRTFRX"
CC_SECRET="9t1vjre/gTjm4R/y9YstwAdh778Hfs0n1+Mgj0FSki5o4rsA7kRhW/sqQOh1zNQk"
CC_SECURE="-X security.protocol=SASL_SSL -X sasl.mechanism=PLAIN -X sasl.username=${CC_APIKEY} -X sasl.password=${CC_SECRET}"
CLIENT_ID="demo"

python3 /home/admin/get_gps.py

GPSTIME=$(cat /home/admin/time.txt)
GPSLAT=$(cat /home/admin/lat.txt)
GPSLON=$(cat /home/admin/lon.txt)

echo "Got GPS data $GPSTIME $GPSLAT $GPSLON"

if [[ $GPSTIME != "0" ]]; then
  echo "Using GPS time" 
  CLIENT_TIMEZONE=$(date --date=$GPSTIME +"%Z")
else
  CLIENT_TIMEZONE=$(date +"%Z")
fi

LAT="51.4147"
LON="-0.0299"

if [[ $GPSLAT != "0" ]]; then
  echo "Using lattitude from GPS"
  LAT=$GPSLAT
fi

if [[ $GPSLON != "0" ]]; then
  echo "Using longitude from GPS"
  LON=$GPSLON
fi

TOPIC_NAME="adsb-raw"

nc localhost 30003 \
    | awk -F "," '{ print $5 "|" $0 }' \
    | kcat -P \
        -t ${TOPIC_NAME} \
        -b ${CC_BOOTSTRAP} \
        -H "ClientID=${CLIENT_ID}" \
        -H "ClientTimezone=${CLIENT_TIMEZONE}" \
        -H "ReceiverLon=${LON}" \
        -H "ReceiverLat=${LAT}" \
        -K "|" \
        ${CC_SECURE}
