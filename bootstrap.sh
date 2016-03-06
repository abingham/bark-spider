#!/usr/bin/env bash

# Bootstrap the vagrant image

sudo apt-get update
sudo apt-get install -y python3
sudo apt-get install -y python3-pip
sudo apt-get install -y python3-dev
sudo apt-get install -y python3-numpy
sudo apt-get install -y python3-pandas
sudo apt-get install -y zsh
# sudo apt-get install node
sudo apt-get install -y nodejs-legacy
sudo apt-get install -y npm
sudo apt-get install -y git
sudo npm install -g bower
sudo npm install -g elm
sudo npm install -g wisp

### Build the chartjs Elm extension
cd /vagrant/bark_spider/elm/chartjs/
sh ./update-from-bower.sh
sh ./make.sh

# TODO: I couldn't get virtualenvwrapper working properly, but that's what we
# really should be doing below.

### Setup the python server stuff
cd /vagrant
# TODO: At some point it would be nice to be able to do this:
#
#   sudo pip3 install -r requirements.txt
#
# But it requires setting up credentials, etc...it's probably possible.

sudo python3 setup.py install

### Build the Elm UI code
cd bark_spider/elm
elm-make --yes Main.elm

### Install brooks
cd
git clone https://github.com/sixty-north/brooks
cd brooks
sudo python3 setup.py install

echo "*** Don't forget to install any interventions you might want! ***"
