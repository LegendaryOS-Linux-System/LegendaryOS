require 'net/http'
require 'json'
require 'open-uri'
require 'fileutils'

# Konfiguracja
REPO = "LegendaryOS-Linux-System/LegendaryOS-Builder"
TARGET_DIR = "build"
# Zmień nazwę pliku, jeśli binarka w release nazywa się inaczej
BINARY_NAME = "legendaryos-builder" 

def get_latest_release_url
  uri = URI("https://api.github.com/repos/#{REPO}/releases/latest")
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)

  if data['assets'].nil? || data['assets'].empty?
    puts "Błąd: Nie znaleziono plików (assets) w najnowszym wydaniu."
    exit 1
  end

  # Szukamy odpowiedniego pliku – domyślnie bierzemy pierwszy asset, 
  # lub możesz przefiltrować po nazwie, np. zawierającej 'linux' albo 'x86_64'
  asset = data['assets'].first
  
  puts "Znaleziono najnowszą wersję: #{data['tag_name']}"
  puts "Pobieranie pliku: #{asset['name']}"
  
  return asset['browser_download_url'], asset['name']
end

def download_file(url, dest_path)
  FileUtils.mkdir_p(TARGET_DIR)
  
  puts "Pobieranie..."
  URI.open(url) do |remote_file|
    File.open(dest_path, "wb") do |local_file|
      local_file.write(remote_file.read)
    end
  end
  puts "Pobrano i zapisano w: #{dest_path}"
end

# 1. Pobranie informacji o najnowszym release
download_url, file_name = get_latest_release_url
binary_path = File.join(TARGET_DIR, BINARY_NAME)

# 2. Pobranie binarki
# Zapisujemy ją bezpośrednio pod docelową nazwą w katalogu build/
download_file(download_url, binary_path)

# 3. Nadanie uprawnień chmod a+x (0755)
puts "Nadawanie uprawnień wykonywania (chmod a+x)..."
File.chmod(0755, binary_path)

# 4. Uruchomienie binarki z subkomendami: build --release
puts "Uruchamianie binarki: #{binary_path} build --release"
puts "--- Wynik działania programu ---"

# exec zastępuje bieżący proces Ruby procesem binarki, 
# jeśli wolisz wrócić do skryptu po jej zakończeniu, użyj system() zamiast exec
exec(binary_path, "build", "--release")
