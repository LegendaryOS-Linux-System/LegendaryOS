#!/usr/bin/env bash

# Konfiguracja
base_dir="/usr/share/LegendaryOS/tools"

# LegendaryOS Builder v0.5
builder_url="https://github.com/LegendaryOS-Linux-System/LegendaryOS-Builder/releases/download/v0.5/legendaryos-builder"
builder_target="/usr/bin/legendaryos-builder"

# LegendaryOS Store v0.3
store_url="https://github.com/LegendaryOS-Linux-System/LegendaryOS-Store/releases/download/v0.3/legendaryos-store"
store_target="/usr/bin/legendaryos-store"

# Definicja repozytoriów w tablicy asocjacyjnej
declare -A repos
repos=(
  ["legendary.git"]="https://github.com/LegendaryOS-Linux-System/legendary.git"
  ["lpm.git"]="https://github.com/LegendaryOS-Linux-System/lpm.git"
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
  echo "Sukces: LegendaryOS Builder został zaktualizowany do wersji v0.3."
else
  echo "Błąd: Nie udało się pobrać pliku binarnego Builder."
fi

# 3. Pobieranie nowej rzeczy: LegendaryOS Store
echo -e "\n--- Instalacja LegendaryOS Store ---"
echo "Pobieranie: ${store_url} -> ${store_target}"

if curl -L -o "$store_target" "$store_url"; then
  echo "Nadawanie uprawnień do wykonywania (chmod a+x)..."
  chmod a+x "$store_target"
  echo "Sukces: LegendaryOS Store został zainstalowany."
else
  echo "Błąd: Nie udało się pobrać pliku binarnego Store."
fi

echo -e "\nProces zakończony."
