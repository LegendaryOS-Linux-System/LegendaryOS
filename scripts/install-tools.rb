#!/usr/bin/env ruby

require 'fileutils'

# Definicja ścieżek
repo_url = "https://github.com/LegendaryOS-Linux-System/legendary.git"
target_dir = "/usr/share/LegendaryOS/tools/legendary.git"

# Tworzenie struktury katalogów, jeśli nie istnieje
# Wymaga uprawnień roota dla zapisu w /usr/share
begin
  FileUtils.mkdir_p(File.dirname(target_dir))
rescue Errno::EACCES
  puts "Błąd: Brak uprawnień do zapisu w #{target_dir}. Uruchom skrypt z sudo."
  exit 1
end

# Klonowanie repozytorium
puts "Klonowanie repozytorium do #{target_dir}..."

if system("git clone #{repo_url} #{target_dir}")
  puts "Sukces: Repozytorium zostało sklonowane."
else
  puts "Błąd: Nie udało się sklonować repozytorium."
  exit 1
end
