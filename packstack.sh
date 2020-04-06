#!/bin/bash

# 1. Preparation Steps
systemctl disable --now firewalld NetworkManager
setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
hostnamectl set-hostname packstack.demo.local --static
yum -y install vim wget curl telnet bash-completion
yum install -y https://www.rdoproject.org/repos/rdo-release.rpm
yum update -y
yum install -y openstack-packstack openstack-utils

# 2. Prepare Files + Installation
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
sudo packstack --provision-demo=n --os-neutron-ml2-type-drivers=vxlan,flat,vlan --gen-answer-file=packstack-answers.txt
sed -i -e 's:10.0.2.15:10.1.0.10:' packstack-answers.txt
echo -e "CONFIG_NOVA_COMPUTE_PRIVIF=eth0\nCONFIG_NOVA_NETWORK_PUBIF=eth1\nCONFIG_NOVA_NETWORK_PRIVIF=eth0" >> packstack-answers.txt
packstack --answer-file=packstack-answers.txt
cp /vagrant/templates/ifcfg-eth1.j2 /etc/sysconfig/network-scripts/
cp /vagrant/templates/ifcfg-br-ex.j2 /etc/sysconfig/network-scripts/
systemctl stop network.service
ifdown eth1 && ifdown br-ex
ifup br-ex && ifup eth1
systemctl start network.service
# 3. Configure Networking
source /etc/environment
source /root/keystonerc_admin
neutron net-create external_network --provider:network_type flat --provider:physical_network extnet  --router:external
neutron subnet-create --name external_subnet --enable_dhcp=False --allocation-pool=start=10.1.0.100,end=10.1.0.120 --gateway=10.1.0.1 external_network 10.1.0.0/24
neutron router-create router1
neutron router-gateway-set router1 external_network
neutron net-create private_network
neutron subnet-create --name private_subnet private_network 192.168.100.0/24
neutron router-interface-add router1 private_subnet

# 4. Create an Image + Security Group
openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey
openstack security group create allow_ssh_http --description "Define ssh connection and http to everyone"
openstack security group rule create allow_ssh_http --protocol tcp --dst-port 80:80 --remote-ip 0.0.0.0/0
openstack security group rule create allow_ssh_http --protocol tcp --dst-port 443:443 --remote-ip 0.0.0.0/0
openstack security group rule create allow_ssh_http --protocol icmp
openstack security group rule create allow_ssh_http --protocol tcp --dst-port 22

# 5. RUN IMAGE
image_id=$(openstack image list | grep cirros | awk '{print $2}')
nano_flavor_id=$(openstack flavor list | grep nano | awk '{print $4}')
priv_net_id=$(openstack network list | grep private | awk '{print $2}')
security_group_id=$(openstack security group list | grep allow_ssh_http | awk '{print $2}')
openstack server create --flavor ${nano_flavor_id} --image cirros --nic net-id=${priv_net_id} --security-group ${security_group_id} --key-name mykey instance01

# 6. Create Floating IP and Assign it
floating_ip=$(openstack floating ip create external_network | grep floating_ip_address | awk '{print $4}')
openstack server add floating ip instance01 ${floating_ip}