#File Image Manipulation
This file is a walk through of different ways to work with .img files that contain Linux images.  The primary example here will be for the Raspberry Pi, however this can also be applied to Yocto Images.

## Getting the image to be represented as a block device
You can make use of loop back devices to load the .img file into the /dev tree.  This presents the different partions of the .img file as different devices.

> kbuntu:~/rpi$ sudo losetup -P /dev/loop0 _filename.img_

> kbuntu:~/rpi$ sudo losetup -P /dev/loop0 
> 2018-10-09-raspbian-stretch.img  
> kbuntu:~/rpi$ ls -la /dev/loop0*  
> brw-rw---- 1 root disk   7, 0 Jan 30 20:07 /dev/loop0  
> brw-rw---- 1 root disk 259, 0 Jan 30 20:07 /dev/loop0p1  
> brw-rw---- 1 root disk 259, 1 Jan 30 20:07 /dev/loop0p2  

For example the Raspberry Pi image has two different partitions. The first is a FAT32 partition which contains /boot. The second contains the root file system.

You can see each of the partions as _/dev/loop0p1_ and _/dev/loop0p2_.

## Mounting the file systems

Now that we have them as block devices in our device tree we can treat them just like any other block device.  To mount the file systems we just call _mount_

> kbuntu:~/rpi$ sudo mount /dev/loop0p1 boot/  
> kbuntu:~/rpi$ cd boot/  
> kbuntu:~/rpi/boot$ ls  
> bcm2708-rpi-0-w.dtb     bcm2709-rpi-2-b.dtb       bootcode.bin   fixup_cd.dat  issue.txt         LICENSE.oracle  start.elf  
> bcm2708-rpi-b.dtb       bcm2710-rpi-3-b.dtb       cmdline.txt    fixup.dat     kernel7.img       overlays        start_x.elf  
> bcm2708-rpi-b-plus.dtb  bcm2710-rpi-3-b-plus.dtb  config.txt     fixup_db.dat  kernel.img        start_cd.elf  
> bcm2708-rpi-cm.dtb      bcm2710-rpi-cm3.dtb       COPYING.linux  fixup_x.dat   LICENCE.broadcom  start_db.elf  

_Note_: Mounting the boot partition is largely optional and only necessary if you need to customize the files there. It is unnecessary for the rest of this tutorial.

> kbuntu:~/rpi$ sudo mount /dev/loop0p2 image/  
> kbuntu:~/rpi$ cd image/  
> kbuntu:~/rpi/image$ ls  
> bin  boot  debootstrap  dev  etc  home  lib  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var  
> kbuntu:~/rpi/image$  

So now we can move and alter files in the .img without burning it to an SD card.  But can we do anything else?

## Using Qemu Static to run the image in CHROOT
First make sure you have qemu-static installed.

> kbuntu:~/rpi$ sudo apt-get install qemu qemu-user-static binfmt-support

Now that we have qemu static installed we need to copy it into the /usr/bin of the image that has been mounted.

> kbuntu:~/rpi$ sudo cp /usr/bin/qemu-arm-static ./image/usr/bin/

Now before we attempt to CHROOT the file system we need to map a bunch of system level directories.

> kbuntu:~/rpi$ sudo mount -t proc proc image/proc  
> kbuntu:~/rpi$ sudo mount -t sysfs sysfs image/sys  
> kbuntu:~/rpi$ sudo mount -o bind /dev image/dev  
> kbuntu:~/rpi$ sudo mount --bind /dev/pts image/dev/pts  

We are now ready to run the chroot:

> kbuntu:~/rpi$ sudo LC_ALL=C chroot ./image
> root@kbuntu:/# 

You can now install packages and do other configuration tasks.

## Cleanup when done
Now that you're done with your image you need to cleanup. Unwind it all in reverse.

> root@kbuntu:/# exit
> kbuntu:~/rpi$ sudo umount image/dev/pts  
> kbuntu:~/rpi$ sudo umount image/dev  
> kbuntu:~/rpi$ sudo umount image/sys  
> kbuntu:~/rpi$ sudo umount image/proc  
> kbuntu:~/rpi$ sudo umount image
> kbuntu:~/rpi$ sudo umount boot
> kbuntu:~/rpi$ sudo losetup -d /dev/loop0

## Note, diskspace is limited
You can expand the .img file so you have more space to work with as the .img is usually shrunk to the bare minimum necessary.

This is a three part process.

### First you need to lengthen the .img

This is because the file is treated as a fixed asset by the loop interface.

> kubuntu:~/rpi$ truncate -s +_size_ _imagefilename.img_

