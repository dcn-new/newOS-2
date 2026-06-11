#!/bin/sh

# get rid!!
sudo rm /etc/resolv.conf

# Sym-link services
sudo ln -s /etc/sv/NetworkManager /var/service
sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/seatd /var/service
sudo ln -s /etc/sv/acpid /var/service

# Connect to network
sudo nmtui

# Remove current bash and X-files
sudo rm ~/.bashrc ~/.bash_profile

# Copy new bash and X-files into place
sudo cp ~/build/newOS-2/.bashrc ~/
sudo cp ~/build/newOS-2/.bash_profile ~/

# Move pictures folder (wallpapers)
sudo cp -r ~/build/newOS-2/Pictures ~/

# Move dotfiles into place
sudo mkdir -p ~/.config
sudo cp ~/build/newOS-2/alacritty ~/.config/
sudo cp ~/build/newOS-2/i3 ~/.config/

# Copy fonts
sudo mkdir -p ~/.local/share
sudo cp -r ~/build/newOS-2/fonts ~/.local/share/

# reboot
sudo reboot
