#################
#### GENERAL ####
#################

# Environment Settings
################################
ENV=split
# Here is the only "all" or
# "splited" options could be

PACKAGE_LOCATION=$HOME/repos/packstack
# Here is the storage location
# where this repo was loaded

##################
### ALL IN ONE ###
##################

# Network Settings
################################
INT_GW=10.1.0.1
DNS_ADDR=8.8.8.8
NET_CIDR=255.255.255.0

# MASHINE SETTINGS
################################
BOX_NAME=centos/7
MASHINE_NAME=packstack
NAT_IP=10.0.2.15
INT_IP=10.1.0.10

# CLOUD SETTINGS
################################
CLOUD_NAME=mycloud
OPENSTACK_USER=admin
OPENSTACK_USER_PASSWD=dragonrising

#################
### SCATTERED ###
#################

# Network Settings
################################
INT_GW=192.168.0.1
TENANT_GW=172.16.0.1
#NAT_ID=100
#TENANT_ID=200
DNS_ADDR=8.8.8.8
NET_CIDR=255.255.255.0
FLOAT_RANGE=10.1.0.128/25

# MASHINES SETTINGS
################################
CONTROLLER=controller1
CONTROLLER_NAT_IP=10.0.2.15
CONTROLLER_INT_IP=192.168.0.10
CONTROLLER_TENANT_IP=172.16.0.10

COMPUTE1=compute1
COMPUTE1_NAT_IP=10.0.2.16
COMPUTE1_INT_IP=192.168.0.11
COMPUTE1_TENANT_IP=172.16.0.100

COMPUTE2=compute2
COMPUTE2_NAT_IP=10.0.2.17
COMPUTE2_INT_IP=192.168.0.12
COMPUTE2_TENANT_IP=172.16.0.20