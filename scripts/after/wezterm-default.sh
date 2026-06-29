#!/usr/bin/env bash
# scripts/after/wezterm-default.sh
# Ustawia WezTerm jako domyślny terminal w COSMIC DE
set -euo pipefail

echo "==> LegendaryOS: Setting WezTerm as default terminal"

# update-alternatives — ustawia x-terminal-emulator system-wide
if command -v update-alternatives &>/dev/null; then
    update-alternatives --install /usr/bin/x-terminal-emulator \
        x-terminal-emulator /usr/bin/wezterm 50 2>/dev/null || true
    update-alternatives --set x-terminal-emulator /usr/bin/wezterm 2>/dev/null || true
    echo "    update-alternatives: wezterm jako x-terminal-emulator"
fi

# Ustaw TERMINAL i TERM globalnie
if ! grep -q '^TERMINAL=' /etc/environment 2>/dev/null; then
    echo 'TERMINAL=wezterm' >> /etc/environment
fi

# COSMIC DE — konfiguracja domyślnego terminala
# COSMIC przechowuje konfigurację w RON (Rust Object Notation) w ~/.config/cosmic/
# Ustawiamy domyślny terminal przez plik konfiguracyjny cosmic-settings-daemon
COSMIC_DEFAULT_APPS_DIR="/etc/cosmic/com.system76.CosmicSettings.Shortcuts"
mkdir -p /etc/cosmic

# Ustaw domyślny terminal dla COSMIC (com.system76.CosmicSettings)
COSMIC_APPS_CONFIG="/etc/cosmic/com.system76.CosmicTerminal"
mkdir -p "$COSMIC_APPS_CONFIG"

# cosmic-greeter i COSMIC respektują zmienną TERMINAL oraz .desktop association
# Utwórz .desktop entry dla WezTerm jeśli nie istnieje
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
X-COSMIC-Default-Terminal=true
DESKEOF
fi

# Ustaw jako domyślną aplikację terminalową przez XDG MIME
if command -v xdg-mime &>/dev/null; then
    xdg-mime default wezterm.desktop x-scheme-handler/terminal 2>/dev/null || true
fi

# Plik środowiskowy ładowany przez COSMIC session
mkdir -p /etc/cosmic/env
cat > /etc/cosmic/env/wezterm.sh << 'ENVEOF'
#!/bin/sh
# LegendaryOS — WezTerm jako domyślny terminal
export TERMINAL=wezterm
ENVEOF
chmod +x /etc/cosmic/env/wezterm.sh

echo "==> WezTerm: ustawiony jako domyślny terminal COSMIC"
