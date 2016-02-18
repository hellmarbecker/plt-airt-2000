# 2016-02-15

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
