#!/bin/bash

[ `id -u` -ne "0" ] && {
    echo "Must run as root/sudo."
    exit 0
}

. ./host_network.sh

qemu-system-x86_64 \
    -smp 2 \
    -m 512M \
    -kernel ./linux-4.4.60/arch/x86_64/boot/bzImage \
    -hda "image/busybox_fs.raw" \
    -append "console=ttyS0 root=/dev/sda rootfs=ext4 rw" \
    -nic tap,ifname=tap0,script=no,downscript=no \
    -nic tap,ifname=tap1,script=no,downscript=no \
    -enable-kvm \
    -nographic

    #-nographic \
    #-net tap,ifname=tap0,script=$script_net_up,downscript=no \
    #-enable-kvm \

    #-hda "image/busybox_fs.qcow2" \

    #-drive "format=qcow2,file=image/busybox_fs.qcow2" \


