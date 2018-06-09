#!/bin/bash
# Automatic install 

## check root level
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

## Install required packages
sudo apt-get update

sudo apt-get -y install apache2 php7.0 libusb-1.0-0-dev

## Install sst cpp program
wget www.smart-sensor-technology.de/download/sst_gateway_program.zip
sudo unzip -o sst_gateway_program.zip -d /home/pi

cd /home/pi/cpp_program
sudo chmod +x makefile
sudo ./makefile
sudo chmod +x run.sh
sudo chmod +x stop.sh
