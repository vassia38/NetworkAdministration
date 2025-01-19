#!/bin/bash

#Script pour supprimer les conteneurs du TP rapidement
containers="C1 C2 C3 R1 R2 R3 DHCP DNSMaster DNSSlave"
for container in $containers; do
    lxc stop $container
    lxc delete $container
done
