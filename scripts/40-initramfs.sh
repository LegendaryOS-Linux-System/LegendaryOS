#!/bin/sh
# Initramfs z modułami dmsquash-live (ISO live) i composefs/overlay (system niezmienny).
set -eu
for k in /usr/lib/modules/*; do
  v=$(basename "$k")
  depmod -a "$v"
  dracut --no-hostonly --add 'dmsquash-live' -f "$k/initramfs.img" "$v"
done
