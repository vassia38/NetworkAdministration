#!/bin/bash

#Script pour supprimer les réseaux du TP rapidement
networks="net1 net2 net3 netR1-R2 netR1-R3 netR2-R3"
for network in $networks; do
    lxc network delete $network
done
