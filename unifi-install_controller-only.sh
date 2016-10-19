#!/bin/bash

##### Unifi Control Panel install script #####
# Installs the unifi control panel, Let's encrypt, and nginx proxy to handle LE.
# 
# Tested on clean installs of:
#   - Ubuntu 16.04 LTS
#   - Should also work on most debian-based systems
#
# Last modified on 7/13/2016
# https://github.com/benyanke/Linux-Unifi-Installer/

# Root check
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#http://www.unixcl.com/2009/12/linux-dialog-utility-short-tutorial.html



# from: https://thatservernerd.com/2016/04/01/install-unifi-on-ubuntu-server-14-04/


# Add unifi software to apt lists
echo "deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti" > /etc/apt/sources.list.d/20unifi.list;
apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50;

# Get Packages
apt-get update > /dev/null 2>&1
apt-get install unifi -y > /dev/null 2>&1


# Wait for all background tasks to run
echo " ";
echo " ";
echo "Waiting for install to complete"
wait;

exit

