#!/usr/bin/env ruby

# Definiujemy ścieżkę do binarki, aby kod był czytelny
BUILDER_BIN = "/usr/bin/legendaryos-builder"

# Ścieżki plików docelowych
WALLPAPER_SCRIPT = "scripts/after/set-default-wallpaper.sh"
CONFIG_TOML      = "config.toml"

# Ścieżki źródłowe dla każdego środowiska
SETUPS = {
  "gnome"  => ".hidden/setup-gnome",
  "cosmic" => ".hidden/setup-cosmic",
}

def apply_desktop_setup(desktop)
  source_dir = SETUPS[desktop]

  wallpaper_src = "#{source_dir}/set-default-wallpaper.sh"
  config_src    = "#{source_dir}/config.toml"

  # Walidacja — sprawdzamy czy pliki źródłowe istnieją
  [wallpaper_src, config_src].each do |path|
    unless File.exist?(path)
      puts "BŁĄD: Brak pliku źródłowego: #{path}"
      exit 1
    end
  end

  puts "Stosowanie konfiguracji dla środowiska: #{desktop}..."

  # Nadpisz skrypt tapety
  FileUtils.cp(wallpaper_src, WALLPAPER_SCRIPT)
  puts "  ✓ #{WALLPAPER_SCRIPT} <- #{wallpaper_src}"

  # Nadpisz config.toml obok tego skryptu (katalog główny)
  FileUtils.cp(config_src, CONFIG_TOML)
  puts "  ✓ #{CONFIG_TOML} <- #{config_src}"
end

# ── Główna logika ─────────────────────────────────────────────

require "fileutils"

command = ARGV[0]

case command
when "clean"
  # Wywołanie dla: ruby build.rb clean
  puts "Uruchamianie czyszczenia..."
  success = system("sudo #{BUILDER_BIN} clean --all")

when "--gnome", "--cosmic"
  # Wywołanie dla: ruby build.rb --gnome
  #                ruby build.rb --cosmic
  desktop = command.delete_prefix("--")
  apply_desktop_setup(desktop)
  puts "Uruchamianie budowania wersji release..."
  success = system("sudo #{BUILDER_BIN} build --release")

when nil
  # Wywołanie bez argumentów: ruby build.rb
  puts "Uruchamianie budowania wersji release..."
  success = system("sudo #{BUILDER_BIN} build --release")

else
  # Obsługa sytuacji, gdy ktoś poda nieznany argument
  puts "Nieznany argument: #{command}"
  puts "Użycie: ruby build.rb [clean | --blue | --cosmic]"
  exit 1
end

# Kończymy skrypt z takim samym statusem, z jakim zakończył się proces builder-a
exit success ? 0 : 1
