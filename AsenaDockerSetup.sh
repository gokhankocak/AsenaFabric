#!/bin/bash

# MIT License
# Copyright (c) 2018 Gökhan Koçak
# www.gokhankocak.com

# install docker-compose
echo "Installing docker-compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# pull Docker images
echo "Pulling Docker images for Hyperledger Fabric"
docker pull hyperledger/fabric-baseos:amd64-0.4.10
docker pull hyperledger/fabric-baseimage:amd64-0.4.10
docker pull hyperledger/fabric-peer:1.2.0
docker pull hyperledger/fabric-orderer:1.2.0
docker pull hyperledger/fabric-ccenv:1.2.0
docker pull hyperledger/fabric-tools:1.2.0
docker pull hyperledger/fabric-couchdb:0.4.10

echo "Now you can run ./AsenaFabricSetup.sh to continue"