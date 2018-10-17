#!/bin/bash

# MIT License
# Copyright (c) 2018 Gökhan Koçak
# www.gokhankocak.com

# bring up the Asena Fabric containers
export COMPOSE_PROJECT_NAME=asena
export NETWORK_BASE_NAME=fabric

docker-compose -f docker-asena-fabric.yaml stop