#!/bin/bash

sudo tee -a /etc/network/interfaces << EOF

auto eth1
iface eth1 inet static
address 192.168.56.102
netmask 255.255.255.0
gateway 192.168.56.10
dns-nameservers 192.168.56.10
EOF

sudo ifup eth1
sudo ip addr add 192.168.56.102/24 dev eth1 2>/dev/null
sudo ip link set eth1 up
