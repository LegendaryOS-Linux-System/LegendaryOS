#!/bin/bash
# ============================================================
#  set-cosmic-wallpaper.sh
#  Ustawia domyślną tapetę w środowisku graficznym COSMIC
#  (cosmic-bg / com.system76.CosmicBackground)
# ============================================================

set -euo pipefail

WALLPAPER="${1:-/usr/share/wallpapers/Wallpaper.png}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/cosmic/com.system76.CosmicBackground/v1"

# ── Walidacja ────────────────────────────────────────────────
if [ ! -f "$WALLPAPER" ]; then
    echo "BŁĄD: Plik tapety nie istnieje: $WALLPAPER" >&2
    exit 1
fi

case "$WALLPAPER" in
    *.png|*.jpg|*.jpeg|*.webp|*.jxl|*.hdr) ;;
    *)
        echo "OSTRZEŻENIE: Nieznane rozszerzenie pliku. Kontynuuję mimo to." >&2
        ;;
esac

# ── Tworzenie katalogu konfiguracji ──────────────────────────
mkdir -p "$CONFIG_DIR"

# ── Zapis pliku konfiguracyjnego (format RON) ────────────────
# Klucz "all" oznacza tapetę dla wszystkich monitorów.
# ScalingMode: Zoom | Fit | Stretch | Center | Tile
# SamplingMethod: Alphanumeric | Random
# FilterMethod: Lanczos | Linear | Nearest

cat > "$CONFIG_DIR/all" << EOF
(
    output: "all",
    source: Path("$WALLPAPER"),
    filter_by_theme: false,
    rotation_frequency: 900,
    filter_method: Lanczos,
    scaling_mode: Zoom,
    sampling_method: Alphanumeric,
)
EOF

# ── same-on-all: użyj jednej tapety na wszystkich monitorach ─
cat > "$CONFIG_DIR/same-on-all" << EOF
true
EOF

# ── backgrounds: lista wyjść (pusty = używamy "all") ─────────
cat > "$CONFIG_DIR/backgrounds" << EOF
[]
EOF

echo "✓ Tapeta ustawiona: $WALLPAPER"
echo "  Konfiguracja zapisana w: $CONFIG_DIR"

# ── Odśwież działający proces cosmic-bg (jeśli jest) ─────────
if pgrep -x cosmic-bg > /dev/null 2>&1; then
    echo "  Restartowanie cosmic-bg..."
    pkill -x cosmic-bg || true
    # cosmic-session automatycznie ponownie uruchomi cosmic-bg
    echo "  Gotowe — tapeta zostanie zastosowana po chwili."
else
    echo "  Uwaga: Proces cosmic-bg nie jest uruchomiony."
    echo "  Tapeta zostanie zastosowana po następnym logowaniu."
fi
