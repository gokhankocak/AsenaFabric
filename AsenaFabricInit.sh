#!/bin/bash

# MIT License
# Copyright (c) 2018 Gökhan Koçak
# www.gokhankocak.com

# bring up the Asena Fabric containers
export COMPOSE_PROJECT_NAME=asena
export NETWORK_BASE_NAME=fabric

echo "Creating the Asena Fabric Channel"
docker exec -it cli.asena.fab bash scripts/AsenaChannelCreate.sh
sleep 15

echo "Installing the Asena Smart Contract"
docker exec -it cli.asena.fab bash scripts/AsenaSmartContractSetup.sh
