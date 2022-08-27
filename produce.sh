#!/bin/bash

# run this on Raspi

KCAT=kafkacat
CFGFILE=$1
TOPIC="adsb-raw"

nc localhost 30003 | ${KCAT} -P -t ${TOPIC} -F ${CFGFILE}
