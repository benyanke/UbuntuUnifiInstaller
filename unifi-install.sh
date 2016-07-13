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
tempfile6=/tmp/dialog_6_$$

# touch $tempfile1 $tempfile2 $tempfile3 $tempfile4 $tempfile5 $tempfile6;

trap "rm -f $tempfile1 $tempfile2 $tempfile3 $tempfile4 $tempfile5 $tempfile6" 0 1 2 5 15


backTitleText="Unifi Initial Configuration"

dialog  --backtitle "$backTitleText" \
--title "Domain or IP?" \
--menu "\nWill this Unifi Control Panel be accessable by domain name or by IP address?\n\n" 0 0 0 \
1 "IP Address" \
2 "Domain Name"  2> $tempfile1

# domain option
if [ $(cat $tempfile1) -eq 2 ]; then

  dialog  --backtitle "$backTitleText" \
  --title "Let's Encrypt" \
  --menu "\nWhat Certificate do you want to use?\n\n" 0 0 0 \
  1 "Let's Encrypt Certificate" \
  2 "Self-Signed Certificate"   2> $tempfile2

  dialog  --backtitle "$backTitleText" \
  --title "Domain" \
  --inputbox "\nWhat domain name do you wish to use (ex: example.com)?\n\n" 0 0  2> $tempfile3
  
  # Domain validity check
  domain=$(cat $tempfile3 | grep -P "^[a-zA-Z0-9]+([-.]?[a-zA-Z0-9]+)*\.[a-zA-Z]+$")
  if [ $? -ne 0 ]; then
      dialog  --backtitle "$backTitleText" \
      --title "Domain Not Valid" \
      --infobox "\n*$(cat $tempfile3)* does not appear to be a valid domain name. Exiting.\n\n" 0 0 
      exit 1;
  fi ## end domain validity check
  
  # LE Check
  useLe=0;
  if [ $(cat $tempfile2) -eq 1 ]; then
    useLe=1;
    
    dialog  --backtitle "$backTitleText" \
    --title "Let's Encrypt" \
    --msgbox "\nNote: You must already have the DNS configured to point *$domain* to this server in order to continue.\n\n" 0 0;
    
    dialog  --backtitle "$backTitleText" \
    --title "Email for Let's Encrypt" \
    --inputbox "\nWhat email should be used for Let's Encrypt?\n\n" 0 0  2> $tempfile6
    
    # email validity check
    leEmail=$(cat $tempfile6 | grep -E "^\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b$");
    if [ $? -ne 0 ]; then
    
        dialog  --backtitle "$backTitleText" \
        --title "Email Not Valid" \
        --infobox "\n$(cat $tempfile6) does not appear to be a valid email address. Exiting.\n\n" 0 0 
        exit 1;
    fi ## end email validity check
    leEmail=$(cat $tempfile6);
    
    messageForProgress="Installing Unifi and Let's Encrypt on $domain"
    installQuestion="Do you want to continue installing the Unifi control panel on *$domain* with a Let's Encrypt certificate?"
  else
    messageForProgress="Installing Unifi"
    installQuestion="Do you want to continue installing the Unifi control panel on *$domain* with a self-signed certificate?"
  fi ## end LE check
else
  messageForProgress="Installing Unifi"
  installQuestion="Do you want to continue installing the Unifi control panel?"
fi ## end domain check

dialog  --backtitle "$backTitleText" \
--title "Port" \
--inputbox "\nWhat TCP port do you wish to use? \n\n" 0 0  2> $tempfile5

  port=$(cat $tempfile5)
  
  # is port valid
  if [ "$port" -lt 1 ] || [ "$port" -gt 65535]; then
    dialog  --backtitle "$backTitleText" \
    --title "Port Not Valid" \
    --infobox "\n$port does not appear to be a valid TCP port. Exiting.\n\n" 0 0;
    exit 1;
  fi ## end domain validity check

dialog  --backtitle "$backTitleText" \
--title "Confirmation" \
--yesno "\n$installQuestion\n" 0 0   2> $tempfile4

dialog  --backtitle "$backTitleText" \
--title "$messageForProgress" \
--infobox "\nInstalling, please wait. \n\nThis could take a while....\n\n" 0 0

# from: https://thatservernerd.com/2016/04/01/install-unifi-on-ubuntu-server-14-04/

