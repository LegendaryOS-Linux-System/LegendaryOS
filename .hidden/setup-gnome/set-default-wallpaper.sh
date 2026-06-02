#!/bin/bash
# ============================================================
#  set-gnome-wallpaper.sh
#  Ustawia domyślną tapetę w środowisku graficznym GNOME
#  (przez gsettings / org.gnome.desktop.background)
# ============================================================

set -euo pipefail

WALLPAPER="${1:-/usr/share/wallpapers/Wallpaper.png}"

# ── Walidacja ────────────────────────────────────────────────
if [ ! -f "$WALLPAPER" ]; then
    echo "BŁĄD: Plik tapety nie istnieje: $WALLPAPER" >&2
    exit 1
fi

# gsettings wymaga URI w formacie file://
WALLPAPER_URI="file://$WALLPAPER"

# ── Upewnij się, że gsettings jest dostępne ──────────────────
if ! command -v gsettings > /dev/null 2>&1; then
    echo "BŁĄD: Polecenie 'gsettings' nie zostało znalezione." >&2
    echo "       Zainstaluj pakiet 'dconf-gsettings-backend' lub 'gsettings-desktop-schemas'." >&2
    exit 1
fi

# ── Wymagane zmienne środowiskowe dla sesji D-Bus ────────────
# (potrzebne gdy skrypt uruchamiany jest spoza sesji graficznej,
#  np. z crona lub przez SSH)
export DISPLAY="${DISPLAY:-:0}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"

# ── Wykryj aktywny motyw kolorystyczny (jasny / ciemny) ──────
COLOR_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "'default'")

# ── Ustaw tapetę ─────────────────────────────────────────────
# GNOME 42+ rozróżnia tapety dla trybu jasnego i ciemnego.
# Ustawiamy obie wartości, żeby tapeta działała niezależnie od motywu.

gsettings set org.gnome.desktop.background picture-uri       "$WALLPAPER_URI"
gsettings set org.gnome.desktop.background picture-uri-dark  "$WALLPAPER_URI"

# Tryb dopasowania: none | wallpaper | centered | scaled | stretched | zoom | spanned
gsettings set org.gnome.desktop.background picture-options   "zoom"

echo "✓ Tapeta ustawiona: $WALLPAPER"
echo "  Tryb kolorystyczny sesji: $COLOR_SCHEME"
echo "  URI: $WALLPAPER_URI"
