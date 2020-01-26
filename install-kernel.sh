#!/bin/bash

LOCALDIR="$(readlink -f "$(dirname "$0")")"

if [ -e "$LOCALDIR/release" ]; then
    RELEASE="$(cat "$LOCALDIR/release")"

    cp "$LOCALDIR/vmlinuz-$RELEASE" /boot/
    cp "$LOCALDIR/config-$RELEASE" /boot/
    cp -r "$LOCALDIR/lib/modules/$RELEASE" /lib/modules/
    dracut --kver "$RELEASE" -fv "/boot/initramfs-$RELEASE.img"
    grub2-mkconfig -o /boot/grub2/grub.cfg
else
    echo "Cannot find kernel version"
    exit 1
fi
