#!/bin/bash

net_address="192.168.100.1"
net_netmask=24
net_name="net1"
lxc network create $net_name ipv4.nat=true ipv4.address=$net_address/$net_netmask ipv6.address=none ipv4.dhcp=false ipv6.dhcp=false
containers="web db"

for cont in $containers;do
  echo "[$cont] Launch"
  lxc launch ubuntu:24.04 $cont

  echo "[$cont] Update"
  lxc exec $cont -- apt update
  lxc exec $cont -- apt install -y ssh

  echo "[$cont] Change root password"
  lxc exec $cont -- bash -c "echo 'root:passwd' | chpasswd"
  
  echo "[$cont] modify ssh root permissions"
  lxc exec $cont -- bash -c "sed -i 's/^#PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config"
  lxc exec $cont -- bash -c "sed -i 's/^#PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config"
  lxc exec $cont -- bash -c "rm /etc/ssh/sshd_config.d/60-cloudimg-settings.conf"
  lxc exec $cont -- systemctl restart ssh

  echo "[$cont] config network"
  dir=$(pwd)
  lxc network attach $net_name $cont eth1
  lxc file push $dir/config/$cont/50-cloud-init.yaml $cont/etc/netplan/50-cloud-init.yaml --uid 0 --gid 0 --mode 0644
  lxc exec $cont -- netplan apply
done

echo "Launch the ansible playbook"
ansible-playbook playbook.yaml

