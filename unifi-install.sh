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

file='/home/user9/work/conf.txt'
tempfile1=/tmp/dialog_1_$$
tempfile2=/tmp/dialog_2_$$
tempfile3=/tmp/dialog_3_$$
tempfile4=/tmp/dialog_4_$$
tempfile5=/tmp/dialog_5_$$

trap "rm -f $tempfile1 $tempfile2 $tempfile3 $tempfile4 $tempfile5" 0 1 2 5 15


backTitleText="Unifi Initial Configuration"

dialog  --backtitle "$backTitleText" \
--title "Domain or IP?" \
--menu "\nWill this Unifi Control Panel be accessable by domain name or by IP address?\n" 0 0 0 \
1 "IP Address" \
2 "Domain Name"  2> $tempfile1

# domain option
if [ $(cat $tempfile1) -eq 2 ]; then

  dialog  --backtitle "$backTitleText" \
  --title "Let's Encrypt" \
  --menu "\nDo you want to set up Let's Encrypt for this control panel?\n" 0 0 0 \
  1 "Yes" \
  2 "No"   2> $tempfile2
  
  # LE Check
  if [ $(cat $tempfile2) -eq 1 ]; then
    
    dialog  --backtitle "$backTitleText" \
    --title "Let's Encrypt" \
    --msgbox "\nNote: You must already have the DNS configured or Let's Encrypt setup to continue with certificate issuance.\n" 0 0;
    
    
    dialog  --backtitle "$backTitleText" \
    --title "Domain" \
    --inputbox "\nWhat domain name do you wish to use (ex: example.com)?\n" 0 0  2> $tempfile3
    
    # Domain validity check
    
    domain=$(cat $tempfile3 | grep -P "^[a-zA-Z0-9]+([-.]?[a-zA-Z0-9]+)*\.[a-zA-Z]+$")
    if [ $? -ne 0 ]; then
        dialog  --backtitle "$backTitleText" \
        --title "Domain Not Valid" \
        --infobox "\n *$(cat $tempfile3)* does not appear to be a valid domain name. Exiting.\n" 0 0 
        exit 1;
    fi ## end domain validity check
    messageForProgress="Installing Unifi and Let's Encrypt"
  else
    messageForProgress="Installing Unifi"
  fi ## end LE check
fi ## end domain check

dialog  --backtitle "$backTitleText" \
--title "Confirmation?" \
--yesno "\nDo you want to continue installing the Unifi control panel?\n" 0 0   2> $tempfile4

dialog  --backtitle "$backTitleText" \
--title "$messageForProgress" \
--infobox "\nInstalling, please wait. \n\nThis could take a while....\n\n" 0 0 &
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
