# plt-airt-2000
ADS-B processing stuff using "big data" tools.

## General approach

Data source is a Raspberry Pi 2 B running dump1090 software. Using Malcolm Robb's fork: https://github.com/MalcolmRobb/dump1090.

The program receives data via a DVB-T stick with winecork antenna. Setup mainly according to: http://www.satsignal.eu/raspberry-pi/dump1090.html
Winecork antenna is described in
http://www.rtl-sdr.com/adsb-aircraft-radar-with-rtl-sdr/.
There are also a lot better antenna setups, but this one gives up to 200 km range from my home in Utrecht.

Data exchange via WiFi dongle.

## Raspi setup notes

- Default setup for rsyslogd will try to write to console and fail, writing lots of messages to /var/log/messages. To fix this, see here: https://blog.dantup.com/2016/04/removing-rsyslog-spam-on-raspberry-pi-raspbian-jessie/

- In /etc/ssh/sshd_config, set `PermitRootLogin no`.

- Adding systemd service definition files for dump1090, Minifi, connect.sh.

- Disable WiFi power saving by editing /etc/network/interfaces and adding a line to `wlan0` configuration like so:

```
allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
wireless-power off
```

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
