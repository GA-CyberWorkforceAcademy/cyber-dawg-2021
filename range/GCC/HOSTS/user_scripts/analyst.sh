#!/bin/bash

# ----- Change default gateway to vyos router
ip route add default via 10.220.0.253

# ----- CREATES USER GROUPS
echo "root:$admin_pass" | chpasswd
useradd -m -U -s /bin/bash $user
usermod -aG sudo $user
echo "$user:$pass" | chpasswd
echo "domain kinetic" > /etc/resolv.conf
echo "search kinetic" >>/etc/resolv.conf
echo "nameserver $domain" >>/etc/resolv.conf
# ----- ENABLE SUDO NOPASSWD
sed -i '/# %wheel        ALL=(ALL)       NOPASSWD: ALL/ c\%wheel        ALL=(ALL)       NOPASSWD: ALL' /etc/sudoers
# ----- ENABLES SSH[8]in prohibit-password/ c\PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '/#Port 22/ c\Port 22' /etc/ssh/sshd_config
sed -i '/#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config
service sshd restart
# ----- updates
apt-get update -y
#apt-get upgrade -y
apt-get install dialog libgl1-mesa-glx libxcb-xinerama0-dev -y
echo "*** Installing PT ***"
# ----- Packet Tracer Install
wget "https://archive.org/download/packet-tracer-800-build-212-mac-notarized/PacketTracer_800_amd64_build212_final.deb" -o /home/user/Desktop/packet_tracer_install.deb
#dpkg -i PacketTracer_800_amd64_build212_final.deb
shutdown -r now