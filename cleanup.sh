#!/bin/bash

# Instructions from https://wiki.t2linux.org/guides/dkms/

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

dkms uninstall -m apple-bce -v 0.1
dkms uninstall -m apple-bce -v 0.2
dkms uninstall -m apple-ibridge -v 0.1
rm -r /usr/src/apple-bce-0.1
rm -r /usr/src/apple-bce-0.2
rm -r /usr/src/apple-ibridge-0.1
rm -r /var/lib/dkms/apple-bce
rm -r /var/lib/dkms/apple-ibridge

# manual cleanup /etc/initramfs-tools/modules
