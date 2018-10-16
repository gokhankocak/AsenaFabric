#!/bin/bash

# MIT License
# Copyright (c) 2018 Gökhan Koçak
# www.gokhankocak.com

# locate the binary files for the current architecture
export ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')")
export BINARY_FILE=hyperledger-fabric-${ARCH}-1.2.0.tar.gz
export BINARY_URL=https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-1.2.0/${BINARY_FILE}

mkdir tmp

# download the Hyperledger Fabric binary files
curl -f -s -C - ${BINARY_URL} -o ${BINARY_FILE}
mv ${BINARY_FILE} tmp
cd tmp
tar xzf ./${BINARY_FILE}
mv bin ../bin
cd ..

export PATH=$PATH:$PWD/bin

# now bring up the Asena Fabric
export CHANNEL=asena
export FABRIC_CFG_PATH=${PWD}

# remove old directories
rm -rf crypto-config
rm -rf crypto
rm -rf artifacts
rm -rf data/*
mkdir data

# generate crypto files
cryptogen generate --config=./crypto.yaml
mv crypto-config crypto

# generate artifacts
mkdir artifacts
configtxgen -profile AsenaGenesis -outputBlock ./artifacts/genesis.block
configtxgen -profile AsenaChannel -outputCreateChannelTx ./artifacts/channel.tx -channelID $CHANNEL
configtxgen -profile AsenaChannel -outputAnchorPeersUpdate ./artifacts/Org1MSPanchors.tx -channelID $CHANNEL -asOrg Org1MSP

# display blockchain objects
configtxgen -inspectBlock ./artifacts/genesis.block
configtxgen -inspectChannelCreateTx ./artifacts/channel.tx

# bring up the Asena Fabric containers
export COMPOSE_PROJECT_NAME=asena
export NETWORK_BASE_NAME=fabric

docker-compose -f docker-asena-fabric.yaml up
