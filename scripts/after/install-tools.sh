#!/usr/bin/env ruby

require 'fileutils'
require 'net/http'

# Konfiguracja
base_dir = "/usr/share/LegendaryOS/tools"

# LegendaryOS Builder v0.3
builder_url = "https://github.com/LegendaryOS-Linux-System/LegendaryOS-Builder/releases/download/v0.3/legendaryos-builder"
builder_target = "/usr/bin/legendaryos-builder"

# LegendaryOS Store v0.3
store_url = "https://github.com/LegendaryOS-Linux-System/LegendaryOS-Store/releases/download/v0.3/legendaryos-store"
store_target = "/usr/bin/legendaryos-store"

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

# 2. Pobieranie LegendaryOS Builder (Aktualizacja do v0.3)
puts "\n--- Instalacja/Aktualizacja LegendaryOS Builder ---"
puts "Pobieranie: #{builder_url} -> #{builder_target}"

if system("curl -L -o #{builder_target} #{builder_url}")
  puts "Nadawanie uprawnień do wykonywania (chmod a+x)..."
  FileUtils.chmod("a+x", builder_target)
  puts "Sukces: LegendaryOS Builder został zaktualizowany do wersji v0.3."
else
  puts "Błąd: Nie udało się pobrać pliku binarnego Builder."
end

# 3. Pobieranie nowej rzeczy: LegendaryOS Store
puts "\n--- Instalacja LegendaryOS Store ---"
puts "Pobieranie: #{store_url} -> #{store_target}"

if system("curl -L -o #{store_target} #{store_url}")
  puts "Nadawanie uprawnień do wykonywania (chmod a+x)..."
  FileUtils.chmod("a+x", store_target)
  puts "Sukces: LegendaryOS Store został zainstalowany."
else
  puts "Błąd: Nie udało się pobrać pliku binarnego Store."
end

puts "\nProces zakończony."
