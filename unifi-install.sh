#!/bin/bash

# Root check
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

installCheck=$(dpkg-query -W -f='${Status}\n' dialog | head -n1 | awk '{print $3;}')


if [ $installCheck != 'installed' ]; then
  echo "Installing needed tools.";
  apt-get update >/dev/null 2>&1
  apt-get install dialog -y >/dev/null 2>&1
fi

#http://www.unixcl.com/2009/12/linux-dialog-utility-short-tutorial.html

backTitleText="Unifi Initial Configuration"

dialog  --backtitle "$backTitleText" \
--title "Domain or IP?" \
--menu "\nWill this Unifi Control Panel be primarily accessable by domain name or by IP address?" 12 55 5 \
1 "IP Address" \
2 "Domain Name";

dialog  --backtitle "$backTitleText" \
--title "Let's Encrypt" \
--menu "\nDo you want to set up Let's Encrypt for this control panel?" 12 55 5 \
1 "Yes" \
2 "No";

dialog  --backtitle "$backTitleText" \
--title "Let's Encrypt" \
--msgbox "\nNote: You must already have the DNS configured or Let's Encrypt setup to continue with certificate issuance." 9 50;


dialog  --backtitle "$backTitleText" \
--title "Domain" \
--inputbox "\nWhat domain name do you wish to use (ex: example.com)?" 8 50;

# dev testing
domain="test.com";

dialog  --backtitle "$backTitleText" \
--title "Confirmation?" \
--yesno "\nDo you want to continue installing the Unifi control panel on $domain?" 10 30

dialog  --backtitle "$backTitleText" \
--title "Confirmation?" \
--infobox "\nInstalling, please wait. \n\nThis could take a while...." 7 40 &
sleep 5 &
wait;
echo "hi";



exit;


# https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-3-2-1-is-released/ba-p/872360

# Ask w/ Ncurses or similar:

# -Running on Domain or IP?
#  -- If domain:  install ssl with let's encrypt?
# -Install beta or production release of unifi controller?
# -Switch to port 80/443 with nginx redirect? or leave at 8080

# or: 
echo "deb http://www.ubnt.com/downloads/unifi/distros/deb/ubuntu ubuntu ubiquiti" >> /etc/apt/sources.list.d/20ubiquiti.list

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
