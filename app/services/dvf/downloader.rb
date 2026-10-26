require "net/http"

module Dvf
  # Télécharge les fichiers DVF géolocalisés de Paris (département 75).
  # Etalab publie un fichier par année ; l'année en cours n'existe souvent pas
  # encore, on remonte donc jusqu'à trouver les `years_needed` plus récentes.
  class Downloader
    BASE_URL = "https://files.data.gouv.fr/geo-dvf/latest/csv/%<year>d/departements/75.csv.gz".freeze
    MAX_REDIRECTS = 5

    def initialize(dir: Rails.root.join("tmp/dvf"), years_needed: 2)
      @dir = Pathname(dir)
      @years_needed = years_needed
    end

    # Renvoie les chemins des fichiers .csv.gz téléchargés, du plus récent au plus ancien.
    def call
      @dir.mkpath
      paths = []
      Date.current.year.downto(Date.current.year - 5) do |year|
        path = download(year)
        paths << path if path
        break if paths.size == @years_needed
      end
      raise "Aucun fichier DVF trouvé pour Paris" if paths.empty?

      paths
    end

    private

    def download(year)
      path = @dir.join("75-#{year}.csv.gz")
      body = fetch(URI(format(BASE_URL, year: year)))
      return nil unless body

      File.binwrite(path, body)
      path
    end

    def fetch(uri, redirects = 0)
      response = Net::HTTP.get_response(uri)
      case response
      when Net::HTTPSuccess then response.body
      when Net::HTTPRedirection
        raise "Trop de redirections" if redirects >= MAX_REDIRECTS

        fetch(URI(response["location"]), redirects + 1)
      when Net::HTTPNotFound then nil # année pas encore publiée
      else raise "Erreur HTTP #{response.code} sur #{uri}"
      end
    end
  end
end
