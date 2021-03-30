#!/bin/bash

# ----- CREATES USER GROUPS
echo "root:$pass" | chpasswd
useradd -m -U -s /bin/bash $user
usermod -aG sudo $user
echo "$user:$userpass" | chpasswd

echo "domain kinetic" > /etc/resolv.conf
echo "search kinetic" >>/etc/resolv.conf
echo "nameserver $domain" >>/etc/resolv.conf

# ----- ENABLE SUDO NOPASSWD
sed -i '/# %wheel        ALL=(ALL)       NOPASSWD: ALL/ c\%wheel        ALL=(ALL)       NOPASSWD: ALL' /etc/sudoers

# ----- ENABLES SSH[8]in prohibit-password/ c\PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '/#Port 22/ c\Port 22' /etc/ssh/sshd_config
sed -i '/#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config
service sshd restart

# ----- CREATES USER GROUPS
echo "root:$pass" | chpasswd
useradd -m -U -s /bin/bash $user
usermod -aG sudo $user
echo "$user:$pass" | chpasswd

# ----- updates
apt-get update -y
apt-get upgrade -y
modprobe -I psmouse

reboot