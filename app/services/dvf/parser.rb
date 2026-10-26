require "csv"
require "zlib"

module Dvf
  # Transforme les lignes brutes DVF en ventes de logements exploitables.
  #
  # Dans DVF, une vente (« mutation ») s'étale sur plusieurs lignes : une pour
  # l'appartement, une pour la cave, une pour le parking… et le prix total est
  # répété sur chacune. On regroupe donc par `id_mutation` avant de filtrer.
  class Parser
    HOUSING_TYPES = %w[Appartement Maison].freeze
    ALLOWED_EXTRA_TYPES = ["Dépendance", nil].freeze # cave, parking, terrain nu
    MIN_SURFACE = 9
    PRICE_M2_RANGE = (2_000..40_000)

    Sale = Struct.new(:mutation_id, :sold_on, :price, :surface, :rooms, :property_type,
                      :address, :insee_code, :lat, :lng, :price_m2, keyword_init: true)

    def initialize(paths, months: 12)
      @paths = Array(paths)
      @months = months
    end

    def call
      sales = mutations.filter_map { |rows| to_sale(rows) }
      return [] if sales.empty?

      latest = sales.map(&:sold_on).max
      cutoff = latest << @months # même jour, 12 mois plus tôt
      sales.select { |sale| sale.sold_on > cutoff }
    end

    private

    def mutations
      groups = Hash.new { |hash, key| hash[key] = [] }
      @paths.each do |path|
        Zlib::GzipReader.open(path.to_s) do |gz|
          CSV.new(gz, headers: true).each { |row| groups[row["id_mutation"]] << row }
        end
      end
      groups.values
    end

    def to_sale(rows)
      first = rows.first
      return unless first["nature_mutation"] == "Vente"

      housing, others = rows.partition { |row| HOUSING_TYPES.include?(row["type_local"]) }
      return unless housing.size == 1 # ventes en bloc : prix impossible à répartir
      return unless others.all? { |row| ALLOWED_EXTRA_TYPES.include?(row["type_local"].presence) }

      home = housing.first
      price = first["valeur_fonciere"].to_f.round
      surface = home["surface_reelle_bati"].to_i
      lat, lng = home["latitude"].presence, home["longitude"].presence
      return if surface < MIN_SURFACE || price <= 0 || lat.nil? || lng.nil?

      price_m2 = (price / surface.to_f).round
      return unless PRICE_M2_RANGE.cover?(price_m2)

      Sale.new(
        mutation_id: first["id_mutation"],
        sold_on: Date.parse(first["date_mutation"]),
        price: price,
        surface: surface,
        rooms: home["nombre_pieces_principales"].to_i,
        property_type: home["type_local"],
        address: address(home),
        insee_code: home["code_commune"],
        lat: lat.to_f,
        lng: lng.to_f,
        price_m2: price_m2
      )
    end

    def address(row)
      [row["adresse_numero"], row["adresse_suffixe"], row["adresse_nom_voie"]]
        .compact_blank.join(" ").squish
    end
  end
end
