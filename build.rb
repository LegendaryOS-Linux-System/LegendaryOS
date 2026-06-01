#!/usr/bin/env ruby

# Definiujemy ścieżkę do binarki, aby kod był czytelny
BUILDER_BIN = "/usr/bin/legendaryos-builder"

# Sprawdzamy pierwszy argument przekazany do skryptu
command = ARGV[0]

case command
when "clean"
  # Wywołanie dla: ruby build.rb clean
  puts "Uruchamianie czyszczenia..."
  success = system("sudo #{BUILDER_BIN} clean --all")
  
when nil
  # Wywołanie bez argumentów: ruby build.rb
  puts "Uruchamianie budowania wersji release..."
  success = system("sudo #{BUILDER_BIN} build --release")
  
else
  # Obsługa sytuacji, gdy ktoś poda nieznany argument
  puts "Nieznany argument: #{command}"
  puts "Użycie: ruby build.rb [clean]"
  exit 1
end

# Kończymy skrypt z takim samym statusem, z jakim zakończył się proces builder-a
exit success ? 0 : 1
