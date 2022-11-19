#!/bin/bash

##
## ufw - wireguard + dnsproxy
##

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

ufw --force reset
ufw --force enable
ufw logging low
ufw allow proto tcp from 0.0.0.0/0 to any port ssh
ufw allow proto tcp from 0.0.0.0/0 to any port https
ufw status verbose

## setup files for homeip cron script
rm -f /var/tmp/home_cidr_previous_file.txt
rm -f /var/tmp/home__ip__previous_file.txt
