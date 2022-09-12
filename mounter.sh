#!/usr/bin/env bash

apt update
apt install -y httpie
mkdir ./content
mkdir ./content/base
mkdir ./content/upper
mkdir ./content/work
mkdir ./content/ol

http -d https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-live-server-amd64.iso
sudo mount ubuntu-22.04.1-live-server-amd64.iso content/base
mkdir -p content/upper/boot/grub/
cp content/base/boot/grub/grub.cfg content/upper/boot/grub/
cp content/base/boot/grub/loopback.cfg content/upper/boot/grub/
chmod 644 content/upper/boot/grub/grub.cfg
chmod 644 content/upper/boot/grub/loopback.cfg
sed -i -e "s/---/autoinstall ds=nocloud-net\\\;s=http:\/\/10.255.0.1\/cloud-init\/ ---/g" "content/upper/boot/grub/grub.cfg"
sed -i -e "s/timeout=30/timeout=5/g" "content/upper/boot/grub/grub.cfg"
sed -i -e "s/---/autoinstall ds=nocloud-net\\\;s=http:\/\/10.255.0.1\/cloud-init\/ ---/g" "content/upper/boot/grub/loopback.cfg"
sudo mount -t overlay -o lowerdir=content/base,upperdir=content/upper,workdir=content/work non content/ol
ELTORITO=$(xorriso -indev ubuntu-22.04.1-live-server-amd64.iso -report_el_torito as_mkisofs)
xorriso -as mkisofs ${ELTORITO} -o ubuntu-22.04.1-live-server-amd64-autoinstall.iso ./content/ol
sudo umount content/ol
echo "OK"
