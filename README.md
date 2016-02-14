# plt-airt-2000
ADS-B processing stuff using "big data" tools.

## General approach

Data source is a Raspberry Pi 2 B running dump1090 software. Using Malcolm Robb's fork: https://github.com/MalcolmRobb/dump1090.

The program receives data via a DVB-T stick with winecork antenna. Setup mainly according to: http://www.satsignal.eu/raspberry-pi/dump1090.html
Winecork antenna is described in
http://www.rtl-sdr.com/adsb-aircraft-radar-with-rtl-sdr/.
There are also a lot better antenna setups, but this one gives up to 200 km range from my home in Utrecht.

Data exchange via WiFi dongle.

## Data sourcing

dump1090 listens for incoming connections on port 30003 and will start writing comma separated records when a client connects. This repo also contains a small simulator that can replay a previously collected data file, servicing port 30003 as well.

## Data transfer

Kafka VM cluster from: https://github.com/elodina/scala-kafka.git

Note: if the host is Windows, need to make sure that the files in the vagrant and checks subdirectories have Unix line endings

## Processing

TODO - use Spark to get interesting aggs

## Visualization

Use Google Maps API?
