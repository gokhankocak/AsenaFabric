#!/bin/bash

# MIT License
# Copyright (c) 2018 Gökhan Koçak
# www.gokhankocak.com

# locate the binary files for the current architecture
export ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')")
export BINARY_FILE=hyperledger-fabric-${ARCH}-1.4.0.tar.gz
export BINARY_URL=https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-1.4.0/${BINARY_FILE}

mkdir tmp

# download the Hyperledger Fabric binary files
echo "Downloading Hyperledger fabric binaries"
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
echo "Generating Public Keys, Private Keys and Certificates"
sleep 5
cryptogen generate --config=./crypto.yaml
mv crypto-config crypto

# generate artifacts
echo "Generating Asena Channel artifacts"
sleep 5
mkdir artifacts
configtxgen -profile AsenaGenesis -outputBlock ./artifacts/genesis.block
configtxgen -profile AsenaChannel -outputCreateChannelTx ./artifacts/channel.tx -channelID $CHANNEL
configtxgen -profile AsenaChannel -outputAnchorPeersUpdate ./artifacts/Org1MSPanchors.tx -channelID $CHANNEL -asOrg Org1MSP

# display blockchain objects
configtxgen -inspectBlock ./artifacts/genesis.block
configtxgen -inspectChannelCreateTx ./artifacts/channel.tx

CA_KEYFILE=`find ./crypto/peerOrganizations/asena.fabric/ca -name '*_sk' | cut -c 44-`
cat template-docker-asena-fabric.yaml | sed "s/SED_FABRIC_CA_SERVER_TLS_KEYFILE/$CA_KEYFILE/g" >docker-asena-fabric.yaml

ORG1_ADMIN_KEYFILE=`find ./crypto/peerOrganizations/asena.fabric/users/Admin@asena.fabric/msp/keystore -name '*_sk' | cut -c 79-`
cat backend/template-network-config.yaml | sed "s/SED_ORG1_ADMIN_KEYFILE/$ORG1_ADMIN_KEYFILE/g" >backend/network-config.yaml

echo "Now you can run ./AsenaFabricStart.sh"
echo "After then, open another terminal window and run ./AsenaFabricInit.sh"