#!/bin/sh
# Edycja Server: SSH, czas, firewall włączone domyślnie; bez konta autologin.
set -eu
for u in sshd chronyd firewalld; do zenitctl enable "$u.service" || echo "ostrzeżenie: $u" >&2; done
mkdir -p /etc/ssh/sshd_config.d
printf 'PermitRootLogin prohibit-password\nPasswordAuthentication yes\n' > /etc/ssh/sshd_config.d/10-legendaryos.conf
