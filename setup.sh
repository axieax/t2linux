#!/bin/bash

# Instructions from https://wiki.t2linux.org/guides/dkms/

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install BCE (Buffer Copy Engine) module
git clone https://github.com/t2linux/apple-bce-drv /usr/src/apple-bce-0.2
cat > /usr/src/apple-bce-0.2/dkms.conf << EOF
PACKAGE_NAME="apple-bce"
PACKAGE_VERSION="0.2"
MAKE[0]="make KVERSION=$kernelver"
CLEAN="make clean"
BUILT_MODULE_NAME[0]="apple-bce"
DEST_MODULE_LOCATION[0]="/kernel/drivers/misc"
AUTOINSTALL="yes"
EOF
dkms install -m apple-bce -v 0.2

# Install Touchbar and Ambient Light sensor modules
git clone https://github.com/Redecorating/apple-ib-drv /usr/src/apple-ibridge-0.1
dkms install -m apple-ibridge -v 0.1

# Load kernel modules
modprobe apple_bce
modprobe apple_ib_tb
modprobe apple_ib_als

# load on boot
echo apple-bce | tee /etc/modules-load.d/t2.conf

# load on early boot
cat <<EOF >> /etc/initramfs-tools/modules
# Required modules for getting the built-in apple keyboard to work:
snd
snd_pcm
apple-bce
EOF

# Setup Touchbar
bash <(curl -s https://wiki.t2linux.org/tools/touchbar.sh)
echo "1" | touchbar
