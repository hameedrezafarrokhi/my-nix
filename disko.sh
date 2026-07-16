#!/usr/bin/env bash
set -euo pipefail

echo "=== NixOS Reproducibility Script ==="
echo "===================================="
echo "=                                  ="
echo "=          Pre Install             ="
echo "=                                  ="
echo "===================================="

read -p "Hostname: " HOSTNAME
read -p "Disk (e.g. sda, nvme0n1): " DISK
read -p "Username: " USERNAME
read -p "Git URL: " GITURL
DISK_PATH="/dev/$DISK"

echo ""
echo "Summary:"
echo "Hostname:     $HOSTNAME"
echo "Disk:         $DISK_PATH"
echo "User:         $USERNAME"
echo "Git:          $GITURL"
echo ""
read -p "Continue? (y/n): " CONT
[[ "$CONT" != "y" ]] && echo "Aborted." && exit 1

export HOSTNAME
export USERNAME
export DISK_PATH

echo "===================================="
echo "=                                  ="
echo "=         Install Phase            ="
echo "=                                  ="
echo "===================================="
echo "==== Running Disko Installation ===="

sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
    --flake .#"$HOSTNAME" \
    --disk "$HOSTNAME" "$DISK_PATH" || true

echo "===================================="
echo "=                                  ="
echo "=          Post Install            ="
echo "=                                  ="
echo "===================================="
set +e +u
set +o pipefail

echo "==== Unmounting previous mounts ===="
for mount_point in $(mount | grep '/mnt' | awk '{print $3}'); do
    if [ "$mount_point" != "/mnt" ]; then
        echo "Unmounting $mount_point"
        sudo umount "$mount_point" || true
    fi
done
echo "====   Mounting target system   ===="
sudo mkdir -p /mnt/temp/boot
sudo mount "${DISK_PATH}2" /mnt/temp
sudo mount -o umask=077 "${DISK_PATH}1" /mnt/temp/boot

echo "====   Nixos-Enter Environment  ===="
sudo nixos-enter --root /mnt/temp -- bash -c "
  passwd root
  passwd '$USERNAME'
"
sudo nixos-enter --root /mnt/temp -- runuser -u "$USERNAME" -- git clone "$GITURL" /home/"$USERNAME"/nixos
sudo nixos-enter --root /mnt/temp -- bash -c "nixos-rebuild boot --flake /home/'$USERNAME'/nixos#'$HOSTNAME' || echo 'Errors occurred but continuing.' "

echo ""
echo "=== Script Finished Successfully ==="
echo "====        Unmounting          ===="
sudo umount "${DISK_PATH}1"
sudo umount "${DISK_PATH}2"
echo "====   Done. Ready For Reboot   ===="
