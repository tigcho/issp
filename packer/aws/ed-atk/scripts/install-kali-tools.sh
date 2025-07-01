#!/bin/bash
set -euo pipefail

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y wget gnupg2 software-properties-common

echo 'deb https://http.kali.org/kali kali-rolling main non-free contrib' | sudo tee /etc/apt/sources.list.d/kali.list
wget -q -O - https://archive.kali.org/archive-key.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kali-archive-keyring.gpg
sudo apt-get update

sudo tee /etc/apt/preferences.d/kali-tools <<EOF
Package: *
Pin: release o=Kali
Pin-Priority: 50

Package: kali-*
Pin: release o=Kali
Pin-Priority: 500
EOF

sudo apt-get install -y \
    nmap \
    nikto \
    sqlmap \
    dirb \
    gobuster \
    hydra \
    john \
    hashcat \
    metasploit-framework \
    burpsuite \
    wireshark \
    tcpdump \
    netcat-traditional \
    socat \
    curl \
    wget \
    git \
    python3-pip \
    crackmapexec \
    enum4linux \
    smbclient \
    rpcclient \
    ldaputils \
    dnsutils \
    whois \
    impacket-scripts

sudo apt-get install -y \
    responder \
    bloodhound \
    neo4j \
    masscan \
    zaproxy \
    aircrack-ng

sudo apt-get autoremove -y
sudo apt-get autoclean
