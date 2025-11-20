#!/usr/bin/env bash
set -euo pipefail

echo "=== NixOS Reproducibility Script ==="

# ---------------------------
# 1. ASK FOR VARIABLES
# ---------------------------

read -p "Is this running from a live ISO? (y/n): " IS_LIVE
read -p "Hostname: " HOSTNAME
read -p "Disk (e.g. sda, nvme0n1): " DISK
read -p "Username: " USERNAME
read -p "Profile (personal/work/etc): " PROFILE

DISK_PATH="/dev/$DISK"

echo ""
echo "Summary:"
echo "Live ISO:     $IS_LIVE"
echo "Hostname:     $HOSTNAME"
echo "Disk:         $DISK_PATH"
echo "User:         $USERNAME"
echo "Profile:      $PROFILE"
echo ""
read -p "Continue? (y/n): " CONT
[[ "$CONT" != "y" ]] && echo "Aborted." && exit 1


# ---------------------------
# 2. IF LIVE ISO
# ---------------------------

if [[ "$IS_LIVE" == "y" ]]; then
    echo "=== Running Live ISO setup ==="
    mkdir -p nixos

    if [[ ! -d nixos ]]; then
        echo "Cloning repository..."
        git clone https://github.com/hameedrezafarrokhi/my-nix/
    else
        echo "Repository already exists, skipping clone."
    fi
fi


# ---------------------------
# 3. INSTALLATION WITH DISKO
# ---------------------------

echo "=== Running Disko Installation ==="

sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
    --flake "nixos#$HOSTNAME" \
    --disk main "$DISK_PATH"


# ---------------------------
# 4. POST INSTALL: REMOUNT DISK
# ---------------------------

echo "=== Post-Install: Unmounting previous mounts ==="

# Unmount anything mounted in /mnt (but not /mnt itself)
for mount_point in $(mount | grep '/mnt' | awk '{print $3}'); do
    if [ "$mount_point" != "/mnt" ]; then
        echo "Unmounting $mount_point"
        sudo umount "$mount_point" || true
    fi
done

echo "=== Mounting target system ==="
# Mount the new root partition at /mnt
sudo mkdir -p /mnt/temp
sudo mount "${DISK_PATH}2" /mnt/temp

# Create /boot and mount the boot partition
sudo mkdir -p /mnt/temp/boot
sudo mount -o umask=077 "${DISK_PATH}1" /mnt/temp/boot


# ---------------------------
# 5. ENTER NIXOS (CHROOT)
# ---------------------------

echo "=== Entering nixos-enter environment ==="
sudo nixos-enter --root /mnt/temp <<EOF
echo "=== Inside nixos-enter ==="

# Change passwords  (NOT WORKING)
echo "Setting passwords..."
passwd root
passwd $USERNAME

# Clone repo inside new system    (Replace On New Boot (Persmission Issues Of Ownership(root owns it in chroot)))
if [[ ! -d /home/$USERNAME/nixos ]]; then
    sudo -u $USERNAME git clone https://github.com/hameedrezafarrokhi/my-nix/ /home/$USERNAME/nixos
fi

# Rebuild system (might show errors — allowed)
cd /home/$USERNAME/nixos
echo "Running nixos-rebuild boot..."
nixos-rebuild boot --flake .#$HOSTNAME || echo "Errors occurred but continuing."

echo "=== nixos-enter phase complete ==="
EOF

echo ""
echo "=== Script Finished Successfully ==="

# echo "=== Unmounting ==="  # Figure Out Passwd First
#
# sudo umount ${DISK_PATH}1
# sudo umount ${DISK_PATH}2
#
# echo "=== Done. Enjoy ==="
