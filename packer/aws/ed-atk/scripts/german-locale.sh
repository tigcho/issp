#!/bin/bash
set -e

sudo apt-get install -y language-pack-de
sudo locale-gen de_DE.UTF-8
sudo update-locale LANG=de_DE.UTF-8
sudo timedatectl set-timezone Europe/Berlin
sudo localectl set-keymap de
sudo localectl set-x11-keymap de
