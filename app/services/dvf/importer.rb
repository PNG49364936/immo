module Dvf
  # Remplace les ventes en base par celles des 24 derniers mois disponibles,
  # puis recalcule les statistiques de chaque arrondissement.
  class Importer
    Result = Struct.new(:count, :data_from, :data_until, keyword_init: true)
    BATCH_SIZE = 5_000

    def initialize(paths: nil)
      @paths = paths
    end

    def call
      sales = Parser.new(@paths || Downloader.new.call).call
      arrondissement_ids = Arrondissement.pluck(:insee_code, :id).to_h
      now = Time.current

      rows = sales.filter_map do |sale|
        arrondissement_id = arrondissement_ids[sale.insee_code]
        next unless arrondissement_id

        sale.to_h.except(:insee_code).merge(arrondissement_id: arrondissement_id,
                                            created_at: now, updated_at: now)
      end

      ActiveRecord::Base.transaction do
        ::Sale.delete_all
        rows.each_slice(BATCH_SIZE) { |batch| ::Sale.insert_all!(batch) }
        Arrondissement.find_each(&:refresh_stats!)
      end

      dates = rows.map { |row| row[:sold_on] }
      Result.new(count: rows.size, data_from: dates.min, data_until: dates.max)
    end
  end
end
