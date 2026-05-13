#!/usr/bin/env bash
set -euo pipefail

echo "==> LegendaryOS: Gaming tweaks"

# ── vm.max_map_count ──────────────────────────────────────────────────────────
# Steam i wiele gier Windows wymaga wyższego limitu memory mappings.
# Domyślnie Fedora ma 65530 — Steam zaleca 2147483642.
cat > /etc/sysctl.d/99-legendaryos-gaming.conf << 'SYSCTL'
# LegendaryOS gaming tweaks

# Wymagane przez Steam i wiele gier
vm.max_map_count = 2147483642

# Zmniejsza latencję dźwięku
dev.hid.poll_interval = 4

# Sieciowe optymalizacje dla gamingu online
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 8192
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
SYSCTL

echo "    vm.max_map_count = 2147483642 — OK"

# ── GameMode — limity ─────────────────────────────────────────────────────────
# Pozwala GameMode na podnoszenie priorytetu procesu gry
cat > /etc/security/limits.d/99-gamemode.conf << 'LIMITS'
@gamemode   -   nice    -10
@gamemode   -   rtprio   5
LIMITS

echo "    GameMode limits — OK"

# ── Udev — kontrolery ─────────────────────────────────────────────────────────
# Dodaj użytkownika do grupy input żeby kontrolery działały bez sudo
cat > /etc/udev/rules.d/99-input-devices.rules << 'UDEV'
# Xbox controllers
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", MODE="0664", GROUP="input"
# PlayStation controllers
SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", MODE="0664", GROUP="input"
# 8BitDo
SUBSYSTEM=="usb", ATTRS{idVendor}=="2dc8", MODE="0664", GROUP="input"
# Generic HID gamepads
KERNEL=="js[0-9]*", MODE="0664", GROUP="input"
KERNEL=="event[0-9]*", SUBSYSTEM=="input", MODE="0664", GROUP="input"
UDEV

echo "    Udev gamepad rules — OK"

# ── Flatpak setup — Flathub ────────────────────────────────────────────────────
# Dodaj Flathub jako źródło Flatpak (potrzebne do VS Code, Spotify, Discord itp.)
if command -v flatpak &>/dev/null; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "    Flathub remote — OK"
fi

echo "==> Gaming tweaks done"
