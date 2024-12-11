#!/bin/bash

sudo apt install -y lxc lxc-templates
sudo snap install lxd

lxd init --auto

lxc launch ubuntu:20.04 R1
lxc launch ubuntu:20.04 R2
lxc launch ubuntu:20.04 R3
lxc launch ubuntu:20.04 C2
lxc launch ubuntu:20.04 DHCP
lxc launch ubuntu:20.04 C1
lxc launch ubuntu:20.04 DNSMAITRE
lxc launch ubuntu:20.04 C3
lxc launch ubuntu:20.04 DNSSECONDAIRE

lxc network create br12 ipv4.address=none ipv6.address=none
lxc network create br23 ipv4.address=none ipv6.address=none
lxc network create br13 ipv4.address=none ipv6.address=none


lxc network create br1 ipv4.address=none ipv6.address=none
lxc network create br2 ipv4.address=none ipv6.address=none
lxc network create br3 ipv4.address=none ipv6.address=none

lxc network attach br1 R1 eth0
lxc network attach br1 DHCP eth0
lxc network attach br1 C2 eth0

lxc network attach br2 R2 eth0
lxc network attach br2 DNSSECONDAIRE eth0
lxc network attach br2 C1 eth0

lxc network attach br3 R3 eth0
lxc network attach br3 DNSMAITRE eth0
lxc network attach br3 C3 eth0


lxc network attach br12 R1 eth1
lxc network attach br12 R2 eth1
lxc network attach br13 R1 eth2
lxc network attach br13 R3 eth1
lxc network attach br23 R2 eth2
lxc network attach br23 R3 eth2

lxc file push R1/50-cloud-init.yaml R1/etc/netplan/50-cloud-init.yaml
lxc file push R2/50-cloud-init.yaml R2/etc/netplan/50-cloud-init.yaml
lxc file push R3/50-cloud-init.yaml R3/etc/netplan/50-cloud-init.yaml
lxc file push DHCP/50-cloud-init.yaml DHCP/etc/netplan/50-cloud-init.yaml
lxc file push DNSMAITRE/50-cloud-init.yaml DNSMAITRE/etc/netplan/50-cloud-init.yaml
lxc file push DNSSECONDAIRE/50-cloud-init.yaml DNSSECONDAIRE/etc/netplan/50-cloud-init.yaml
lxc file push C1/50-cloud-init.yaml C1/etc/netplan/50-cloud-init.yaml
lxc file push C2/50-cloud-init.yaml C2/etc/netplan/50-cloud-init.yaml
lxc file push C3/50-cloud-init.yaml C3/etc/netplan/50-cloud-init.yaml

lxc exec R1 -- netplan apply
lxc exec R2 -- netplan apply
lxc exec R3 -- netplan apply
lxc exec DHCP -- netplan apply
lxc exec DNSMAITRE -- netplan apply
lxc exec DNSSECONDAIRE -- netplan apply

lxc exec C1 -- netplan apply
lxc exec C2 -- netplan apply
lxc exec C3 -- netplan apply

echo "Configuration terminée."

<< EOF
echo "Test de configuration."

echo "====== R1 ======"
echo "R1 ping DHCP"
lxc exec R1 -- ping -c 4 192.168.1.65
echo "R1 ping C2"
lxc exec R1 -- ping -c 4 192.168.1.66
echo "R1 ping R2"
lxc exec R1 -- ping -c 4 192.168.1.110
echo "R1 ping R3"
lxc exec R1 -- ping -c 4 192.168.1.62
echo "R1 ping DNSMAITRE"
lxc exec R1 -- ping -c 4 192.168.1.1
echo "R1 ping DNSSECONDAIRE"
lxc exec R1 -- ping -c 4 192.168.1.97
echo "R1 ping C1"
lxc exec R1 -- ping -c 4 192.168.1.98
echo "R1 ping C3"
lxc exec R1 -- ping -c 4 192.168.1.2



echo "====== R2 ======"
echo "R2 ping DHCP"
lxc exec R2 -- ping -c 4 192.168.1.65
echo "R2 ping C2"
lxc exec R2 -- ping -c 4 192.168.1.66
echo "R2 ping R1"
lxc exec R2 -- ping -c 4 192.168.1.94
echo "R2 ping R3"
lxc exec R2 -- ping -c 4 192.168.1.62
echo "R2 ping DNSMAITRE"
lxc exec R2 -- ping -c 4 192.168.1.1
echo "R2 ping DNSSECONDAIRE"
lxc exec R2 -- ping -c 4 192.168.1.97
echo "R2 ping C1"
lxc exec R2 -- ping -c 4 192.168.1.98
echo "R2 ping C3"
lxc exec R2 -- ping -c 4 192.168.1.2


echo "====== R3 ======"
echo "R3 ping DHCP"
lxc exec R3 -- ping -c 4 192.168.1.65
echo "R3 ping C2"
lxc exec R3 -- ping -c 4 192.168.1.66
echo "R3 ping R1"
lxc exec R3 -- ping -c 4 192.168.1.94
echo "R3 ping R1"
lxc exec R3 -- ping -c 4 192.168.1.94
echo "R3 ping DNSMAITRE"
lxc exec R3 -- ping -c 4 192.168.1.1
echo "R3 ping DNSSECONDAIRE"
lxc exec R3 -- ping -c 4 192.168.1.97
echo "R3 ping C1"
lxc exec R3 -- ping -c 4 192.168.1.98
echo "R3 ping C3"
lxc exec R3 -- ping -c 4 192.168.1.2


