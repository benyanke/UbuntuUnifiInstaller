#!/bin/bash

# Root check
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Ask w/ Ncurses or similar:

# -Running on Domain or IP?
#  -- If domain:  install ssl with let's encrypt?
# -Install beta or production release of unifi controller?
# -Switch to port 80/443 with nginx redirect? or leave at 8080

echo "deb http://www.ubnt.com/downloads/unifi/distros/deb/squeeze squeeze ubiquiti" >> /etc/apt/sources.list.d/20ubiquiti.list
apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" >> /etc/apt/sources.list.d/21mongodb.list
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

apt-get update
apt-get install unifi -y

# Beta Option:
# apt-get install unifi-beta -y


3.- u will get a java error. * Starting Ubiquiti UniFi Controller unifi Cannot locate Java Home [fail] .. to fix it run the following commands
# nano /etc/init.d/unifi
search for JAVA_HOME and change the path to /usr/lib/jvm/java-7-openjdk-amd64
now  


sudo /etc/init.d/unifi start

apt-get remove unifi
apt-get remove unifi-beta

wget http://www.ubnt.com/downloads/unifi/4.2.0/unifi_sysvinit_all.deb
dpkg -i unifi_sysvinit_all.de
