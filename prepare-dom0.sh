#!/bin/bash

REMOTE_CONSOLE_IP="192.168.0.72"

# lscpi -v
ETHERNET_PCI_ID="0000:1f:00.0"
ETHERNET_DRIVER="igb"
ETHERNET_NAME="enp31s0"

# force remove assignable ethernet card
xl pci-assignable-add "${ETHERNET_PCI_ID}" >/dev/null 2>&1 || true
xl pci-assignable-remove "${ETHERNET_PCI_ID}" >/dev/null 2>&1

# force reload driver
rmmod "$ETHERNET_DRIVER" >/dev/null 2>&1
modprobe "$ETHERNET_DRIVER"

# dhcp
dhclient "$ETHERNET_NAME"

# kernel debug messages
dmesg -n 8

# load netconsole (sport is 6665, dport is 6666) 
# on remote ip use nc as: nc -l -u 6666
# don't forget to allow 6666 INPUT udp port
modprobe netconsole netconsole="@/${ETHERNET_NAME},@${REMOTE_CONSOLE_IP}/"

# you can test by doing: echo test /dev/kmesg
