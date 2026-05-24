require 'net/http'
require 'uri'
require 'fileutils'

# 1. Definiowanie adresów i nazw plików
url_string = "https://github.com/LegendaryOS-Linux-System/LegendaryOS-App/releases/download/v0.1/LegendaryOS-App.rpm"
file_name = "LegendaryOS-App.rpm"

# 2. Ustalanie ścieżki docelowej (wyjście z scripts/pre do głównego katalogu, a potem do packages/)
# __dir__ to katalog, w którym znajduje się ten skrypt (czyli scripts/pre)
script_dir = __dir__
target_dir = File.expand_path(File.join(script_dir, '..', '..', 'packages'))

# Tworzymy folder 'packages/', jeśli jeszcze nie istnieje
FileUtils.mkdir_p(target_dir)

target_path = File.join(target_dir, file_name)

# 3. Metoda do pobierania pliku z obsługą przekierowań (HTTP Redirect)
def download_file(url_str, target_path)
  uri = URI.parse(url_str)
  
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    request = Net::HTTP::Get.new(uri)
    
    http.request(request) do |response|
      case response
      when Net::HTTPSuccess
        # Zapisywanie pliku na dysku
        File.open(target_path, 'wb') do |file|
          response.read_body do |chunk|
            file.write(chunk)
          end
        end
        puts "Sukces! Plik został pobrany do: #{target_path}"
      when Net::HTTPRedirection
        # GitHub przekieruje nas na serwery AWS S3 – musimy iść za tym adresem
        location = response['location']
        puts "Przekierowanie do: #{location}"
        download_file(location, target_path)
      else
        puts "Błąd pobierania: #{response.code} #{response.message}"
      end
    end
  end
end

# 4. Uruchomienie pobierania
puts "Rozpoczynam pobieranie pliku RPM..."
download_file(url_string, target
  _path)
