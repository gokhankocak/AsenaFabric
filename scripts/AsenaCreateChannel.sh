#!/bin/bash

export FABRIC_CFG_PATH=/etc/hyperledger/fabric
export CHANNEL=asena
export ORDERER=orderer.asena.fab:7050
export ORDERER_CA=/etc/hyperledger/fabric/crypto/ordererOrganizations/asena.fab/orderers/orderer.asena.fab/msp/tlscacerts/tlsca.asena.fab-cert.pem
export PEER0_ORG1_CA=/etc/hyperledger/fabric/crypto/peerOrganizations/asena.fab/peers/peer.asena.fab/tls/ca.crt
export CORE_PEER_ID=peer.asena.fab
export CORE_PEER_ADDRESS=peer.asena.fab:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto/peerOrganizations/asena.fab/users/Admin@asena.fab/msp

cd $FABRIC_CFG_PATH

# create channel
peer channel create -o $ORDERER -c $CHANNEL -f artifacts/channel.tx --tls --cafile $ORDERER_CA
sleep 10
cp $CHANNEL.block artifacts

# save block 0
peer channel fetch config config_block.pb -o $ORDERER -c $CHANNEL --tls --cafile $ORDERER_CA
cp config_block.pb artifacts

# display channel config
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config

# update anchor peers
peer channel update -o $ORDERER -c $CHANNEL -f artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $ORDERER_CA
sleep 10

# join channel
peer channel join -b artifacts/$CHANNEL.block
sleep 10

peer channel list