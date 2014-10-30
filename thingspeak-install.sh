#!/bin/bash
# Automatic install of Thingspeak server on Ubuntu 12.04 / Raspbmc / Debian (?)
# Updated to use ruby 2.1.4

## Install required packages
sudo apt-get update
sudo apt-get -y install build-essential git mysql-server mysql-client libmysqlclient-dev libxml2-dev libxslt-dev libssl-dev libsqlite3-dev

## Install ruby
wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.4.tar.gz
tar xvzf ruby-2.1.4.tar.gz
cd ruby-2.1.4
./configure
make
sudo make install
cd ..
 
## Install rails
echo "gem: --no-rdoc --no-ri" >> ${HOME}/.gemrc
sudo gem install rails

## Install thingspeak
git clone https://github.com/iobridge/thingspeak.git
cp thingspeak/config/database.yml.example thingspeak/config/database.yml
cd thingspeak
bundle install
bundle exec rake db:create 
bundle exec rake db:schema:load
rails server
