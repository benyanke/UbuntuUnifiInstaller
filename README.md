# _Ubiquity Unifi Controller_ Install Script for Linux
## With Let's Encrypt
Bash installer script for the Unifi Controller for Ubiquity's unifi access points, including integration with Let's Encrypt (via nginx)
 
Currently, only the Let's Encrypt + Nginx implementation works, but I plan to also get direct standalone installing working soon. Also need to get automatic certificate renewal added to crontab with this tool.

### How To Use

Simply run this one line in your terminal:
```bash
wget https://git.io/vKRg8 -O unifi-install.sh && chmod +x unifi-install.sh && sudo ./unifi-install.sh
```

### Currently tested on 
* Ubuntu Server 16.04 LTS (64 & 32 bit)
* Ubuntu Server 14.04.1 LTS  (64 & 32 bit)
 

_Should also work on Raspian (Raspberry Pi), I plan to do an actual test very soon._
