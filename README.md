# plt-airt-2000
ADS-B processing stuff using "big data" tools.

## General approach

Data source is a Raspberry Pi 2 B running dump1090 software. Using Malcolm Robb's fork: https://github.com/MalcolmRobb/dump1090.

The program receives data via a DVB-T stick with winecork antenna. Setup mainly according to: http://www.satsignal.eu/raspberry-pi/dump1090.html.

Data exchange via WiFi dongle.

## Data transfer

dump1090 listens for incoming connections on port 30003 and will start writing comma separated records when a client connects. This repo also contains a small simulator that can replay a previously collected data file, servicing port 30003 as well.
