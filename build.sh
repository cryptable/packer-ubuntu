#!/bin/bash

source ./image-configs/$1-$2.shvars
sh ./scripts/prep-userdata-$2-iso.sh

if [ $2 == "vmware" ]; then 
  packer build -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var-file=./image-configs/$1-$2.pkrvars.hcl -only vmware-iso.ubuntu .
fi

if [ $2 == "proxmox" ]; then
  packer build -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var-file=./image-configs/$1-$2.pkrvars.hcl -only proxmox-iso.ubuntu .
fi
