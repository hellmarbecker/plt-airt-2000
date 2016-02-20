## 2016-02-15

Installed Vagrant:

    yum install vagrant

Installed Docker:

    yum install docker

Set up proxy to access external repos

    export http_proxy="http://*******:********@proxynlwp.europe.intranet:8080/"
    export https_proxy=$http_proxy

Install docker-compose as a container, according to https://docs.docker.com/compose/install/

    curl -L https://github.com/docker/compose/releases/download/1.6.0/run.sh > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

Download kafka docker package from http://wurstmeister.github.io/kafka-docker/, and untar it in root's home directory

    cd
    tar xfz wurstmeister-kafka-docker-0.9.0.0-6-ge03b1d6.tar.gz

Need to configure the proxy in Docker according to  http://stackoverflow.com/questions/23111631/cannot-download-docker-images-behind-a-proxy

    mkdir /etc/systemd/system/docker.service.d
    vi /etc/systemd/system/docker.service.d/http-proxy.conf
  
and enter:

    [Service]
    Environment="HTTP_PROXY=http://*******:********@proxynlwp.europe.intranet:8080/"
    Environment="HTTPS_PROXY=http://*******:********@proxynlwp.europe.intranet:8080/"

Flush changes:

    sudo systemctl daemon-reload

Verify that the configuration has been loaded:

    sudo systemctl show docker --property Environment

Restart Docker:

    sudo systemctl restart docker

then continue with http://wurstmeister.github.io/kafka-docker/:

    cd /root/wurstmeister-kafka-docker-e03b1d6
    docker-compose up
    
ends up with the error:

    ERROR: client is newer than server (client API version: 1.21, server API version: 1.20)
    
This is going to need docker-machine. Install it according to https://docs.docker.com/machine/install-machine/

    $ curl -L https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine
    $ docker-machine version
    docker-machine version 0.6.0, build e27fb87
    
and then upgrade docker machine according to http://hjgraca.github.io/2015/11/09/Docker-Error-client-newer-than-server/

or, that was the plan. Problem is, I have no "default" machine and nothing to upgrade!

Solution approach: Downgrade docker-compose, see release notes at https://github.com/docker/compose/releases

    rm /usr/local/bin/docker-compose
    curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

then retry:

    cd /root/wurstmeister-kafka-docker-e03b1d6
    docker-compose up

voilà! docker starts up. Next problem building kafka:

    Building kafka
    Step 0 : FROM anapsix/alpine-java
    not found
    latest: Pulling from anapsix/alpine-java
    9d710148acd0: Pull complete
    e6c3b50b2a35: Pull complete
    39627d44a1f5: Pull complete
    b559691b8e30: Pull complete
    Digest: sha256:ebacbf1dd84aeb82d5784c5641d5a43dce95f9e9cd8d3d99f2126bf023648cd1
    Status: Downloaded newer image for docker.io/anapsix/alpine-java:latest
    
     ---> b559691b8e30
    Step 1 : MAINTAINER Wurstmeister
     ---> Running in 8915067bb2b5
     ---> 3d21fc9e799c
    Removing intermediate container 8915067bb2b5
    Step 2 : RUN apk add --update unzip wget curl docker jq coreutils
     ---> Running in d36f95db1375
    fetch http://dl-4.alpinelinux.org/alpine/v3.3/main/x86_64/APKINDEX.tar.gz
    ERROR: http://dl-4.alpinelinux.org/alpine/v3.3/main: temporary error (try again later)
    WARNING: Ignoring APKINDEX.d3812b7e.tar.gz: No such file or directory
    fetch http://dl-4.alpinelinux.org/alpine/v3.3/community/x86_64/APKINDEX.tar.gz
    ERROR: http://dl-4.alpinelinux.org/alpine/v3.3/community: temporary error (try again later)
    WARNING: Ignoring APKINDEX.bb2c5760.tar.gz: No such file or directory
    ERROR: unsatisfiable constraints:
      coreutils (missing):
        required by: world[coreutils]
      curl (missing):
        required by: world[curl]
      docker (missing):
        required by: world[docker]
      jq (missing):
        required by: world[jq]
      unzip (missing):
        required by: world[unzip]
      wget (missing):
        required by: world[wget]
    ERROR: Service 'kafka' failed to build: The command '/bin/sh -c apk add --update unzip wget curl docker jq coreutils' returned a non-zero code: 6
    
could be a proxy issue. Edit Dockerfile to include:

    ENV http_proxy "http://*******:********@proxynlwp.europe.intranet:8080/"
    ENV https_proxy "http://*******:********@proxynlwp.europe.intranet:8080/"

same error!

"Restarting the docker service on the host seems to have fixed the issue." -> https://github.com/gliderlabs/docker-alpine/issues/75

_TODO_: let's check if the proxy settings in Dockerfile and docker-compose.yml are really needed.

