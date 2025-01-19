#!/bin/bash

#Création des conteneurs
#Routeurs
lxc init ubuntu:20.04 R1
lxc init ubuntu:20.04 R2
lxc init ubuntu:20.04 R3

#Clients
lxc init ubuntu:20.04 C1
lxc init ubuntu:20.04 C2
lxc init ubuntu:20.04 C3

#Serveurs
lxc init ubuntu:20.04 DNSMaster
lxc init ubuntu:20.04 DNSSlave
lxc init ubuntu:20.04 DHCP

#Création des Réseaux
#net1: 192.168.10.0/26 | net2: 192.168.10.64/27 | net3: 192.168.10.96/28
#netR1-R2: 192.168.10.120/30 | netR1-R3: 192.168.10.116/30 | netR2-R3: 192.168.10.112/30
lxc network create net1 ipv4.address=none ipv6.address=none ipv4.dhcp=false
lxc network create net2 ipv4.address=none ipv6.address=none ipv4.dhcp=false
lxc network create net3 ipv4.address=none ipv6.address=none ipv4.dhcp=false
lxc network create netR1-R2 ipv4.address=none ipv6.address=none ipv4.dhcp=false
lxc network create netR1-R3 ipv4.address=none ipv6.address=none ipv4.dhcp=false
lxc network create netR2-R3 ipv4.address=none ipv6.address=none ipv4.dhcp=false

#Configuration des interfaces
#Routeurs
#Routeur R3 --> net1
lxc config device add R3 eth1 nic nictype=bridged parent=net1
lxc config device add R3 eth2 nic nictype=bridged parent=netR1-R3
lxc config device add R3 eth3 nic nictype=bridged parent=netR2-R3

#Routeur R1 --> net2
lxc config device add R1 eth1 nic nictype=bridged parent=net2
lxc config device add R1 eth2 nic nictype=bridged parent=netR1-R3
lxc config device add R1 eth3 nic nictype=bridged parent=netR1-R2

#Routeur R2 --> net3
lxc config device add R2 eth1 nic nictype=bridged parent=net3
lxc config device add R2 eth2 nic nictype=bridged parent=netR2-R3
lxc config device add R2 eth3 nic nictype=bridged parent=netR1-R2

#Clients
#Client C1
lxc config device add C1 eth1 nic nictype=bridged parent=net1

#Client C2
lxc config device add C2 eth1 nic nictype=bridged parent=net2

#Client C3
lxc config device add C3 eth1 nic nictype=bridged parent=net3

#Serveurs
#DNSMaster
lxc config device add DNSMaster eth1 nic nictype=bridged parent=net1

#DNSSlave
lxc config device add DNSSlave eth1 nic nictype=bridged parent=net3

#DHCP
lxc config device add DHCP eth1 nic nictype=bridged parent=net2

#Lancement des conteneurs
conteneurs="R1 R2 R3 C1 C2 C3 DHCP DNSMaster DNSSlave"
for conteneur in $conteneurs; do
	echo "Lancement de $conteneur"
	lxc start $conteneur
done
