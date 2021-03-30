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
#apt-get upgrade -y

echo "*** Installing PT ***"
# ----- Packet Tracer Install
mkdir /usr/share/packet_tracer
wget https://gitlab.com/ga-cyberworkforceacademy/cyber-dawg-2021/-/raw/master/range/GCC/resources/Cisco-PT-7.1.1x64.tar
tar xvf Cisco-PT-7.1.1x64.tar
rm install

cat <<EOF > install.sh
#!/bin/bash

# Thanks to Brent C., Ruben L., Alan C. for updating this install script to make it install without prompts.
# Thanks to Paul Fedele for providing script to check/download 32-bit library on a 64-bit machine
echo
echo "Welcome to Cisco Packet Tracer 7.1.1 Installation"
echo
installer ()
{
SDIR=`dirname $_`

echo "Packet Tracer will now be installed in the default location [/opt/pt]"

IDIR="/opt/pt"

if [ -e \$IDIR ]; then
sudo rm -rf \$IDIR
fi

QIDIR=\${IDIR//\//\\\\\/}

echo "Installing into \$IDIR"

if mkdir \$IDIR > /dev/null 2>&1; then
if cp -r \$SDIR/* \$IDIR; then
echo "Copied all files successfully to \$IDIR"
fi

sh -c "sed s%III%\$QIDIR% \$SDIR/tpl.packettracer > \$IDIR/packettracer"
chmod a+x \$IDIR/packettracer
sh -c "sed s%III%\$QIDIR% \$SDIR/tpl.linguist > \$IDIR/linguist"
chmod a+x \$IDIR/linguist

if touch /usr/share/applications/pt7.desktop > /dev/null 2>&1; then
echo -e "[Desktop Entry]\nExec=PacketTracer7\nIcon=pt7\nType=Application\nTerminal=false\nName=Packet Tracer 7.1" | tee /usr/share/applications/pt7.desktop > /dev/null
rm -f /usr/share/icons/hicolor/48x48/apps/pt7.png
gtk-update-icon-cache -f -q /usr/share/icons/hicolor
sleep 10
cp $SDIR/art/app.png /usr/share/icons/hicolor/48x48/apps/pt7.png
gtk-update-icon-cache -f -q /usr/share/icons/hicolor
fi

else
echo
if sudo mkdir \$IDIR; then
echo "Installing into \$IDIR"
if sudo cp -r \$SDIR/* \$IDIR; then
echo "Copied all files successfully to \$IDIR"
else
echo
echo "Not able to copy files to \$IDIR"
echo "Exiting installation"
exit
fi
sudo sh -c "sed 's/III/\$QIDIR/ \$SDIR/tpl.packettracer > \$IDIR/packettracer'"
sudo chmod a+x \$IDIR/packettracer
sudo sh -c "sed 's/III/\$QIDIR/ \$SDIR/tpl.linguist > \$IDIR/linguist'"
sudo chmod a+x \$IDIR/linguist

if sudo touch /usr/share/applications/pt7.desktop; then
echo -e "[Desktop Entry]\nExec=PacketTracer7\nIcon=pt7\nType=Application\nTerminal=false\nName=Packet Tracer 7.1" | sudo tee /usr/share/applications/pt7.desktop > /dev/null
sudo rm -f /usr/share/icons/hicolor/48x48/apps/pt7.png
sudo gtk-update-icon-cache -f -q /usr/share/icons/hicolor
sleep 10
sudo cp \$SDIR/art/app.png /usr/share/icons/hicolor/48x48/apps/pt7.png
sudo gtk-update-icon-cache -f -q /usr/share/icons/hicolor
fi

else
echo
echo "Not able to gain root access with sudo"
echo "Exiting installation"
exit
fi
fi

echo
echo
sudo ln -sf \$IDIR/packettracer /usr/local/bin/packettracer
echo "Type \"packettracer\" in a terminal to start Cisco Packet Tracer"

# add the environment var PT7HOME
sudo sh set_ptenv.sh $IDIR
sudo sh set_qtenv.sh

echo
echo "Cisco Packet Tracer 7.1.1 installed successfully"
echo "Please restart you computer for the Packet Tracer settings to take effect"
}
installer
exit 0
EOF

chmod +x install.sh

./install.sh

cat <<__EOF__ > packettracer
#!/bin/bash
echo "Starting Packet Tracer 7.1.1"
PTDIR=/opt/pt
#export LD_LIBRARY_PATH=\$PTDIR/lib
pushd \$PTDIR/bin > /dev/null
./PacketTracer7 "\$@" > /dev/null 2>&1 &
popd > /dev/null
__EOF__

sudo chmod +x packettracer

sudo cp packettracer /usr/local/bin/packettracer

reboot