echo "====== DHCP ======"
echo "DHCP ping R1"
lxc exec DHCP -- ping -c 4 192.168.1.94
echo "DHCP ping C2"
lxc exec DHCP -- ping -c 4 192.168.1.66
echo "DHCP ping R2"
lxc exec DHCP -- ping -c 4 192.168.1.110
echo "DHCP ping R3"
lxc exec DHCP -- ping -c 4 192.168.1.62
echo "DHCP ping DNSMAITRE"
lxc exec DHCP -- ping -c 4 192.168.1.1
echo "DHCP ping DNSSECONDAIRE"
lxc exec DHCP -- ping -c 4 192.168.1.97
echo "DHCP ping C1"
lxc exec DHCP -- ping -c 4 192.168.1.98
echo "DHCP ping C3"
lxc exec DHCP -- ping -c 4 192.168.1.2


echo "====== DNSMAITRE ======"
echo "DNSMAITRE ping R1"
lxc exec DNSMAITRE -- ping -c 4 192.168.1.94
echo "DNSMAITRE ping C2"
lxc exec DNSMAITRE -- ping -c 4 192.168.1.66
echo "DNSMAITRE ping R2"
lxc exec DNSMAITRE -- ping -c 4 192.168.1.110
echo "DNSMAITRE ping R3"
lxc exec DNSMAITRE -- ping -c 4 192.168.1.62
echo "DNSMAITRE ping DHCP"
lxc exec DNSMAITRE -- ping -c 4 192.168.1.65
echo "DNSMAITRE ping DNSSECONDAIRE"
lxc exec DNSMAITRE -- ping -c 4 192.168.1.97
echo "DNSMAITRE ping C1"
lxc exec DNSMAITRE -- ping -c 4 192.168.1.98
echo "DNSMAITRE ping C3"
lxc exec DNSMAITRE -- ping -c 4 192.168.1.2


echo "====== DNSSECONDAIRE ======"
echo "DNSSECONDAIRE ping R1"
lxc exec DNSSECONDAIRE -- ping -c 4 192.168.1.94
echo "DNSSECONDAIRE ping C2"
lxc exec DNSSECONDAIRE -- ping -c 4 192.168.1.66
echo "DNSSECONDAIRE ping R2"
lxc exec DNSSECONDAIRE -- ping -c 4 192.168.1.110
echo "DNSSECONDAIRE ping R3"
lxc exec DNSSECONDAIRE -- ping -c 4 192.168.1.62
echo "DNSSECONDAIRE ping DHCP"
lxc exec DNSSECONDAIRE -- ping -c 4 192.168.1.65
echo "DNSSECONDAIRE ping DNSMAITRE"
lxc exec DNSSECONDAIRE -- ping -c 4 192.168.1.1
echo "DNSSECONDAIRE ping C1"
lxc exec DNSSECONDAIRE -- ping -c 4 192.168.1.98
echo "DNSSECONDAIRE ping C3"
lxc exec DNSSECONDAIRE -- ping -c 4 192.168.1.2


echo "====== C1 ======"
echo "C1 ping R1"
lxc exec C1 -- ping -c 4 192.168.1.94
echo "C1 ping C2"
lxc exec C1 -- ping -c 4 192.168.1.66
echo "C1 ping R2"
lxc exec C1 -- ping -c 4 192.168.1.110
echo "C1 ping R3"
lxc exec C1 -- ping -c 4 192.168.1.62
echo "C1 ping DHCP"
lxc exec C1 -- ping -c 4 192.168.1.65
echo "C1 ping DNSMAITRE"
lxc exec C1 -- ping -c 4 192.168.1.1
echo "C1 ping DNSSECONDAIRE"
lxc exec C1 -- ping -c 4 192.168.1.97
echo "C1 ping C3"
lxc exec C1 -- ping -c 4 192.168.1.2

echo "====== C2 ======"
echo "C2 ping R1"
lxc exec C2 -- ping -c 4 192.168.1.94
echo "C2 ping C1"
lxc exec C2 -- ping -c 4 192.168.1.98
echo "C2 ping R2"
lxc exec C2 -- ping -c 4 192.168.1.110
echo "C2 ping R3"
lxc exec C2 -- ping -c 4 192.168.1.62
echo "C2 ping DHCP"
lxc exec C2 -- ping -c 4 192.168.1.65
echo "C2 ping DNSMAITRE"
lxc exec C2 -- ping -c 4 192.168.1.1
echo "C2 ping DNSSECONDAIRE"
lxc exec C2 -- ping -c 4 192.168.1.97
echo "C2 ping C3"
lxc exec C2 -- ping -c 4 192.168.1.2


echo "====== C3 ======"
echo "C3 ping R1"
lxc exec C3 -- ping -c 4 192.168.1.94
echo "C3 ping C1"
lxc exec C3 -- ping -c 4 192.168.1.98
echo "C3 ping R2"
lxc exec C3 -- ping -c 4 192.168.1.110
echo "C3 ping R3"
lxc exec C3 -- ping -c 4 192.168.1.62
echo "C3 ping DHCP"
lxc exec C3 -- ping -c 4 192.168.1.65
echo "C3 ping DNSMAITRE"
lxc exec C3 -- ping -c 4 192.168.1.1
echo "C3 ping DNSSECONDAIRE"
lxc exec C3 -- ping -c 4 192.168.1.97
echo "C3 ping C2"
lxc exec C3 -- ping -c 4 192.168.1.66

EOF




