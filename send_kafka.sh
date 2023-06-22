#!/bin/bash

CC_BOOTSTRAP="<confluent cloud bootstrap server>"
CC_APIKEY="<api key>"
CC_SECRET="<secret>"
CC_SECURE="-X security.protocol=SASL_SSL -X sasl.mechanism=PLAIN -X sasl.username=${CC_APIKEY} -X sasl.password=${CC_SECRET}"
CLIENT_ID="<client id>"
LON="0.0"
LAT="0.0"
TOPIC_NAME="adsb-raw"

nc localhost 30003 \
    | awk -F "," '{ print $5 "|" $0 }' \
    | kafkacat -P \
        -t ${TOPIC_NAME} \ 
        -b ${CC_BOOTSTRAP} \
        -H "ClientID=${CLIENT_ID}" \
        -H "ReceiverLon=${LON}" \
        -H "ReceiverLat=${LAT}" \
        -K "|" \
        ${CC_SECURE}
