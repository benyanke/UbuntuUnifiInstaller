# Unifi-Installer
Bash installer script for the Unifi Controller for Ubiquity's unifi access points. 

I'm currentlty going to be installing Unifi controller in multiple locations, and so I wrote up this bash script to install the Unifi Controller, including a Let's Encrypt Certificate (via an nginx proxy). 
 
Right now, it's only working for Let's Encrypt + Nginx, but I plan to also get it working for just a straight install without LE or nginx shortly. Also currently only working on clean isntalls of Ubuntu 16.04 LTS, but it should also work on Raspian on Raspberry Pi, which I plan to test very soon.
 
https://github.com/benyanke/Linux-Unifi-Installer
 
If there are any other features that would be helpful for people, do let me know, post here or on GH, or of course make a pull request, and I'll see what I can do!

# Currently tested on clean installs of
* Ubuntu Server 16.04 LTS
