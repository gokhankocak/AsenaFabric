#!/bin/bash

# MIT License
# Copyright (c) 2018 Gökhan Koçak
# www.gokhankocak.com

# install necessary tools
sudo apt-get update
sudo apt-get -y install git
sudo apt-get -y install curl
sudo apt-get -y install wget
sudo apt-get -y install autoconf
sudo apt-get -y install automake
sudo apt-get -y install libtool
sudo apt-get -y install pkg-config
sudo apt-get -y install libevent-dev
sudo apt-get -y upgrade
echo "You may need to reboot your system."
echo "Please check apt-get logs"
sleep 5

# install Go
echo "Installing Go"
wget https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.11.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo "Please add /usr/local/go/bin to your PATH in your shell profile"

# install Node 8.x because higher versions are not supported by Hyperledger
echo "Installing Node 8.x"
wget -qO- https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential

# install Docker CE
echo "Installing Docker CE"
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

# test if docker is installed properly
docker run hello-world

echo "Please log out and then login again."
echo "Run ./AsenaDockerSetup.sh after login"
