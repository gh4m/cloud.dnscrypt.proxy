#!/bin/bash

##
## ubuntu AWS server basic setup
##

snap list | grep ^amazon-ssm-agent && snap remove amazon-ssm-agent

APT_DPKG_VAR="DEBIAN_FRONTEND=noninteractive"
APT_DPKG_OPT="-o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\""
APT_GET_CMD="eval $APT_DPKG_VAR apt-get -y $APT_DPKG_OPT"

$APT_GET_CMD update
$APT_GET_CMD dist-upgrade
$APT_GET_CMD autoremove

AWS_ACCT_FIRE_FQDN=${DNSCRYPT_HOSTNAME}.${AWS_ACCT_FIRE_DOMAIN_NAME}
AWS_ACCT_FIRE_PUBL_IP_ADDR=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
AWS_ACCT_FIRE_PRIV_IP_ADDR=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
AWS_ACCT_FIRE_ETH0_DNS_IP_ADDR=169.254.169.123

## sshd on ipv4 only
sed -i "/ListenAddress 0.0.0.0/c\ListenAddress 0.0.0.0" /etc/ssh/sshd_config

## hostname setup
hostnamectl set-hostname ${AWS_ACCT_FIRE_FQDN}
echo "${AWS_ACCT_FIRE_PRIV_IP_ADDR} ${AWS_ACCT_FIRE_FQDN}" >> /etc/hosts
## home host setup
AWS_ACCT_FIRE_HOME_LAN_PUBL_IP_ADDR=$(dig +short ${HOME_ISP_FQDN} | tail -n1 | grep -E -o "^([0-9]{1,3}[\.]){3}[0-9]{1,3}$")
echo "${AWS_ACCT_FIRE_HOME_LAN_PUBL_IP_ADDR} ${HOME_ISP_FQDN}" >> /etc/hosts

timedatectl set-timezone America/New_York

sed -i "/pool ntp.ubuntu.com/c\server ${AWS_ACCT_FIRE_ETH0_DNS_IP_ADDR} prefer iburst minpoll 4 maxpoll 4" /etc/chrony/chrony.conf
sed -i "/pool /c\#" /etc/chrony/chrony.conf
systemctl restart chrony
