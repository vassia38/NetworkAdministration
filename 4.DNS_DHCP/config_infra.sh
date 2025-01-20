#!/bin/bash

containers="R1 R2 R3 DHCP DNSSlave DNSMaster"
for cont in $containers; do
  lxc exec $cont -- apt update
done
# Install packets for DNS
lxc exec DNSSlave -- apt install bind9 bind9-utils -y
lxc exec DNSMaster -- apt install bind9 bind9-utils -y

# Install necessary packets for the DHCP server and the routers that
# will forward DHCP requests from client to the server
lxc exec DHCP -- apt install isc-dhcp-server -y
lxc exec R3 -- apt install isc-dhcp-relay iptables-persistent -y
lxc exec R2 -- apt install isc-dhcp-relay iptables-persistent -y
lxc exec R1 -- apt install iptables-persistent -y
# Web Server
lxc exec DHCP -- apt install nginx -y


#Configure the network interfaces
dir=$(pwd)
config_dir="${dir}/Config-files"
containers="R1 R2 R3 C1 C2 C3 DHCP DNSSlave DNSMaster"
for cont in $containers; do
	echo "Config $cont"
	lxc file push $config_dir/$cont/50-cloud-init.yaml $cont/etc/netplan/50-cloud-init.yaml --uid 0 --gid 0 --mode 0644 #Push the config; set proper access rights
	lxc exec $cont -- netplan apply
done


#Push the configuration for DNSMaster
echo "Config server DNS: DNSMaster"
lxc file push $config_dir/DNSMaster/named.conf.local DNSMaster/etc/bind/named.conf.local --uid 0 --gid 120 --mode 0644
lxc file push $config_dir/DNSMaster/named.conf.options DNSMaster/etc/bind/named.conf.options --uid 0 --gid 120 --mode 0644
lxc file push $config_dir/DNSMaster/db.ssi.edu DNSMaster/etc/bind/db.ssi.edu --uid 120 --gid 120 --mode 0644
lxc exec DNSMaster -- systemctl restart bind9


#Push the configuration for DNSSlave
echo "Config server DNS: DNSSlave"
lxc file push $config_dir/DNSSlave/named.conf.local DNSSlave/etc/bind/named.conf.local --uid 0 --gid 120 --mode 0644
lxc exec DNSSlave -- systemctl restart bind9


#Push the configuration for DHCP
echo "Config server DHCP"
lxc file push $config_dir/DHCP/dhcpd.conf DHCP/etc/dhcp/dhcpd.conf --uid 0 --gid 0 --mode 0644
lxc exec DHCP -- systemctl restart isc-dhcp-server


#Configure port forwading and NAT for the routers
containers="R1 R2 R3"
for cont in $containers; do
  lxc exec $cont -- sysctl -w net.ipv4.ip_forward=1
  # lxc exec $cont -- bash -c "sysctl -p"
  lxc exec $cont -- iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  lxc exec $cont -- netfilter-persistent save
done
lxc exec R2 -- systemctl restart isc-dhcp-relay
lxc exec R3 -- systemctl restart isc-dhcp-relay

#Shut down eth0, which was used only for installing the needed packages
containers="C1 C2 C3 DHCP DNSSlave DNSMaster"
for cont in $containers; do
	lxc exec $cont -- ip link set dev eth0 down
done

