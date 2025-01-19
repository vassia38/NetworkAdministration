#!/bin/bash

#Installation des packages necéssaires pour DNS
lxc exec DNSSlave -- apt update 
lxc exec DNSSlave -- apt install bind9 bind9-utils -y
lxc exec DNSMaster -- apt update 
lxc exec DNSMaster -- apt install bind9 bind9-utils -y

#Installation des packages necéssaires pour DHCP Serveur et client
lxc exec DHCP -- apt update
lxc exec DHCP -- apt install isc-dhcp-server -y
lxc exec R3 -- apt update
lxc exec R3 -- apt install isc-dhcp-relay -y
lxc exec R2 -- apt update
lxc exec R2 -- apt install isc-dhcp-relay -y

#Installation du Serveur Web
lxc exec DHCP -- apt install nginx -y

#Configuration Basic des interfaces
dir=$(pwd)
conteneurs="R1 R2 R3 C1 C2 C3 DHCP DNSSlave DNSMaster"
for conteneur in $conteneurs; do
	echo "Configuration de $conteneur"
	lxc file push $dir/Fichier_Configuration/$conteneur/50-cloud-init.yaml $conteneur/etc/netplan/50-cloud-init.yaml --uid 0 --gid 0 --mode 0644 #Push du fichier de configuration avec les bon droits
	lxc exec $conteneur -- netplan apply #Mise en place de la configuration
done

#Push des configuration du DNSMaster
echo "Configuration du serveur DNS : DNSMaster"
lxc file push $dir/Fichier_Configuration/DNSMaster/named.conf.local DNSMaster/etc/bind/named.conf.local --uid 0 --gid 120 --mode 0644 #Push du fichier de configuration avec les bon droits
lxc file push $dir/Fichier_Configuration/DNSMaster/named.conf.options DNSMaster/etc/bind/named.conf.options --uid 0 --gid 120 --mode 0644
lxc file push $dir/Fichier_Configuration/DNSMaster/db.ssi.edu DNSMaster/etc/bind/db.ssi.edu --uid 120 --gid 120 --mode 0644
lxc exec DNSMaster -- systemctl restart bind9 #Mise en place de la configuration

#Push des configuration du DNSSlave
echo "Configuration du serveur DNS : DNSSlave"
lxc file push $dir/Fichier_Configuration/DNSSlave/named.conf.local DNSSlave/etc/bind/named.conf.local --uid 0 --gid 120 --mode 0644 #Push du fichier de configuration avec les bon droits
lxc exec DNSSlave -- systemctl restart bind9 #Mise en place de la configuration

#Push des configuration du DHCP
echo "Configuration du serveur DHCP"
lxc file push $dir/Fichier_Configuration/DHCP/dhcpd.conf DHCP/etc/dhcp/dhcpd.conf --uid 0 --gid 0 --mode 0644 #Push du fichier de configuration avec les bon droits
lxc exec DHCP -- systemctl restart isc-dhcp-server #Mise en place de la configuration

#Configuration du port forwading pour les routeur, ainsi que le NAT pour la connexion à internet
lxc exec R3 -- bash -c "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf"
lxc exec R3 -- bash -c "sysctl -p"
lxc exec R3 -- bash -c "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
lxc exec R3 -- systemctl restart isc-dhcp-relay # Restart du DHCP relay
lxc exec R2 -- bash -c "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf"
lxc exec R2 -- bash -c "sysctl -p"
lxc exec R2 -- bash -c "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
lxc exec R2 -- systemctl restart isc-dhcp-relay # Restart du DHCP relay
lxc exec R1 -- bash -c "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf"
lxc exec R1 -- bash -c "sysctl -p"
lxc exec R1 -- bash -c "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"


#Mettre les interfaces eth0 down pour tout les conteneurs sauf les routeurs, a fin de laisser la connexion à internet.
conteneurs="C1 C2 C3 DHCP DNSSlave DNSMaster"
for conteneur in $conteneurs; do
	lxc exec $conteneur -- ip link set dev eth0 down #Shut down de eth0 car inutile aprés installation des paquets
done