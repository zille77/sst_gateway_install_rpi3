#!/bin/bash
# Automatic install of Thingspeak server on Ubuntu 12.04

sudo apt-get update
sudo apt-get -y install build-essential ruby1.9.3 git mysql-server mysql-client libmysqlclient-dev libxml2-dev libxslt-dev
sudo gem install rails
git clone https://github.com/iobridge/thingspeak.git
cp thingspeak/config/database.yml.example thingspeak/config/database.yml
cd thingspeak
echo "gem: --no-rdoc --no-ri" >> ${HOME}/.gemrc
bundle install
bundle exec rake db:create
bundle exec rake db:schema:load
rails server
