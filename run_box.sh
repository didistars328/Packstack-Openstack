#!/bin/bash
path=$(pwd)
source "${path}/env_vars.sh"
vagrant box list | grep $BOX_NAME
if [[ $? != 0 ]]; then
  vagrant box add $BOX_NAME
fi
mkdir ${path}/$MASHINE_NAME && cd ${path}/$MASHINE_NAME
vagrant init $BOX_NAME