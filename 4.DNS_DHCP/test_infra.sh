#!/bin/bash

# Codes de couleur
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sans couleur

# Création de nouveaux conteneurs pour le test DHCP
echo -e "${YELLOW}Création de nouveaux conteneurs pour le test DHCP${NC}"
lxc launch ubuntu:20.04 C4 --network net1
lxc launch ubuntu:20.04 C5 --network net3

# Liste des conteneurs
conteneurs="C1 C2 C3 DNSMaster DNSSlave DHCP R1 R2 R3"

# 1. Tester la connectivité entre les conteneurs
echo -e "${YELLOW}Test de la connectivité entre les conteneurs${NC}"
for conteneur1 in $conteneurs; do
    for conteneur2 in $conteneurs; do
        if [ "$conteneur1" != "$conteneur2" ]; then
            echo -e "${YELLOW}Ping de $conteneur1 à $conteneur2${NC}"
            if lxc exec $conteneur1 -- ping -c 3 $conteneur2; then
                echo -e "${GREEN}Ping réussi !${NC}"
            else
                echo -e "${RED}Échec du ping de $conteneur1 à $conteneur2${NC}"
            fi
        fi
    done
done

# 2. Vérifier le serveur DNS
echo -e "${YELLOW}Vérification du serveur DNS : DNSMaster${NC}"
dns_server="192.168.10.3"
domain="ssi.edu"

echo -e "${YELLOW}Test de la résolution DNS pour $domain sur le DNSMaster${NC}"
lxc exec C1 -- nslookup R3
lxc exec C1 -- host -a C2

# Arrêt du DNSMaster pour le test
echo -e "${YELLOW}Arrêt du serveur DNS Master${NC}"
lxc exec DNSMaster -- systemctl stop bind9

echo -e "${YELLOW}Test de la résolution DNS $domain sur le DNSSlave${NC}"
lxc exec C1 -- nslookup R3
lxc exec C1 -- host -a C2

# Démarrage du DNSMaster après le test
echo -e "${YELLOW}Démarrage du serveur DNS Master${NC}"
lxc exec DNSMaster -- systemctl start bind9

# 3. Test du serveur DHCP
echo -e "${YELLOW}Tester le serveur DHCP${NC}"
for conteneur in C4 C5; do
    echo -e "${YELLOW}Demande d'adresse IP sur $conteneur${NC}"
    if lxc exec $conteneur -- dhclient -v eth0; then
        echo -e "${GREEN}Adresse IP obtenue sur $conteneur${NC}"
    else
        echo -e "${RED}Échec de la demande d'adresse IP sur $conteneur${NC}"
    fi
    echo -e "${YELLOW}Vérification de l'adresse IP de $conteneur${NC}"
    lxc exec $conteneur -- ip addr show eth0
    echo -e "${YELLOW}Vérification de la connectivité du $conteneur${NC}"
    lxc exec $conteneur -- ping -c3 R1
    lxc exec $conteneur -- ping -c3 R3
    lxc exec $conteneur -- ping -c3 ns1
    echo -e "${YELLOW}Vérification de la sortie à internet${NC}"
    lxc exec $conteneur -- ping -c3 8.8.8.8
    lxc exec $conteneur -- ping -c3 google.com
done

# 4. Vérification le relais DHCP
echo -e "${YELLOW}Vérification du relais DHCP sur R2 et R3${NC}"
for router in R2 R3; do
    echo -e "${YELLOW}Configuration IP de $router${NC}"
    lxc exec $router -- ip addr show
done

echo -e "${YELLOW}Test du Site Web${NC}"
lxc exec C1 -- curl www.ssi.edu


echo -e "${GREEN}Tests terminés !${NC}"
