#!/bin/bash

# ===================================================================
# STAGE 2: This block ONLY runs INSIDE the chroot environment
# ===================================================================
if [ "$1" == "--stage2" ]; then
    echo "=== Starting Stage 2: Inside the Chroot ==="
    
    # 1. System Config
    echo "newOS" > /etc/hostname
    ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
    echo 'KEYMAP="uk"' > /etc/rc.conf
    
    # 2. Set Locales
    echo "en_GB.UTF-8 UTF-8" > /etc/default/libc-locales
    xbps-reconfigure -f glibc-locales
    echo "LANG=en_GB.UTF-8" > /etc/locale.conf
    
    # 3. Users & Sudo Configuration
    echo "Set ROOT password:"
    passwd
    
    useradd -m -G wheel,video,input,audio dcn
    echo "Set USER password for yourusername:"
    passwd dcn
    
    EDITOR=vim visudo
    
    # 4. Blacklist Nvidia (Multi-line Heredoc)
    cat << 'EOF' > /etc/modprobe.d/blacklist-nvidia.conf
blacklist nouveau
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
blacklist nvidia_uvm
EOF

    # 5. Install Your Full Sway Stack & Core Packagesss
    echo "=== Installing Sway and Desktop Packages ==="
    sudo xbps-install -Sy sway swaylock swayidle swaybg foot firefox-esr wmenu \
	    pipewire wireplumber brightnessctl i3status pam_rundir vlc
    
    echo "=== Installing Utilities ==="
    sudo xbps-install -Sy wget fzf git grim slurp htop fastfetch unzip tree
    
    echo "=== Installing Driver Repositories ==="
    sudo xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
    
	echo "=== Installing Graphics Stack and Drivers ==="
    sudo xbps-install -Sy ffmpeg intel-ucode libva-intel-driver libva-utils mesa-demos mesa-dri \
	    mesa-vulkan-intel

	# 6. Install Fonts
    echo "=== Installing Fonts ==="
    sudo xbps-install -Sy font-tamzen font-ibm-plex-ttf terminus-font termsyn-font

    # 7. Finalize Kernel Initramfs & Bootloader
    sudo xbps-reconfigure -fa
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=void
    grub-mkconfig -o /boot/grub/grub.cfg

    # 8. Sym-link Pipewire Services
    sudo mkdir -p /etc/pipewire/pipewire.conf.d
    sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
    sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/

    echo "=== Stage 2 Complete! Passing control back to Live ISO ==="
    exit 0
fi

# ==============================================================================
# STAGE 1: This block runs on the Live ISO (Default behavior)
# ==============================================================================
echo "=== Starting Stage 1: Live ISO ==="

# 1. Disk Partitioning (Pauses script until you finish menu)
echo "Launching cfdisk to partition /dev/sda..."
read -p "Press Enter to open cfdisk..."
cfdisk /dev/sda

# 2. Formatting & Creating Btrfs Subvolumes
echo "Formatting partitions..."
mkfs.vfat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.btrfs -f /dev/sda3

echo "Creating Btrfs subvolumes..."
# Root subvolumes
mount /dev/sda3 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt

# 3. Mount Everything Correctly for Installation
echo "Mounting target file systems..."
mount -o noatime,compress=zstd,subvol=@ /dev/sda3 /mnt
mkdir -p /mnt/home 
mkdir -p /mnt/boot/efi
mkdir -p /mnt/.snapshots
mount -o noatime,compress=zstd,subvol=@home /dev/sda3 /mnt/home
mount -o noatime,compress=zstd,subvol=@snapshots /dev/sda3 /mnt/.snapshots
mount /dev/sda1 /mnt/boot/efi

# 4. Bootstrap the Base Void Linux System
echo "Bootstrapping base system..."
xbps-install -Sy -R https://repo-de.voidlinux.org/current -r /mnt \
base-system grub-x86_64-efi vim dbus NetworkManager seatd acpid xtools

# 5. Generate FSTAB
xgenfstab -U /mnt > /mnt/etc/fstab

# 6. THE HAND-OFF (Copy script into the new root and execute)
cp "$0" /mnt/tmp/install-void-sway.sh
chmod +x /mnt/tmp/install-void-sway.sh

echo "Entering chroot to execute Stage 2..."
xchroot /mnt /tmp/install-void-sway.sh --stage2

# ==============================================================================
# CLEANUP: Executes back in the Live ISO after Stage 2 finishes
# ==============================================================================
echo "Cleaning up and unmounting file systems..."
umount -R /mnt

echo "========================================================"
echo " SUCCESS! Void Linux + Sway base is installed."
echo " Remove your installation media and type: reboot"
echo "========================================================"


