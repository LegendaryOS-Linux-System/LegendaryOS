#!/usr/bin/env bash
# set-wallpaper.sh — ustawia tapetę w KDE Plasma (Fedora)

WALLPAPER="/usr/share/wallpapers/Wallpaper.png"

# --- 1. Sprawdź czy plik istnieje ---
if [[ ! -f "$WALLPAPER" ]]; then
    echo "Błąd: plik '$WALLPAPER' nie istnieje." >&2
    exit 1
fi

# --- 2. Metoda 1: plasma-apply-wallpaperimage (Plasma 5.26+ / Plasma 6) ---
if command -v plasma-apply-wallpaperimage &>/dev/null; then
    plasma-apply-wallpaperimage "$WALLPAPER" && echo "Tapeta ustawiona (plasma-apply-wallpaperimage)." && exit 0
fi

# --- 3. Metoda 2: przez D-Bus / qdbus (działa w działającej sesji Plasma) ---
if command -v qdbus &>/dev/null || command -v qdbus6 &>/dev/null; then
    QDBUS=$(command -v qdbus6 || command -v qdbus)

    "$QDBUS" org.kde.plasmashell /PlasmaShell \
        org.kde.PlasmaShell.evaluateScript "
        var allDesktops = desktops();
        for (var i = 0; i < allDesktops.length; i++) {
            var d = allDesktops[i];
            d.wallpaperPlugin = 'org.kde.image';
            d.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
            d.writeConfig('Image', 'file://$WALLPAPER');
        }
    " && echo "Tapeta ustawiona (qdbus)." && exit 0
fi

# --- 4. Metoda 3: bezpośrednia edycja plasma-org.kde.plasma.desktop-appletsrc ---
PLASMA_CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

if [[ ! -f "$PLASMA_CONFIG" ]]; then
    echo "Błąd: nie znaleziono $PLASMA_CONFIG ani żadnego obsługiwanego narzędzia." >&2
    exit 1
fi

# Znajdź sekcje [Wallpaper][...][General] i ustaw Image
python3 - <<EOF
import configparser, sys

path = "$PLASMA_CONFIG"
cfg = configparser.RawConfigParser()
cfg.optionxform = str          # zachowaj wielkość liter
cfg.read(path)

changed = 0
for section in cfg.sections():
    # Szukamy sekcji typu: Containments\[N\]\\[Wallpaper\]\\[org.kde.image\]\\[General\]
    if "Wallpaper" in section and "General" in section and "org.kde.image" in section:
        cfg.set(section, "Image", "file://$WALLPAPER")
        changed += 1

if changed == 0:
    print("Ostrzeżenie: nie znaleziono sekcji tapety w configu.", file=sys.stderr)
    sys.exit(1)

with open(path, "w") as f:
    cfg.write(f)

print(f"Tapeta ustawiona w {changed} sekcji(ach) pliku konfiguracyjnego.")
print("Uruchom ponownie plasmashell: kquitapp6 plasmashell && kstart plasmashell")
EOF
