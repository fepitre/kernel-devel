#!/bin/bash

LOCALDIR="$(readlink -f "$(dirname "$0")")"

if [ -e "$LOCALDIR/version" ]; then
    VERSION="$(cat version)"

    cp "$LOCALDIR/vmlinuz-$VERSION" /boot/
    cp "$LOCALDIR/config-$VERSION" /boot/
    cp -r "$LOCALDIR/lib/modules/$VERSION" /lib/modules/
    dracut --kver "$VERSION" -fv
    grub2-mkconfig -o /boot/grub2/grub.cfg
else
    echo "Cannot find kernel version"
    exit 1
fi
