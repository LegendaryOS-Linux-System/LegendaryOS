#!/usr/bin/env ruby

require 'fileutils'

# Konfiguracja repozytoriów
base_dir = "/usr/share/LegendaryOS/tools"
repos = {
  "legendary.git" => "https://github.com/LegendaryOS-Linux-System/legendary.git",
  "lpm.git"       => "https://github.com/LegendaryOS-Linux-System/lpm.git"
}

# Sprawdzenie uprawnień roota przed rozpoczęciem
if Process.uid != 0
  puts "Błąd: Brak uprawnień roota. Uruchom skrypt przy użyciu sudo."
  exit 1
end

# Tworzenie głównego katalogu narzędzi
begin
  FileUtils.mkdir_p(base_dir)
rescue Errno::EACCES => e
  puts "Błąd krytyczny: #{e.message}"
  exit 1
end

repos.each do |name, url|
  target_path = File.join(base_dir, name)
  
  if Dir.exist?(target_path)
    puts "Repozytorium #{name} już istnieje w #{target_path}. Pomijanie..."
    next
  end

  puts "Klonowanie #{name} do #{target_path}..."
  
  if system("git clone #{url} #{target_path}")
    puts "Sukces: #{name} zostało zainstalowane."
  else
    puts "Błąd: Nie udało się sklonować #{url}."
  end
end

puts "\nProces zakończony."
