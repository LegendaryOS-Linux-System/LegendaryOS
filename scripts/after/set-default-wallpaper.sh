#!/usr/bin/env bash
# set-default-wallpaper.sh — ustawia tapetę w COSMIC DE (Fedora)

WALLPAPER="/usr/share/wallpapers/Wallpaper.png"

# --- 1. Sprawdź czy plik istnieje ---
if [[ ! -f "$WALLPAPER" ]]; then
    echo "Błąd: plik '$WALLPAPER' nie istnieje." >&2
    exit 1
fi

# --- 2. Metoda 1: cosmic-bg — natywne narzędzie COSMIC do tapet ---
# cosmic-bg przechowuje konfigurację w RON w ~/.config/cosmic/com.system76.CosmicBg/
# Ustawiamy tapetę system-wide przez /etc/skel (nowi użytkownicy)
# oraz przez aktywną sesję jeśli dostępna

COSMIC_BG_SYSTEM_DIR="/etc/skel/.config/cosmic/com.system76.CosmicBg/v1"
mkdir -p "$COSMIC_BG_SYSTEM_DIR"

cat > "$COSMIC_BG_SYSTEM_DIR/backgrounds" << RONEOF
(
    backgrounds: [
        Output(
            output: "all",
            source: Path("$WALLPAPER"),
            filter_by_theme: false,
            filter_method: Lanczos,
            sampling_method: Alphanumeric,
            rotation_frequency: 0,
        ),
    ],
    current_image: Path("$WALLPAPER"),
)
RONEOF

echo "Tapeta ustawiona dla nowych użytkowników (skel)."

# --- 3. Metoda 2: Dla aktualnie zalogowanego użytkownika przez COSMIC D-Bus ---
# COSMIC udostępnia D-Bus interfejs com.system76.CosmicBg
if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    if command -v busctl &>/dev/null; then
        busctl --user call com.system76.CosmicBg \
            /com/system76/CosmicBg \
            com.system76.CosmicBg \
            SetBackground "ss" "all" "file://$WALLPAPER" 2>/dev/null \
        && echo "Tapeta ustawiona przez D-Bus (busctl)." \
        || echo "Ostrzeżenie: D-Bus niedostępny, tapeta zostanie ustawiona przy następnym logowaniu."
    fi
else
    echo "Brak sesji D-Bus — tapeta zostanie ustawiona przy następnym logowaniu użytkownika."
fi

# --- 4. Ustaw domyślną konfigurację cosmic-bg przez /etc/cosmic ---
COSMIC_ETC_BG="/etc/cosmic/com.system76.CosmicBg/v1"
mkdir -p "$COSMIC_ETC_BG"

cp "$COSMIC_BG_SYSTEM_DIR/backgrounds" "$COSMIC_ETC_BG/backgrounds"
echo "Tapeta ustawiona w /etc/cosmic (system-wide default)."
