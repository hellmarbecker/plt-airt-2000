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
    
this is going to need docker-machine: 
- see https://docs.docker.com/machine/install-machine/
- and then upgrade docker machine according to http://hjgraca.github.io/2015/11/09/Docker-Error-client-newer-than-server/
