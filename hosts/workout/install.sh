#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p git
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz

if [ -n "$DEBUG" ]; then
    set -x
fi

set -o errexit
set -o nounset
set -o pipefail

# EFI system partition on a GUID Partition Table is identified by the partition type GUID C12A7328-F81F-11D2-BA4B-00A0C93EC93B
sfdisk /dev/sda << EOF
label: gpt
,1024M,C12A7328-F81F-11D2-BA4B-00A0C93EC93B
;
EOF

mkfs.vfat -n boot /dev/sda1
mkfs.ext4 -L root /dev/sda2

mount /dev/sda2 /mnt

mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

nixos-generate-config --root /mnt

mkdir /mnt/var
pushd /mnt/var
git clone https://github.com/prospo/nixos-config.git
popd

pushd /mnt/etc/nixos
mv configuration.nix configuration.generated.nix
ln -s ../../var/nixos-config/hosts/workout/configuration.nix configuration.nix
mv hardware-configuration.nix /mnt/var/nixos-config/hosts/workout
ln -s ../../var/nixos-config/hosts/workout/hardware-configuration.nix hardware-configuration.nix
popd

nixos-install --no-root-password
