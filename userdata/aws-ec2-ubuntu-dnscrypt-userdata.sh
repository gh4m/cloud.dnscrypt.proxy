#!/bin/bash
set -eux

##
## AWS EC2 user data script to setup dnscrypt server (ubuntu 22.04)
##

####----------------------------------------------------------------
####----------------------------------------------------------------
####----------------------------------------------------------------

DNSCRYPT_HOSTNAME=

## FQDN to use for finding home isp ip address
HOME_ISP_FQDN=

## YES or NO
SET_DNSCRYPT_PROXY_BLOCKING=YES

## AWS ACCT SPECIFIC INFO (these vars only used in code below)
AWS_ACCT_FIRE_ID=
AWS_ACCT_FIRE_DOMAIN_NAME=
AWS_ACCT_FIRE_ZONEID_PRIVATE=
AWS_ACCT_FIRE_ZONEID_PUBLIC=
AWS_SNS_ARN="arn:aws:sns:us-east-1:${AWS_ACCT_FIRE_ID}:SendEmail"

####----------------------------------------------------------------
####----------------------------------------------------------------
####----------------------------------------------------------------

## userdata directory (other userdata scripts hardcode USERDATA_* var & path, keep in sync)
USERDATA_PATH=/root/userdata
USERDATA_BASH=${USERDATA_PATH}/bash
USERDATA_CONFIG=${USERDATA_PATH}/config
mkdir ${USERDATA_PATH}
git clone https://github.com/gh4m/cloud.userdata.scripts.git ${USERDATA_PATH}

## Downloaded files
SCRIPT_SETUP_OS_NAME=setup-ubuntu-server-aws.sh
SCRIPT_SETUP_OS_PATH=${USERDATA_BASH}/${SCRIPT_SETUP_OS_NAME}
SCRIPT_SETUP_AWSCLI_NAME=setup-aws-cli.sh
SCRIPT_SETUP_AWSCLI_PATH=${USERDATA_BASH}/${SCRIPT_SETUP_AWSCLI_NAME}
SCRIPT_GET_OS_FINGERPRINT_NAME=get-server-ssh-fingerprint-aws.sh
SCRIPT_GET_OS_FINGERPRINT_PATH=${USERDATA_BASH}/${SCRIPT_GET_OS_FINGERPRINT_NAME}
SCRIPT_SETUP_DNSCRYPT_PROXY_NAME=install-dnscrypt-proxy.sh
SCRIPT_SETUP_DNSCRYPT_PROXY_PATH=${USERDATA_BASH}/${SCRIPT_SETUP_DNSCRYPT_PROXY_NAME}
SCRIPT_SETUP_FIREWALL_NAME=setup-ubuntu-server-firewall-dnscrypt-proxy.sh
SCRIPT_SETUP_FIREWALL_PATH=${USERDATA_BASH}/${SCRIPT_SETUP_FIREWALL_NAME}
SCRIPT_CRON_FIREWALL_HOMEFIOS_CHANGE_NAME=reconfigue-ufw-homeip-change.sh
SCRIPT_CRON_FIREWALL_HOMEFIOS_CHANGE_PATH=${USERDATA_BASH}/${SCRIPT_CRON_FIREWALL_HOMEFIOS_CHANGE_NAME}

## server basic setup
. ${SCRIPT_SETUP_OS_PATH}

## instal aws cli
. ${SCRIPT_SETUP_AWSCLI_PATH}

## AWS ssh server fingerprint
. ${SCRIPT_GET_OS_FINGERPRINT_PATH}

## dnscrypt-proxy setup
## -- DNS will not work till reboot after running this script -- ##
. ${SCRIPT_SETUP_DNSCRYPT_PROXY_PATH}

## ufw (basic launch firewall setup)
## -- this FW script cannot rely on a working DNS -- ##
. ${SCRIPT_SETUP_FIREWALL_PATH}

## setup crons
## -- add to crontab just before reboot as not run during initial launch -- ##
set +e
(crontab -l 2>/dev/null; echo "3-59/4 * * * * ${SCRIPT_CRON_FIREWALL_HOMEFIOS_CHANGE_PATH} ${HOME_ISP_FQDN}") | crontab -
set -e

shutdown -r now