But first another problem: the alpine update works now but the kafka container still spews

    Step 13 : CMD start-kafka.sh
     ---> Running in 0f50d46f46b3
     ---> aa6aa0b3bc5f
    Removing intermediate container 0f50d46f46b3
    Successfully built aa6aa0b3bc5f
    Creating wurstmeisterkafkadockere03b1d6_kafka_1
    Attaching to wurstmeisterkafkadockere03b1d6_zookeeper_1, wurstmeisterkafkadockere03b1d6_kafka_1
    zookeeper_1 | JMX enabled by default
    zookeeper_1 | Using config: /opt/zookeeper-3.4.6/bin/../conf/zoo.cfg
    zookeeper_1 | 2016-02-18 19:34:50,944 [myid:] - INFO  [main:QuorumPeerConfig@103] - Reading configuration from: /opt/zookeeper-3.4.6/bin/../conf/zoo.cfg
    zookeeper_1 | 2016-02-18 19:34:50,950 [myid:] - INFO  [main:DatadirCleanupManager@78] - autopurge.snapRetainCount set to 3
    zookeeper_1 | 2016-02-18 19:34:50,950 [myid:] - INFO  [main:DatadirCleanupManager@79] - autopurge.purgeInterval set to 1
    zookeeper_1 | 2016-02-18 19:34:50,951 [myid:] - WARN  [main:QuorumPeerMain@113] - Either no config or no quorum defined in config, running  in standalone mode
    zookeeper_1 | 2016-02-18 19:34:50,951 [myid:] - INFO  [PurgeTask:DatadirCleanupManager$PurgeTask@138] - Purge task started.
    zookeeper_1 | 2016-02-18 19:34:50,961 [myid:] - INFO  [PurgeTask:DatadirCleanupManager$PurgeTask@144] - Purge task completed.
    zookeeper_1 | 2016-02-18 19:34:50,966 [myid:] - INFO  [main:QuorumPeerConfig@103] - Reading configuration from: /opt/zookeeper-3.4.6/bin/../conf/zoo.cfg
    zookeeper_1 | 2016-02-18 19:34:50,966 [myid:] - INFO  [main:ZooKeeperServerMain@95] - Starting server
    zookeeper_1 | 2016-02-18 19:34:50,976 [myid:] - INFO  [main:Environment@100] - Server environment:zookeeper.version=3.4.6-1569965, built on 02/20/2014 09:09 GMT
    zookeeper_1 | 2016-02-18 19:34:50,977 [myid:] - INFO  [main:Environment@100] - Server environment:host.name=0577e57cef73
    zookeeper_1 | 2016-02-18 19:34:50,977 [myid:] - INFO  [main:Environment@100] - Server environment:java.version=1.7.0_65
    zookeeper_1 | 2016-02-18 19:34:50,977 [myid:] - INFO  [main:Environment@100] - Server environment:java.vendor=Oracle Corporation
    zookeeper_1 | 2016-02-18 19:34:50,977 [myid:] - INFO  [main:Environment@100] - Server environment:java.home=/usr/lib/jvm/java-7-openjdk-amd64/jre
    zookeeper_1 | 2016-02-18 19:34:50,977 [myid:] - INFO  [main:Environment@100] - Server environment:java.class.path=/opt/zookeeper-3.4.6/bin/../build/classes:/opt/zookeeper-3.4.6/bin/../build/lib/*.jar:/opt/zookeeper-3.4.6/bin/../lib/slf4j-log4j12-1.6.1.jar:/opt/zookeeper-3.4.6/bin/../lib/slf4j-api-1.6.1.jar:/opt/zookeeper-3.4.6/bin/../lib/netty-3.7.0.Final.jar:/opt/zookeeper-3.4.6/bin/../lib/log4j-1.2.16.jar:/opt/zookeeper-3.4.6/bin/../lib/jline-0.9.94.jar:/opt/zookeeper-3.4.6/bin/../zookeeper-3.4.6.jar:/opt/zookeeper-3.4.6/bin/../src/java/lib/*.jar:/opt/zookeeper-3.4.6/bin/../conf:
    zookeeper_1 | 2016-02-18 19:34:50,977 [myid:] - INFO  [main:Environment@100] - Server environment:java.library.path=/usr/java/packages/lib/amd64:/usr/lib/x86_64-linux-gnu/jni:/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu:/usr/lib/jni:/lib:/usr/lib
    zookeeper_1 | 2016-02-18 19:34:50,977 [myid:] - INFO  [main:Environment@100] - Server environment:java.io.tmpdir=/tmp
    zookeeper_1 | 2016-02-18 19:34:50,980 [myid:] - INFO  [main:Environment@100] - Server environment:java.compiler=<NA>
    zookeeper_1 | 2016-02-18 19:34:50,980 [myid:] - INFO  [main:Environment@100] - Server environment:os.name=Linux
    zookeeper_1 | 2016-02-18 19:34:50,980 [myid:] - INFO  [main:Environment@100] - Server environment:os.arch=amd64
    zookeeper_1 | 2016-02-18 19:34:50,980 [myid:] - INFO  [main:Environment@100] - Server environment:os.version=3.10.0-327.4.5.el7.x86_64
    zookeeper_1 | 2016-02-18 19:34:50,980 [myid:] - INFO  [main:Environment@100] - Server environment:user.name=root
    zookeeper_1 | 2016-02-18 19:34:50,980 [myid:] - INFO  [main:Environment@100] - Server environment:user.home=/root
    zookeeper_1 | 2016-02-18 19:34:50,980 [myid:] - INFO  [main:Environment@100] - Server environment:user.dir=/opt/zookeeper-3.4.6
    zookeeper_1 | 2016-02-18 19:34:50,981 [myid:] - INFO  [main:ZooKeeperServer@755] - tickTime set to 2000
    zookeeper_1 | 2016-02-18 19:34:50,981 [myid:] - INFO  [main:ZooKeeperServer@764] - minSessionTimeout set to -1
    zookeeper_1 | 2016-02-18 19:34:50,981 [myid:] - INFO  [main:ZooKeeperServer@773] - maxSessionTimeout set to -1
    zookeeper_1 | 2016-02-18 19:34:50,996 [myid:] - INFO  [main:NIOServerCnxnFactory@94] - binding to port 0.0.0.0/0.0.0.0:2181
    kafka_1     | Error response from daemon: client is newer than server (client API version: 1.21, server API version: 1.20)
    kafka_1     | waiting for kafka to be ready
    kafka_1     | [2016-02-18 19:37:35,951] FATAL  (kafka.Kafka$)
    kafka_1     | org.apache.kafka.common.config.ConfigException: Invalid value  for configuration advertised.port: Not a number of type INT
    kafka_1     |   at org.apache.kafka.common.config.ConfigDef.parseType(ConfigDef.java:253)
    kafka_1     |   at org.apache.kafka.common.config.ConfigDef.parse(ConfigDef.java:145)
    kafka_1     |   at org.apache.kafka.common.config.AbstractConfig.<init>(AbstractConfig.java:49)
    kafka_1     |   at org.apache.kafka.common.config.AbstractConfig.<init>(AbstractConfig.java:56)
    kafka_1     |   at kafka.server.KafkaConfig.<init>(KafkaConfig.scala:702)
    kafka_1     |   at kafka.server.KafkaConfig$.fromProps(KafkaConfig.scala:691)
    kafka_1     |   at kafka.server.KafkaServerStartable$.fromProps(KafkaServerStartable.scala:28)
    kafka_1     |   at kafka.Kafka$.main(Kafka.scala:58)
    kafka_1     |   at kafka.Kafka.main(Kafka.scala)
    wurstmeisterkafkadockere03b1d6_kafka_1 exited with code 1

## 2016-02-19

Try a new image from Spotify https://github.com/spotify/docker-kafka

    docker run -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST=`docker-machine ip \`docker-machine active\`` --env ADVERTISED_PORT=9092 spotify/kafka
    
make this:

    docker run -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST=10.44.129.105 --env ADVERTISED_PORT=9092 spotify/kafka
    
Then connect to the box in another window like such

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                                            NAMES
    ba67dc1d0ae7        spotify/kafka       "supervisord -n"    27 seconds ago      Up 26 seconds       0.0.0.0:2181->2181/tcp, 0.0.0.0:9092->9092/tcp   sad_darwin
    $ docker exec -i -t sad_darwin bash
    root@ba67dc1d0ae7:/#

On the main host, download and install kafka:

    wget http://mirrors.supportex.net/apache/kafka/0.8.2.1/kafka_2.11-0.8.2.1.tgz
    tar xfz kafka_2.11-0.8.2.1.tgz
    cd kafka_2.11-0.8.2.1/bin
        
    ./kafka-topics.sh --create --zookeeper 10.44.129.105:2181 --replication-factor 1 --partitions 1 --topic PLT-AIRT
    ./kafka-topics.sh --describe --zookeeper 10.44.129.105:2181  --topic PLT-AIRT # check topic
    ./kafka-console-producer.sh --broker-list 10.44.129.105:9092 --topic PLT-AIRT # write to topic
    
Note that the topic create command gives a warning on Kafka 0.8.2.1, see http://users.kafka.apache.narkive.com/PFbfIGcY/quickstart-ok-locally-but-getting-warn-property-topic-is-not-valid-and-leadernotavailableexception

Next approach - install docker-machine (as part of Docker toolbox) on Windows. Then:

    $ docker run -d -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST=`docker-machine ip \`docker-machine active\`` --env ADVERTISED_PORT=9092 spotify/kafka
    
and it brings up kafka inside the docker VM.

Run Hadoop container:

    $ docker run -it -d sequenceiq/hadoop-docker:2.7.0 /etc/bootstrap.sh -bash

