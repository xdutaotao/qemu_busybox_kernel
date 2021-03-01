#!/bin/sh

usage(){
    [ -n "$1" ] && echo "ERR: $1"
    echo "usage: mkqcow2fs.sh IMG-NAME IMG-SIZE BUSYBOX-PATH"
    exit 0
}

[ "$1" = "-h" -o "$1" = "--help" ] && usage

[ "$#" -eq "3" ] || usage "param lost."

ROOTFS="/tmp/rootfs"
CUR="`pwd`"
IMGDIR="image"
IMGNAME="$1"
IMGSIZE="$2"
BUSYBOX="$3"
IMGPATH="$CUR/$IMGDIR/$IMGNAME"

mkdir -p "$CUR/$IMGDIR"

#raw img
echo "create $IMGPATH.raw ext4 fs."
qemu-img create -f raw $IMGPATH.raw $IMGSIZE
mkfs.ext4 $IMGPATH.raw

#create rootfs mount point
rm -rf $ROOTFS
mkdir -p $ROOTFS

#mount raw ext4 fs to rootfs mnt point
mount -o loop $IMGPATH.raw $ROOTFS

#copy
echo "copy busybox."
cp $BUSYBOX/_install/*  $ROOTFS/ -raf

#temporary dir
echo "create proc sys tmp root dir...."
cd $ROOTFS
mkdir -p proc sys tmp root var mnt etc/init.d /sys/kernel/debug

#dev
echo "prepare dev console,null,tty."
cd $ROOTFS
mkdir -p dev dev/pts
cd $ROOTFS/dev
mknod tty1 c 4 1
mknod tty2 c 4 2
mknod tty3 c 4 3
mknod tty4 c 4 4
mknod console c 5 1
mknod null c 1 3

#fstab
echo "prepare etc/fstab"
cd $ROOTFS
cat > etc/fstab <<EOF
proc /proc proc defaults 0 0
tmpfs /tmp tmpfs defaults 0 0
sysfs /sys sysfs defaults 0 0
devpts /dev/pts devpts defaults 0 0
debugfs /sys/kernel/debug debugfs defaults 0 0
EOF

#rcS etc
echo "prepare etc/init.d/rcS"
cd $ROOTFS
cat > etc/init.d/rcS << EOF
/bin/mount -a
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
EOF

chmod a+x etc/init.d/rcS

#etc inittab
echo "prepare etc/inittab"
cd $ROOTFS
cat > etc/inittab <<EOF
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::askfirst:-/bin/sh
::crtlaltdel:/bin/umount -a -r
EOF

#lib
#cd $ROOTFS
#mkdir -p $ROOTFS/lib64
#cp -arf /lib/x86_64-linux-gnu/* $ROOTFS/lib64/
#rm $ROOTFS/lib/*.a
#strip $ROOTFS/lib/*


#mount mount point
cd /tmp
umount $ROOTFS

#
echo "convert $IMGPATH.raw to $IMGPATH.qcow2"
cd $CUR
qemu-img convert -f raw -O qcow2 $IMGPATH.raw $IMGPATH.qcow2

chmod 777 $IMGPATH.raw $IMGPATH.qcow2

echo "$IMGPATH.qcow2 is ready, enjoy it."

