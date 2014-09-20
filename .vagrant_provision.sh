#!/bin/bash

PE_VERSION="3.3.1"

INSTALL=false

###########################################################
ANSWERS=$1
PE_URL="https://s3.amazonaws.com/pe-builds/released/${PE_VERSION}/puppet-enterprise-${PE_VERSION}-el-6-x86_64.tar.gz"
FILENAME=${PE_URL##*/}
DIRNAME=${FILENAME%*.tar.gz}

## A reasonable PATH
echo "export PATH=$PATH:/usr/local/bin:/opt/puppet/bin" >> /etc/bashrc

## Add host entries for each system
cat > /etc/hosts <<EOH
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain
::1 localhost localhost.localdomain localhost6 localhost6.localdomain
###############################################################################
### Primary site
192.168.29.10 puppetca01.vagrant.vm puppetca01
192.168.29.11 puppetdb01.vagrant.vm puppetdb01
192.168.29.12 puppetconsole01.vagrant.vm puppetconsole01

###############################################################################
### Secondary (DR) site
192.168.29.13 puppetca02.vagrant.vm puppetca02
192.168.29.14 puppetdb02.vagrant.vm puppetdb02
192.168.29.15 puppetconsole02.vagrant.vm puppetconsole02

###############################################################################
### CNAMES for HA (behind LB)
192.168.29.10 puppetmaster.vagrant.vm puppetmaster

###############################################################################
### Floating CNAMES for HA/DR
### These should point to ACTIVE instances (or a LB that can determine that)
###############################################################################
## Active CA
192.168.29.10 puppetca.vagrant.vm puppetca
## Active PuppetDB
192.168.29.11 puppetdb.vagrant.vm puppetdb
## PuppetDB PostgreSQL instance
192.168.29.11 puppetdbpg.vagrant.vm puppetdbpg
## Active Console
192.168.29.12 puppetconsole.vagrant.vm puppetconsole
## Console PostgreSQL instance
192.168.29.12 puppetconsolepg.vagrant.vm puppetconsolepg

EOH

## Download and extract the PE installer
cd /vagrant/puppet/bootstrap/pe || (echo "/vagrant/puppet/bootstrap/pe doesn't exist." && exit 1)
if [ ! -f $FILENAME ]; then
  curl -O ${PE_URL} || (echo "Failed to download ${PE_URL}" && exit 1)
else
  echo "${FILENAME} already present"
fi

if [ ! -d ${DIRNAME} ]; then
  tar zxf ${FILENAME} || (echo "Failed to extract ${FILENAME}" && exit 1)
else
  echo "${DIRNAME} already present"
fi

service iptables stop

echo "========================================================================"
echo "Proceed with installation using the provided wrapper script."
echo
echo "/vagrant/puppet/bootstrap/bootstrap.sh"
echo "========================================================================"