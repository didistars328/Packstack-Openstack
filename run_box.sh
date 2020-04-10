#!/bin/bash

echo "===================================="
echo "  ----------- Load Box -----------  "
echo "===================================="

set -a
source env_vars.sh
set +a

vagrant box list | grep $BOX_NAME
if [[ $? != 0 ]]; then
  vagrant box add $BOX_NAME
else
  echo "$BOX_NAME is allready loaded..."
fi
echo "===================================="
echo "  ----------- Run Box -----------  "
echo "===================================="

cd all_in_one/
vagrant up

echo "[controller]" > inventory/hosts
echo "$MASHINE_NAME ansible_host=127.0.0.1 ansible_port=2222 ansible_user=vagrant ansible_ssh_private_key_file=$PWD/.vagrant/machines/$MASHINE_NAME/virtualbox/private_key" >> inventory/hosts
echo "int_ip: $INT_IP" > inventory/group_vars/all
echo "int_gw: $INT_GW" >> inventory/group_vars/all
echo "netmask: $NET_CIDR" >> inventory/group_vars/all
echo "dns_addr: $DNS_ADDR" >> inventory/group_vars/all
echo "nat_ip: $NAT_IP" >> inventory/group_vars/all

ansible-playbook -i inventory install_playbook.yml