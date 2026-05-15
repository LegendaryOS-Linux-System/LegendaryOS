#!/usr/bin/env ruby

require 'fileutils'
require 'net/http'

# Konfiguracja
base_dir = "/usr/share/LegendaryOS/tools"
builder_url = "https://github.com/LegendaryOS-Linux-System/LegendaryOS-Builder/releases/download/v0.1.2/legendaryos-builder"
builder_target = "/usr/bin/legendaryos-builder"

repos = {
  "legendary.git" => "https://github.com/LegendaryOS-Linux-System/legendary.git",
  "lpm.git"       => "https://github.com/LegendaryOS-Linux-System/lpm.git"
}

# Sprawdzenie uprawnień roota
if Process.uid != 0
  puts "Błąd: Brak uprawnień roota. Uruchom skrypt przy użyciu sudo."
  exit 1
end

# 1. Zarządzanie repozytoriami git
puts "--- Zarządzanie repozytoriami ---"
FileUtils.mkdir_p(base_dir) unless Dir.exist?(base_dir)

repos.each do |name, url|
  target_path = File.join(base_dir, name)
  
  if Dir.exist?(target_path)
    puts "Repozytorium #{name} już istnieje. Pomijanie..."
  else
    puts "Klonowanie #{name}..."
    if system("git clone #{url} #{target_path}")
      puts "Sukces: Zainstalowano #{name}."
    else
      puts "Błąd: Nie udało się sklonować #{url}."
    end
  end
end

# 2. Pobieranie LegendaryOS Builder
puts "\n--- Instalacja LegendaryOS Builder ---"

puts "Pobieranie: #{builder_url} -> #{builder_target}"
# Używamy curl dla prostoty i obsługi przekierowań (GitHub ich wymaga)
if system("curl -L -o #{builder_target} #{builder_url}")
  puts "Nadawanie uprawnień do wykonywania (chmod a+x)..."
  FileUtils.chmod("a+x", builder_target)
  puts "Sukces: LegendaryOS Builder został zainstalowany."
else
  puts "Błąd: Nie udało się pobrać pliku binarnego."
end

puts "\nProces zakończony."
