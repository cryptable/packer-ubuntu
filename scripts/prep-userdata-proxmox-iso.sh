#!/bin/sh

cat <<EOF > ./http/proxmox/linux/ubuntu/20.04/user-data
#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: be
    variant: be
  storage:
    layout:
      name: direct
  identity:
    hostname: ${HOSTNAME}
    username: ${USERNAME}
    password: "`printf ${PASSWORD} | openssl passwd -6 -salt ${SALT} -stdin`"
  ssh:
    # For now we install openssh-server during package installs
    allow-pw: true
    install-server: yes
    authorized-keys:
      - ${SSHKEY}
  user-data:
    disable_root: false
  early-commands:
    # Block inbound SSH to stop Packer trying to connect during initial install
    - iptables -A INPUT -p tcp --dport 22 -j DROP
  packages:
    - lsb-release
    - qemu-guest-agent
    - cloud-init
  late-commands:
    - sed -i 's/^#*\(send dhcp-client-identifier\).*$/\1 = hardware;/' /target/etc/dhcp/dhclient.conf
    - sed -i 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers
    - "echo 'Defaults:${USERNAME} !requiretty' > /target/etc/sudoers.d/${USERNAME}"
    - "echo '${USERNAME} ALL=(ALL) NOPASSWD: ALL' >> /target/etc/sudoers.d/${USERNAME}"
    - "chmod 440 /target/etc/sudoers.d/${USERNAME}"
    - 'sed -i "s/dhcp4: true/&\n      dhcp-identifier: duid/" /target/etc/netplan/00-installer-config.yaml'

EOF
