#! /usr/bin/zsh
apt update
apt install linux-image-4.13.0-kali1-amd64 linux-image-amd64
apt install linux-headers-4.13.0-kali1-common linux-headers-4.13.0-kali1-all-amd64 linux-headers-4.13.0-kali1-amd64 linux-headers-amd64
apt install broadcom-sta-dkms dkms
apt install kali-linux-wireless

# Installs the broadcom-wl kernel module with DKMS
# Tested under Fedora 23, will likely work with other versions/distros
# Author: Steven Mirabito <smirabito@csh.rit.edu>

# Create a work directory
mkdir -p /tmp/broadcom
cd /tmp/broadcom

# Download the module from Broadcom (http://www.broadcom.com/support/?gid=1) manually to ~/Downloads
# https://docs.broadcom.com/docs/12358410

# Download some support files from the Arch package manually ~/Downloads
# https://aur.archlinux.org/cgit/aur.git/snapshot/broadcom-wl-dkms.tar.gz

cp /root/kali/wl/broadcom-wl-dkms.tar.gz /tmp/broadcom/
cp /root/kali/wl/hybrid-v35_64-nodebug-pcoem-6_30_223_271.tar.gz /tmp/broadcom/broadcom.tar.gz


# Untar the archives
tar -zxvf broadcom.tar.gz
tar -zxvf broadcom-wl-dkms.tar.gz

# Patch the module
sed -i -e "/BRCM_WLAN_IFNAME/s:eth:wlan:" src/wl/sys/wl_linux.c

# Add the module version number to the dkms config file
sed -e "s/@PACKAGE_VERSION@/6.30.223.271/" broadcom-wl-dkms/dkms.conf.in > dkms.conf

# Create the destination directory
mkdir -p /usr/src/broadcom-wl-6.30.223.271

# Move files into place
cp -RL src lib Makefile dkms.conf /usr/src/broadcom-wl-6.30.223.271

# Fix permissions and link the license in the appropriate place
chmod a-x "/usr/src/broadcom-wl-6.30.223.271/lib/LICENSE.txt"
mkdir -p "/usr/share/licenses/broadcom-wl-dkms"
ln -rs "/usr/src/broadcom-wl-6.30.223.271/lib/LICENSE.txt" "/usr/share/licenses/broadcom-wl-dkms/LICENSE"

# Install the modprobe config to blacklist the other Broadcom modules
install -D -m 644 broadcom-wl-dkms/broadcom-wl-dkms.conf "/etc/modprobe.d/broadcom-wl-dkms.conf"

# Install and build the module
dkms add -m broadcom-wl -v 6.30.223.271
cp -RL /tmp/broadcom/broadcom-wl-dkms /var/lib/dkms/broadcom-wl/6.30.223.271/source/patches
dkms install -m broadcom-wl -v 6.30.223.271

# Activate the module
rmmod b43 b43legacy ssb bcm43xx brcm80211 brcmfmac brcmsmac bcma wl
modprobe wl

# Clean up
cd ~
rm -rf /tmp/broadcom
