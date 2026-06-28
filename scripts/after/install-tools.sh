#!/usr/bin/env bash

# Konfiguracja
base_dir="/usr/share/LegendaryOS/tools"

# LegendaryOS Builder v0.5.1
builder_url="https://github.com/LegendaryOS-Linux-System/LegendaryOS-Builder/releases/download/v0.5.1/legendaryos-builder"
builder_target="/usr/bin/legendaryos-builder"

# Definicja repozytoriów w tablicy asocjacyjnej
declare -A repos
repos=(
  ["legendary.git"]="https://github.com/LegendaryOS-Linux-System/legendary.git"
  ["lpm.git"]="https://github.com/LegendaryOS-Linux-System/lpm.git"
  ["LegendaryOS-Game.git"]="https://github.com/LegendaryOS-Linux-System/LegendaryOS-Game.git"
)

# Sprawdzenie uprawnień roota
if [ "$EUID" -ne 0 ]; then
  echo "Błąd: Brak uprawnień roota. Uruchom skrypt przy użyciu sudo."
  exit 1
fi

# 1. Zarządzanie repozytoriami git
echo "--- Zarządzanie repozytoriami ---"
if [ ! -d "$base_dir" ]; then
  mkdir -p "$base_dir"
fi

for name in "${!repos[@]}"; do
  url="${repos[$name]}"
  target_path="${base_dir}/${name}"

  if [ -d "$target_path" ]; then
    echo "Repozytorium ${name} już istnieje. Pomijanie..."
  else
    echo "Klonowanie ${name}..."
    if git clone "$url" "$target_path"; then
      echo "Sukces: Zainstalowano ${name}."
    else
      echo "Błąd: Nie udało się sklonować ${url}."
    fi
  fi
done

# 2. Pobieranie LegendaryOS Builder (Aktualizacja do v0.3)
echo -e "\n--- Instalacja/Aktualizacja LegendaryOS Builder ---"
echo "Pobieranie: ${builder_url} -> ${builder_target}"

if curl -L -o "$builder_target" "$builder_url"; then
  echo "Nadawanie uprawnień do wykonywania (chmod a+x)..."
  chmod a+x "$builder_target"
  echo "Sukces: LegendaryOS Builder został zaktualizowany do wersji v0.5.1."
else
  echo "Błąd: Nie udało się pobrać pliku binarnego Builder."
fi

echo -e "\nProces zakończony."
