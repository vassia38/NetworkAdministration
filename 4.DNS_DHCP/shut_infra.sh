#!/bin/bash

containers="C1 C2 C3 R1 R2 R3 DHCP DNSMaster DNSSlave"
for cont in $containers; do
    lxc stop $cont
    lxc delete $cont
done
