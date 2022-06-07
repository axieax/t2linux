#!/bin/bash

# Instructions from https://www.kali.org/docs/usb/usb-persistence-encryption/

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

usb=$1
if [ -z "$usb" ]; then
   echo "Usage: $0 <usb device>"
   exit 1
fi

# create and format an additional partition on the USB drive
fdisk $usb <<< $(printf "n\np\n\n\n\nw")
lsblk

# encrypt the partition with LUKS
cryptsetup --verbose --verify-passphrase luksFormat ${usb}3

# open the encrypted partition
cryptsetup luksOpen ${usb}3 my_usb

# create an ext3 filesystem and label it
mkfs.ext3 -L persistence /dev/mapper/my_usb
e2label /dev/mapper/my_usb persistence

# mount the partition and create your persistence.conf so changes persist across reboots
mkdir -p /mnt/my_usb
mount /dev/mapper/my_usb /mnt/my_usb
echo "/ union" | tee /mnt/my_usb/persistence.conf
umount /dev/mapper/my_usb

# close the encrypted partition
cryptsetup luksClose /dev/mapper/my_usb
