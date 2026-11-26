#!/bin/sh
# Włącza menedżer logowania i cel domyślny wg edycji. Zmienne ustawia builder (z editions/<id>/edition.hk):
#   LEGENDARY_EDITION, LEGENDARY_DISPLAY_MANAGER (sddm|gdm|lightdm|cosmic-greeter|none), LEGENDARY_DEFAULT_TARGET
set -eu
dm="${LEGENDARY_DISPLAY_MANAGER:-none}"
target="${LEGENDARY_DEFAULT_TARGET:-multi-user}"
if [ "$dm" != none ]; then
  zenitctl enable "$dm.service"
fi
mkdir -p /etc/zenit/system
ln -sf "/usr/lib/zenit/system/$target.target" /etc/zenit/system/default.target
echo "edycja ${LEGENDARY_EDITION:-?}: dm=$dm target=$target"
