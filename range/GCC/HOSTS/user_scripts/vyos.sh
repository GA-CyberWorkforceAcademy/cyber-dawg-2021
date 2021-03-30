#!/bin/vbash
# Base OS Changes
source /opt/vyatta/etc/functions/script-template
configure

# System Properties
set system config-management commit-revisions '20'
set system console device ttyS0 speed '9600'
set system host-name 'gcc_vyos_rtr'
set system login user vyos authentication plaintext-password '$userpass'
set system login user root authentication plaintext-password '$adminpass'
set system login user root level 'admin'
set system package auto-sync '1'
set system package repository community components 'main'
set system package repository community distribution 'helium'
set system package repository community password ''
set system package repository community url 'http://packages.vyos.net/vyos'
set system package repository community username ''
set system syslog global facility all level 'notice'
set system syslog global facility protocols level 'debug'
set system time-zone 'UTC'

# Router Interfaces
set interfaces ethernet eth0 mtu 1450
set interfaces ethernet eth1 mtu 1450
set interfaces ethernet eth0 description INTERNET
set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth1 description GCC_GTA_NET
set interfaces ethernet eth1 address 10.220.0.253/24
set interfaces loopback lo
set interfaces loopback lo address 10.100.0.1/32

# Nat rules for outbound traffic
set nat source rule 100 outbound-interface eth0
set nat source rule 100 'source'
set nat source rule 100 translation address masquerade

# System Services
set service ssh allow-root
set service ssh port 22

# System Properties
#set system login user vyos authentication plaintext-password $userpass
#set system login user root authentication plaintext-password $adminpass

# Default Route to Internet
set protocols static route 0.0.0.0/0 next-hop 10.100.0.254 distance 1

commit
save
done

reboot