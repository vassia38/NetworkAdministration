#!/bin/bash

sudo apt install -y lxc lxc-templates
sudo snap install lxd

lxd init --auto

lxc-create --name router1 --template download -- --dist alpine --release 3.17 --arch amd64
lxc-create --name router2 --template download -- --dist alpine --release 3.17 --arch amd64
lxc-create --name router3 --template download -- --dist alpine --release 3.17 --arch amd64
lxc-create --name C1 --template download -- --dist alpine --release 3.17 --arch amd64
lxc-create --name C2 --template download -- --dist alpine --release 3.17 --arch amd64
lxc-create --name C3 --template download -- --dist alpine --release 3.17 --arch amd64
lxc-create --name DNS_PRIN --template download -- --dist ubuntu --release 20.04 --arch amd64
lxc-create --name DNS_SEC --template download -- --dist alpine --release 20.04 --arch amd64
lxc-create --name DHCP --template download -- --dist alpine --release 20.04 --arch amd64
