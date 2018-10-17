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

export CHAINCODE=asenacc
export VERSION=1.0
export LANGUAGE=golang
export GOPATH=/etc/hyperledger/fabric
export CC_SRC_PATH=chaincode/AsenaSmartContract/go
export PEER_CONN_PARAMS="--peerAddresses peer.asena.fab:7051 --tlsRootCertFiles $PEER0_ORG1_CA"

cd $FABRIC_CFG_PATH

echo "Downloading statsd go client"
go get github.com/cactus/go-statsd-client/statsd

# install chaincode
echo "Installing Asena Smart Contract"
peer chaincode install -n $CHAINCODE -v ${VERSION} -l ${LANGUAGE} -p ${CC_SRC_PATH}
sleep 10
peer chaincode list --installed

# instantiate chaincode
echo "Instantiating Asena Smart Contract"
peer chaincode instantiate -o $ORDERER --tls --cafile $ORDERER_CA -C $CHANNEL -n $CHAINCODE -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["Init"]}'
sleep 10
# sometimes it timeouts, so issue the instantiate command again
peer chaincode instantiate -o $ORDERER --tls --cafile $ORDERER_CA -C $CHANNEL -n $CHAINCODE -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["Init"]}'
sleep 10
peer chaincode list -C $CHANNEL --instantiated

# invoke chaincode
echo "Invoking Asena Smart Contract"
peer chaincode invoke -o $ORDERER --tls --cafile $ORDERER_CA -C $CHANNEL -n $CHAINCODE $PEER_CONN_PARAMS -c '{"Args":["InitLedger"]}'
sleep 10

# query chaincode
echo "Querying Asena Smart Contract"
peer chaincode query -C $CHANNEL -n $CHAINCODE -c '{"Args":["GetState","AsenaSmartContract.Status"]}'
peer chaincode query -C $CHANNEL -n $CHAINCODE -c '{"Args":["GetState","AsenaSmartContract.Version"]}'
