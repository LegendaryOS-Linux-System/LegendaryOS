#!/usr/bin/env bash

# 1. Definiowanie adresów i nazw plików
url_string="https://github.com/LegendaryOS-Linux-System/LegendaryOS-App/releases/download/v0.1/LegendaryOS-App.rpm"
file_name="LegendaryOS-App.rpm"

# 2. Ustalanie ścieżki docelowej
# BASH_SOURCE[0] pobiera ścieżkę do bieżącego skryptu
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Wyjście z scripts/pre do głównego katalogu, a potem do packages/
target_dir="$(cd "${script_dir}/../.." && pwd)/packages"

# Tworzymy folder 'packages/', jeśli jeszcze nie istnieje
if [ ! -d "$target_dir" ]; then
  mkdir -p "$target_dir"
fi

target_path="${target_dir}/${file_name}"

# 3. Pobieranie pliku z obsługą przekierowań
# Flaga -L w curl automatycznie obsługuje przekierowania (np. na AWS S3)
echo "Rozpoczynam pobieranie pliku RPM..."

if curl -L -o "$target_path" "$url_string"; then
  echo "Sukces! Plik został pobrany do: ${target_path}"
else
  echo "Błąd pobierania pliku z adresu: ${url_string}"
  exit 1
fi
