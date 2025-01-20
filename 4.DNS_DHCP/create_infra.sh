#!/bin/bash

lxc init ubuntu:24.04 R1
lxc init ubuntu:24.04 R2
lxc init ubuntu:24.04 R3

lxc init ubuntu:24.04 C1
lxc init ubuntu:24.04 C2
lxc init ubuntu:24.04 C3

lxc init ubuntu:24.04 DNSMaster
lxc init ubuntu:24.04 DNSSlave
lxc init ubuntu:24.04 DHCP

# net1: 192.168.10.0/26
# net2: 192.168.10.64/27
# net3: 192.168.10.96/28
lxc network create net1 ipv4.address=none ipv6.address=none ipv4.dhcp=false
lxc network create net2 ipv4.address=none ipv6.address=none ipv4.dhcp=false
lxc network create net3 ipv4.address=none ipv6.address=none ipv4.dhcp=false

# netR1-R2: 192.168.10.120/30 
# netR1-R3: 192.168.10.116/30 
# netR2-R3: 192.168.10.112/30
lxc network create netR1-R2 ipv4.address=none ipv6.address=none ipv4.dhcp=false
lxc network create netR1-R3 ipv4.address=none ipv6.address=none ipv4.dhcp=false
lxc network create netR2-R3 ipv4.address=none ipv6.address=none ipv4.dhcp=false

#Router R3 > net1
lxc config device add R3 eth1 nic nictype=bridged parent=net1
lxc config device add R3 eth2 nic nictype=bridged parent=netR1-R3
lxc config device add R3 eth3 nic nictype=bridged parent=netR2-R3

#Router R1 > net2
lxc config device add R1 eth1 nic nictype=bridged parent=net2
lxc config device add R1 eth2 nic nictype=bridged parent=netR1-R3
lxc config device add R1 eth3 nic nictype=bridged parent=netR1-R2

#Router R2 > net3
lxc config device add R2 eth1 nic nictype=bridged parent=net3
lxc config device add R2 eth2 nic nictype=bridged parent=netR2-R3
lxc config device add R2 eth3 nic nictype=bridged parent=netR1-R2

#Clients C1, C2, C3
lxc config device add C1 eth1 nic nictype=bridged parent=net1
lxc config device add C2 eth1 nic nictype=bridged parent=net2
lxc config device add C3 eth1 nic nictype=bridged parent=net3

#DNSMaster, DNSSlave, DHCP
lxc config device add DNSMaster eth1 nic nictype=bridged parent=net1
lxc config device add DNSSlave eth1 nic nictype=bridged parent=net3
lxc config device add DHCP eth1 nic nictype=bridged parent=net2

containers="R1 R2 R3 C1 C2 C3 DHCP DNSMaster DNSSlave"
for cont in $containers; do
	echo "Launch  $cont"
	lxc start $cont
done
