#!/bin/bash

# Lancer les conteneurs
echo "Lancement des conteneurs"
lxc launch ubuntu:22.04 web
lxc launch ubuntu:20.04 db

# Mettre à jour les paquets et installer les logiciels nécessaires
echo "Mise à jour et installation des paquets"
lxc exec web -- apt update
lxc exec web -- apt install -y ssh
lxc exec db -- apt update
lxc exec db -- apt install -y ssh

# Ajouter un mot de passe à l'utilisateur root
echo "Mise à jour du mot de passe de root"
lxc exec web -- bash -c "echo 'root:lyes' | chpasswd"
lxc exec db -- bash -c "echo 'root:lyes' | chpasswd"

# Modifier la configuration SSH pour autoriser la connexion root et l'authentification par mot de passe
echo "Mise à jour de la configuration SSH"
lxc exec web -- bash -c "sed -i 's/^#PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config"
lxc exec web -- bash -c "sed -i 's/^#PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config"
lxc exec web -- bash -c "rm /etc/ssh/sshd_config.d/60-cloudimg-settings.conf"

lxc exec db -- bash -c "sed -i 's/^#PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config"
lxc exec db -- bash -c "sed -i 's/^#PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config"
lxc exec db -- bash -c "rm /etc/ssh/sshd_config.d/60-cloudimg-settings.conf"

# Redémarrer le service SSH pour appliquer les changements
echo "Redémarrage du service SSH"
lxc exec web -- systemctl restart ssh
lxc exec db -- systemctl restart ssh

# Création du réseau
echo "Création du réseau"
lxc network create ansible-net ipv4.address=192.168.100.3/24 ipv6.address=none ipv4.dhcp=false ipv6.dhcp=false
lxc network attach ansible-net web eth1
lxc network attach ansible-net db eth1

dir=$(pwd)
# Push des configurations réseau
echo "Configuration du container 'web'"
lxc file push $dir/config/web/50-cloud-init.yaml web/etc/netplan/50-cloud-init.yaml --uid 0 --gid 0 --mode 0644
lxc exec web -- netplan apply

echo "Configuration du container 'db'"
lxc file push $dir/config/db/50-cloud-init.yaml db/etc/netplan/50-cloud-init.yaml --uid 0 --gid 0 --mode 0644
lxc exec db -- netplan apply

# Lancer Ansible pour déployer CodeIgniter
echo "Lancement du playbook Ansible"
ansible-playbook playbook.yml

