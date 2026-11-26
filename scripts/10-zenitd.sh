#!/bin/sh
# Włącza jednostki wspólne dla wszystkich edycji (chroot obrazu). Wymaga zenitctl z kroku "zenitd".
set -eu
for u in udevd getty@tty1 legendary-state legendary-triggers legendary-tools dbus polkit NetworkManager elogind; do
  zenitctl enable "$u.service" || echo "ostrzeżenie: nie włączono $u.service" >&2
done
