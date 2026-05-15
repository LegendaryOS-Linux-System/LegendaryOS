#!/bin/bash

# Definicja docelowego katalogu
TARGET_DIR="/usr/share/LegendaryOS/icons"

# Lista plików do pobrania (wersje RAW)
URLS=(
    "https://raw.githubusercontent.com/LegendaryOS-Linux-System/website/main/images/LegendarOS.png"
    "https://raw.githubusercontent.com/LegendaryOS-Linux-System/website/main/images/LegendaryOS-bg.png"
    "https://raw.githubusercontent.com/LegendaryOS-Linux-System/website/main/images/LegendaryOS-notext.png"
    "https://raw.githubusercontent.com/LegendaryOS-Linux-System/website/main/images/LegendaryOS.jpg"
)

# Tworzenie katalogu, jeśli nie istnieje
if [ ! -d "$TARGET_DIR" ]; then
    echo "Tworzenie katalogu $TARGET_DIR..."
    sudo mkdir -p "$TARGET_DIR"
fi

echo "Rozpoczynanie pobierania plików do $TARGET_DIR..."

# Pętla pobierająca pliki
for url in "${URLS[@]}"; do
    echo "Pobieranie: ${url##*/}"
    sudo wget -q --show-progress -O "$TARGET_DIR/${url##*/}" "$url"
done

echo "Gotowe! Pliki znajdują się w $TARGET_DIR"
ls -lh "$TARGET_DIR"
