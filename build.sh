#!/bin/zsh

cd /root
apt-get install git live-build cdebootstrap
git clone git://git.kali.org/live-build-config.git build
cd build

cp /root/dots/cfg/isolinux.cfg /root/build/kali-config/common/includes.binary/isolinux/
cp /root/dots/cfg/menu.cfg /root/build/kali-config/common/includes.binary/isolinux/
cp /root/dots/cfg/live.cfg /root/build/kali-config/common/includes.binary/isolinux/
cp /root/dots/cfg/kali.list.chroot /root/build/kali-config/variant-gnome/package-lists/

./build.sh --distribution kali-rolling --variant gnome --verbose