# Add unifi software to apt lists
echo "deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti" > /etc/apt/sources.list.d/20unifi.list;
apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50;

# Get Packages
  apt-get update > /dev/null 2>&1
  
# if port is not 8443 OR we're using Let's Encrypt, 
# setup nginx proxy to handle certs and redirection
if [ \( "$port" -ne 8443] \) -o \( [ "$useLe" -eq 1 \) ]; then
  apt-get install unifi ufw git nginx -y
  useNginx=1
else
  apt-get install unifi ufw git -y
  useNginx=0
fi

# Wait for install to complete
wait;


# Generate stronger DH groups
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048  > /dev/null 2>&1 &

# Setup nginx to proxy to unifi
# Let's encrypt certificate

(
  if [[ "$useLe" -eq 1 ]]; then
  service nginx stop
  if [ -d "/opt/letsencrypt" ]; then
    git -C /opt/letsencrypt pull
  else
    git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
  fi
  
  /opt/letsencrypt/letsencrypt-auto certonly \
    --standalone \
    --standalone-supported-challenges tls-sni-01 \
    --email $leEmail \
    -d $domain
    
  service nginx start;
  clear;
fi
) &

(
if [[ "$useNginx" -eq 1 ]]; then
  configpath="/etc/nginx/sites-available/";
  mv $configPath/default $configPath/old-default
  configFile="$configPath/default"
  touch $configFile;

  echo "server {" > $configFile
  echo "  listen 80;" >> $configFile
  echo "  return 301 https://\$domain\$request_uri;" >> $configFile
  echo "}" >> $configFile
  echo " " >> $configFile
  echo " " >> $configFile
  echo "server {" >> $configFile
  echo "  listen 443;" >> $configFile
  echo "  server_name $domain;" >> $configFile
  echo "  ssl_certificate           /etc/letsencrypt/live/$domain/fullchain.pem;" >> $configFile
  echo "  ssl_certificate_key       /etc/letsencrypt/live/$domain/privkey.pem;" >> $configFile
  echo " " >> $configFile
  echo "  ssl on;" >> $configFile
  echo "  ssl_prefer_server_ciphers on;" >> $configFile
  echo "  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;" >> $configFile
  echo "  ssl_dhparam /etc/ssl/certs/dhparam.pem;" >> $configFile
  echo "  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';" >> $configFile
  echo "  ssl_session_timeout 1d;" >> $configFile
  echo "  ssl_session_cache shared:SSL:50m;" >> $configFile
  echo "  ssl_stapling on;" >> $configFile
  echo "  ssl_stapling_verify on;" >> $configFile
  echo "  add_header Strict-Transport-Security max-age=15768000;" >> $configFile
  echo "  " >> $configFile  
  echo "  " >> $configFile
  echo "  access_log            /var/log/nginx/unifi.access.log;" >> $configFile
  echo "  " >> $configFile
  echo "  location / {" >> $configFile
  echo "    proxy_set_header        Host \$host;" >> $configFile
  echo "    proxy_set_header        X-Real-IP \$remote_addr;" >> $configFile
  echo "    proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;" >> $configFile
  echo "    proxy_set_header        X-Forwarded-Proto \$scheme;" >> $configFile
  echo "  " >> $configFile
  echo "    # Fix the \"It appears that your reverse proxy set up is broken\" error." >> $configFile
  echo "    proxy_pass          https://$domain:8443;" >> $configFile
  echo "    proxy_read_timeout  90;" >> $configFile
  echo " " >> $configFile
  echo "    proxy_redirect      https://$domain:8443/ https://$domain;" >> $configFile
  echo "  }" >> $configFile
  echo "}" >> $configFile
  clear;
 fi # end nginx check
) &

# Enable firewall
(ufw disable
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 8080
ufw allow 8443
ufw allow 8880
ufw allow 8843
ufw allow 27117
ufw allow $port
ufw --force enable) &

# Wait for all background tasks to run
echo "Waiting for install to complete"
wait;
service nginx restart

dialog  --backtitle "$backTitleText" \
  --title "Complete!" \
  --infobox "\nSetup complete! \n\n Visit https://$domain:$port to view Unifi control panel.\n\n" 0 0;
  
exit

