# plt-airt-2000
ADS-B processing stuff using "big data" tools.

## General approach

Data source is a Raspberry Pi 2 B running dump1090 software. Using Malcolm Robb's fork: https://github.com/MalcolmRobb/dump1090.

The program receives data via a DVB-T stick with winecork antenna. Setup mainly according to: http://www.satsignal.eu/raspberry-pi/dump1090.html
Winecork antenna is described in
http://www.rtl-sdr.com/adsb-aircraft-radar-with-rtl-sdr/.
There are also a lot better antenna setups, but this one gives up to 200 km range from my home in Utrecht.

Data exchange via WiFi dongle.

## NEW setup 2023

You need only 2 files

- send_kafka.sh, enter all your detail here, including Confluent Cloud credentials and your unique ID per receiver
- dump1090-kafka.service, systemd definition file, update the path to send_kafka in this definition and then install to /etc/systemd/system, enable and start

### Setup instructions

- On your Raspberry, set up the flight radar receiver, for instance from this repo https://github.com/MalcolmRobb/dump1090, or from https://www.flightradar24.com/
- clone this repo to the raspberry: https://github.com/hellmarbecker/plt-airt-2000
- in your home directory, (I assume /home/pi), create a copy of plt-airt-2000/raspberry/send_kafka.sh
- edit this copy:
  - overwrite the Confluent credentials with the correct ones (`CC_BOOTSTRAP`, `CC_APPIKEY`, `CC_SECRET`)
  - enter a unique string for `CLIENT_ID` (you can just use your name)
  - enter your own geo coordinates for `LON` and `LAT`
- make sure the script is executable
- copy file plt-airt-2000/raspberry/dump1090-kafka.service to /etc/systemd/system/
- make sure the path in `ExecStart=/home/pi/plt-airt-2000/send_kafka.sh` points to your customized script
- enable and start the service

## Raspi setup notes

- For headless setup, check https://www.raspberrypi.org/forums/viewtopic.php?t=74176.

- Default setup for rsyslogd will try to write to console and fail, writing lots of messages to /var/log/messages. To fix this, see here: https://blog.dantup.com/2016/04/removing-rsyslog-spam-on-raspberry-pi-raspbian-jessie/.

- In /etc/ssh/sshd_config, set `PermitRootLogin no`.

- Disable WiFi power saving by editing /etc/network/interfaces and adding a line to `wlan0` configuration like so:

```
allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
wireless-power off
```

- Adding systemd service definition files for dump1090, Minifi, connect.sh (TBD)

## Data sourcing

dump1090 listens for incoming connections on port 30003 and will start writing comma separated records when a client connects. 

### Simulator

This repo also contains a small simulator (serve_data.py) that can replay a previously collected data file, servicing port 30003 as well.

## Data transfer

1.  Kafka VM cluster from: https://github.com/elodina/scala-kafka.git

    Note: if the host is Windows, need to make sure that the files in the vagrant and checks subdirectories have Unix line endings!

2.  Install Docker based Kafka cluster on a single Linux VM. See linux-install-notes.md

## Data transfer, preferred approach

1. NiFi single machine "cluster" to move data in, on AWS

2. MiNiFi on the Raspi

Setup based on the excellent article by Andrew Psaltis:
https://community.hortonworks.com/articles/56341/getting-started-with-minifi.html

### MiNiFi side (Raspi)

Using the TCP Listen processor on MiNiFi. Since dump1090 is listening (acting as a server) itself, connect the ends like this:

```
nc localhost 30003 | nc localhost 4711
```
For now, using connect.sh script to transfer data from 30003 to a listening port (ListenTCP processor) on MiNiFi.

### NiFi side (HDF 2.0 on AWS) 

1. Parse and process the data by using first ConvertCSVToAvro and then ConvertAvroToJSON. Avro schema is in the repo, for explanation and example see:

   https://avro.apache.org/docs/1.8.0/gettingstartedjava.html#Compiling+the+schema
   
2. Merge data together into ORC files by cascading two MergeContent processors. Note that with just one processor, NiFi will consume excessive heap space and crash.

## Processing

TODO - use Spark to get interesting aggs

## Visualization

Use Google Maps API?

## Kafka Client

### C Client

Pilfered from Confluent examples. This simply takes whatever it gets and writes it to a Kafka topic. No key is added at this stage. 

Note that librdkafka has to be available on the Raspi (`sudo apt-get install librdkafka-dev`).

Call like this:

```
nc localhost 30003 | ./producer adsb-raw ~/.ccloud/example.config 
```

This was done on purpose - original idea was to parse the key already during data generation, like so:
```
nc localhost 30003 | perl -ne 'my @x=split /,/;print "$x[4]|$_"' | ./producer test-topic ~/.ccloud/example.config
```
and have a producer client that splits key and value at the pipe character. However, it is more interesting to do that part in KSQL.

### Using `kafkacat` as Kafka client

The easiest way to get data into Kafka is probably by using `kafkacat`. The included shell script `send_kafka.sh` does the following:
- Gets ADS-B data in CSV format by connecting to dump1090 on port 30003
- Extracts the Hex code as key and prepends it to the record
- Uses `kafkacat` to send data to Confluent Cloud
