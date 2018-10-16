#!/bin/bash

# MIT License
# Copyright (c) 2018 Gökhan Koçak
# www.gokhankocak.com

# install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# test if docker is installed properly
docker run hello-world

# pull Docker images
docker pull hyperledger/fabric-baseos:amd64-0.4.10
docker pull hyperledger/fabric-baseimage:amd64-0.4.10
docker pull hyperledger/fabric-peer:1.2.0
docker pull hyperledger/fabric-orderer:1.2.0
docker pull hyperledger/fabric-ccenv:1.2.0
docker pull hyperledger/fabric-tools:1.2.0
docker pull hyperledger/fabric-couchdb:0.4.10

# pull SDKs and other libraries for development
git clone https://github.com/hyperledger/fabric-sdk-node.git
git clone https://github.com/hyperledger/fabric-sdk-java.git
git clone https://github.com/hyperledger/fabric-samples.git 
