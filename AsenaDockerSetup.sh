#!/bin/bash

# MIT License
# Copyright (c) 2018 Gökhan Koçak
# www.gokhankocak.com

# install docker-compose
echo "Installing docker-compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# pull Docker images
echo "Pulling Docker images for Hyperledger Fabric"
docker pull hyperledger/fabric-baseos:latest
docker pull hyperledger/fabric-baseimage:latest
docker pull hyperledger/fabric-peer:latest
docker pull hyperledger/fabric-orderer:latest
docker pull hyperledger/fabric-ccenv:latest
docker pull hyperledger/fabric-tools:latest
docker pull hyperledger/fabric-couchdb:0.4.10

echo "Now you can run ./AsenaFabricSetup.sh to continue"