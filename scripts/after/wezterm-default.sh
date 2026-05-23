#!/usr/bin/env bash
# scripts/after/01-wezterm-default.sh
# Ustawia WezTerm jako domyślny terminal w KDE Plasma
set -euo pipefail

echo "==> LegendaryOS: Setting WezTerm as default terminal"

# KDE używa x-terminal-emulator alternatives + własnej konfiguracji
# Ustaw przez update-alternatives jeśli dostępne
if command -v update-alternatives &>/dev/null; then
    update-alternatives --install /usr/bin/x-terminal-emulator \
        x-terminal-emulator /usr/bin/wezterm 50 2>/dev/null || true
    update-alternatives --set x-terminal-emulator /usr/bin/wezterm 2>/dev/null || true
    echo "    update-alternatives: wezterm jako x-terminal-emulator"
fi

# KDE Plasma — domyślny terminal w ustawieniach systemu
# Zapisz do /etc/xdg/plasma-workspace/env/ (ładowane przy starcie KDE)
mkdir -p /etc/xdg/plasma-workspace/env
cat > /etc/xdg/plasma-workspace/env/wezterm-default.sh << 'ENVEOF'
#!/bin/sh
# LegendaryOS — WezTerm jako domyślny terminal KDE
export TERMINAL=wezterm
ENVEOF
chmod +x /etc/xdg/plasma-workspace/env/wezterm-default.sh

# KDE konfiguracja — ustaw w kdeglobals
mkdir -p /etc/xdg
# Dopisz do kdeglobals jeśli istnieje, lub utwórz
if [ -f /etc/xdg/kdeglobals ]; then
    # Usuń stary wpis TerminalApplication jeśli istnieje
    sed -i '/^TerminalApplication=/d' /etc/xdg/kdeglobals
    sed -i '/^TerminalService=/d' /etc/xdg/kdeglobals
fi

# Zapisz konfigurację KDE
cat >> /etc/xdg/kdeglobals << 'KDEEOF'

[General]
TerminalApplication=wezterm
TerminalService=wezterm.desktop
KDEEOF

# Utwórz .desktop entry dla WezTerm jeśli nie istnieje
# (COPR powinno je dostarczyć, ale dla pewności)
if [ ! -f /usr/share/applications/wezterm.desktop ]; then
cat > /usr/share/applications/wezterm.desktop << 'DESKEOF'
[Desktop Entry]
Name=WezTerm
Comment=GPU-accelerated cross-platform terminal emulator
Exec=wezterm start
Icon=org.wezfurlong.wezterm
Type=Application
Categories=System;TerminalEmulator;
Keywords=terminal;shell;prompt;command;
StartupNotify=true
X-KDE-SubstituteUID=false
DESKEOF
fi

# Ustaw TERMINAL w /etc/environment (globalnie)
if ! grep -q '^TERMINAL=' /etc/environment 2>/dev/null; then
    echo 'TERMINAL=wezterm' >> /etc/environment
fi

echo "==> WezTerm: ustawiony jako domyślny termi
nal KDE"
