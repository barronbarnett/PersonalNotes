#!/bin/bash
sudo losetup -P /dev/loop0 $1
sudo mount /dev/loop0$2 image
sudo mount -t proc proc image/proc
sudo mount -t sysfs sysfs image/sys
sudo mount -o bind /dev image/dev
sudo mount --bind /dev/pts image/dev/pts
sudo cp /usr/bin/qemu-arm-static ./image/usr/bin/

sudo LC_ALL=C chroot ./image 

sudo umount image/dev/pts
sudo umount image/dev
sudo umount image/sys
sudo umount image/proc
sudo umount image
sudo losetup -d /dev/loop0