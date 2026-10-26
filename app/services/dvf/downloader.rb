require "net/http"

module Dvf
  # Télécharge les fichiers DVF géolocalisés de Paris (75) et des Hauts-de-Seine (92,
  # pour Clichy et Levallois-Perret).
  # Etalab publie un fichier par année ; l'année en cours n'existe souvent pas
  # encore, on remonte donc jusqu'à trouver les `years_needed` plus récentes.
  class Downloader
    BASE_URL = "https://files.data.gouv.fr/geo-dvf/latest/csv/%<year>d/departements/%<department>s.csv.gz".freeze
    DEPARTMENTS = %w[75 92].freeze
    MAX_REDIRECTS = 5

    def initialize(dir: Rails.root.join("tmp/dvf"), years_needed: 2, departments: DEPARTMENTS)
      @dir = Pathname(dir)
      @years_needed = years_needed
      @departments = departments
    end

    # Renvoie les chemins des fichiers .csv.gz téléchargés, pour tous les départements.
    def call
      @dir.mkpath
      @departments.flat_map { |department| download_department(department) }
    end

    private

    def download_department(department)
      paths = []
      Date.current.year.downto(Date.current.year - 5) do |year|
        path = download(department, year)
        paths << path if path
        break if paths.size == @years_needed
      end
      raise "Aucun fichier DVF trouvé pour le département #{department}" if paths.empty?

      paths
    end

    def download(department, year)
      path = @dir.join("#{department}-#{year}.csv.gz")
      body = fetch(URI(format(BASE_URL, year: year, department: department)))
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
