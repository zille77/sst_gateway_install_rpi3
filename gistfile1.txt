#!/bin/bash
# Install Thingspeak server on Ubuntu 12.04

MYSQL_USR=root  #root used for simplicity, not security.
MYSQL_PWD=<root password>  #this is the passwd you'll enter during the installation of mysql-server

sudo apt-get update
sudo apt-get -y install build-essential ruby-1.9.3 git mysql-server mysql-client mysql-dev libxml2-dev libxslt-dev
sudo gem install rails
git clone https://github.com/iobridge/thingspeak.git
cp thingspeak/config/database.yml.example thingpseak/config/database.yml
sed -i 's/username:.*\+/username: $MYSQL_USR/' thingspeak/config/database.yml
sed -i 's/password:.*\+/password: $MSYQL_PWD/' thingpseak/config/database.yml
cd thingspeak
bundle install
bundle exec rake db:create
bundle exec rake db:schema:load
rails server

