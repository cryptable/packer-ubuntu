#!/bin/bash

source ./image-configs/$1-$2.shvars
sh ./scripts/prep-userdata-$2-iso.sh

packer build -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var-file=./image-configs/$1-$2.pkrvars.hcl .