Below for example adds 1 gigabyte to the rpi.img file.
> kubuntu:~/rpi$ truncate -s +1G rpi.img

Now mount the image .img file using the loop interface again.

> kubuntu:~/rpi$ sudo losetup -P /dev/loop0 _filename.img_

### Resize the partition
After lengthening the file you need to resize the partition so it takes advantage of the new space in the file.

> kbuntu:~/rpi$ sudo fdisk /dev/loop0  
>  
> Welcome to fdisk (util-linux 2.31.1).
> Changes will remain in memory only, until you decide to write them.  
> Be careful before using the write command.  

First we need to print out the existing partition information from fdisk.
>  
> Command (m for help): p  
> Disk /dev/loop0: 4.9 GiB, 5209325568 bytes, 10174464 sectors  
> Units: sectors of 1 * 512 = 512 bytes  
> Sector size (logical/physical): 512 bytes / 512 bytes  
> I/O size (minimum/optimal): 512 bytes / 512 bytes  
> Disklabel type: dos  
> Disk identifier: 0x2ee8b6fe  
>  
> Device       Boot Start      End  Sectors  Size Id Type  
> /dev/loop0p1       8192    97890    89699 43.8M  c W95 FAT32 (LBA)  
> /dev/loop0p2      98304 10174463 10076160  4.8G 83 Linux  

Now that we have this information we need to delete the last partition that we are resizing.

> Command (m for help): d  
> Partition number (1,2, default 2): 2  
>  
> Partition 2 has been deleted.  

Now we need to recreate the partition with the new size.  Note the starting sector needs to match the starting sector printed out above.  In this example _98304_.
 
> Command (m for help): n  
> Partition type
> >   p   primary (1 primary, 0 extended, 3 free)  
> >   e   extended (container for logical partitions)
>  
> Select (default p): p  
> Partition number (2-4, default 2): 2  
> First sector (2048-10174463, default 2048): _98304_  
> Last sector, +sectors or +size{K,M,G,T,P} (98304-10174463, default 10174463):  
>  
> Created a new partition 2 of type 'Linux' and of size 4.8 GiB.  
> Partition #2 contains a ext4 signature.  
>  
> Do you want to remove the signature? [Y]es/[N]o: n  

Verify that the starting sector is correct and then write it.
 
> Command (m for help): p  
> 
> Disk /dev/loop0: 4.9 GiB, 5209325568 bytes, 10174464 sectors  
> Units: sectors of 1 * 512 = 512 bytes  
> Sector size (logical/physical): 512 bytes / 512 bytes  
> I/O size (minimum/optimal): 512 bytes / 512 bytes  
> Disklabel type: dos  
> Disk identifier: 0x2ee8b6fe  
>  
> Device       Boot Start      End  Sectors  Size Id Type  
> /dev/loop0p1       8192    97890    89699 43.8M  c W95 FAT32 (LBA)  
> /dev/loop0p2      98304 10174463 10076160  4.8G 83 Linux  
>  
> Command (m for help): w  
> The partition table has been altered.  
> Calling ioctl() to re-read partition table.  
> Syncing disks.  

### Resize the file system
After resizing the partition you need to resize the file system.

> kbuntu:~/rpi$ sudo e2fsck -f /dev/loop0p2  
> e2fsck 1.44.1 (24-Mar-2018)  
> Pass 1: Checking inodes, blocks, and sizes  
> Pass 2: Checking directory structure  
> Pass 3: Checking directory connectivity  
> Pass 4: Checking reference counts  
> Pass 5: Checking group summary information  
> rootfs: 118177/249488 files (0.1% non-contiguous), 866815/997376 blocks  
> barronb@barnba-dev-kbuntu:~/rpi$ sudo resize2fs /dev/loop0p2 
> resize2fs 1.44.1 (24-Mar-2018)  
> Resizing the filesystem on /dev/loop0p2 to 1259520 (4k) blocks.  
> The filesystem on /dev/loop0p2 is now 1259520 (4k) blocks long.  

barronb@barnba-dev-kbuntu:~/rpi$ 

### Cheat and combine the last two parts
Point gparted at the loop0 interface.

> kubuntu:~/rpi$: sudo gparted /dev/loop0

## Bash script to automate loading a .img

Below is a bash script that automates mounting the image, copying the arm qemu binary, and then doing a chroot into the image.  When you're done it automatically cleans everything up.

Usage:
> kubuntu:~/rpi$ image_root.sh 2018-10-09-raspbian-stretch.img p2
``` Bash
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
```
