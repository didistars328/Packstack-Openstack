#!/bin/bash

echo "===================================="
echo "  ----------- Load Box -----------  "
echo "===================================="

path=$(pwd)
source "${path}/env_vars.sh"
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
ansible-playbook -i hosts install_playbook.yml