#!/bin/sh

# Remove current bash and X-files
sudo rm ~/.bashrc ~/.bash_profile
sudo rm ~/.Xresources

# Copy new bash and X-files into place
sudo cp ~/build/newOS-2/.bashrc ~/
sudo cp ~/build/newOS-2/.bash_profile ~/
sudo cp ~/build/newOS-2/.xinitrc ~/
sudo cp ~/build/newOS-2/.Xresources ~/

# Move pictures folder (wallpapers)
sudo cp -r ~/build/newOS-2/Pictures ~/

# Move dotfiles into place
sudo mkdir -p ~/.config
sudo cp ~/build/newOS-2/alacritty ~/.config/
sudo cp ~/build/newOS-2/i3 ~/.config/

# Copy fonts
sudo mkdir -p ~/.local/share
sudo cp -r ~/build/newOS-2/fonts ~/.local/share/

# Copy keyboard and touchpad configs
sudo cp -r ~/build/newOS-2/xorg.conf.d /etc/X11/

# reboot
sudo reboot
