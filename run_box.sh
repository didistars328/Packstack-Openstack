#!/bin/bash

# Start
echo "===================================="
echo "  ----------- Load Box -----------  "
echo "===================================="

# Source ENV
set -a
source env_vars.sh
set +a

# Load Box
vagrant box list | grep $BOX_NAME
if [[ $? != 0 ]]; then
  vagrant box add $BOX_NAME
else
  echo "$BOX_NAME is allready loaded..."
fi

# Functions:
group_inventory () {
echo "int_ip: $INT_IP" > $PACKAGE_LOCATION/inventory/group_vars/all
echo "int_gw: $INT_GW" >> $PACKAGE_LOCATION/inventory/group_vars/all
echo "netmask: $NET_CIDR" >> $PACKAGE_LOCATION/inventory/group_vars/all
echo "dns_addr: $DNS_ADDR" >> $PACKAGE_LOCATION/inventory/group_vars/all
echo "nat_ip: $NAT_IP" >> $PACKAGE_LOCATION/inventory/group_vars/all
}

# Run Box
echo "===================================="
echo "  ----------- Run Box -----------  "
echo "===================================="
if [[ $ENV != split ]]
then
  cd all_in_one/
  vagrant up
  PORT_ID=$(vagrant ssh-config  | grep -E 'Port' | awk '{print$2}')
  echo "[controller]" > $PACKAGE_LOCATION/inventory/hosts
  echo "$MASHINE_NAME ansible_host=127.0.0.1 ansible_port=$PORT_ID ansible_user=vagrant \
  ansible_ssh_private_key_file=$PWD/.vagrant/machines/$MASHINE_NAME/virtualbox/private_key" >> $PACKAGE_LOCATION/inventory/hosts
  group_inventory
else
  cd scattered/
  vagrant up
  echo "[controller]" > $PACKAGE_LOCATION/inventory/hosts
  echo -e "$CONTROLLER ansible_host=127.0.0.1 ansible_port=$PORT_ID ansible_user=vagrant \
  ansible_ssh_private_key_file=$PWD/.vagrant/machines/$CONTROLLER/virtualbox/private_key\n" >> $PACKAGE_LOCATION/inventory/hosts
  echo "[compute]" >> $PACKAGE_LOCATION/inventory/hosts
  for LIST in COMPUTE1 COMPUTE2
    do
      PORT_ID=$(vagrant ssh-config  | grep -E 'Port' | awk '{print$2}')
      set MASHINE_NAME=$LIST
      echo "$MASHINE_NAME ansible_host=127.0.0.1 ansible_port=$PORT_ID ansible_user=vagrant \
      ansible_ssh_private_key_file=$PWD/.vagrant/machines/$MASHINE_NAME/virtualbox/private_key" >> $PACKAGE_LOCATION/inventory/hosts
    done
  group_inventory
fi

# Run Playbook
cd .. && ansible-playbook -i inventory install_${ENV}.yml