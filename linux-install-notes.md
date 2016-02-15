# 2016-02-15

* installed Vagrant:

  yum install vagrant

* installed Docker:

  yum install docker

* Set up proxy to access external repos

  export http_proxy="http://*******:********@proxynlwp.europe.intranet:8080/"
  export https_proxy=$http_proxy

* Install docker-compose as a container, according to https://docs.docker.com/compose/install/

  curl -L https://github.com/docker/compose/releases/download/1.6.0/run.sh > /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose

* Download kafka docker package from http://wurstmeister.github.io/kafka-docker/, and untar it in root's home directory

* Need to configure the proxy in Docker according to  http://stackoverflow.com/questions/23111631/cannot-download-docker-images-behind-a-proxy

  mkdir /etc/systemd/system/docker.service.d
  vi /etc/systemd/system/docker.service.d/http-proxy.conf
  
and enter:

  [Service]
  Environment="HTTP_PROXY=http://*******:********@proxynlwp.europe.intranet:8080/"
  Environment="HTTPS_PROXY=http://*******:********@proxynlwp.europe.intranet:8080/"


