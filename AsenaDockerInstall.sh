#!/bin/bash

# MIT License
# Copyright (c) 2018 Gökhan Koçak
# www.gokhankocak.com

# install necessary tools
sudo apt-get update
sudo apt-get -y install git
sudo apt-get -y install curl
sudo apt-get -y upgrade

# install Docker CE
sudo apt-get -y remove docker docker-engine docker.io
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get -y install docker-ce

sudo groupadd docker
sudo usermod -aG docker $USER

sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R

echo "Please log out and then login again."
echo "Because $USER is added to the docker group"
