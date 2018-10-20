#!/bin/bash

export FABRIC_CFG_PATH=/etc/hyperledger/fabric
export CHANNEL=asena
export ORDERER=orderer.asena.fabric:7050
export ORDERER_CA=/etc/hyperledger/fabric/crypto/ordererOrganizations/asena.fabric/orderers/orderer.asena.fabric/msp/tlscacerts/tlsca.asena.fabric-cert.pem
export PEER0_ORG1_CA=/etc/hyperledger/fabric/crypto/peerOrganizations/asena.fabric/peers/peer0.asena.fabric/tls/ca.crt
export CORE_PEER_ID=peer0.asena.fabric
export CORE_PEER_ADDRESS=peer0.asena.fabric:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto/peerOrganizations/asena.fabric/users/Admin@asena.fabric/msp

export CHAINCODE=asenacc
export VERSION=1.0
export LANGUAGE=golang
export GOPATH=/etc/hyperledger/fabric
export CC_SRC_PATH=chaincode/AsenaSmartContract/go
export PEER_CONN_PARAMS="--peerAddresses peer0.asena.fabric:7051 --tlsRootCertFiles $PEER0_ORG1_CA"

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
if [ $? -ne 0 ]; then
    # sometimes it timeouts, so issue the instantiate command again
    peer chaincode instantiate -o $ORDERER --tls --cafile $ORDERER_CA -C $CHANNEL -n $CHAINCODE -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["Init"]}'
fi
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
