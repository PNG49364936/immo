class SalesController < ApplicationController
  # GeoJSON de toutes les ventes, aux propriétés volontairement courtes
  # (p = prix, m2 = prix au m², a = arrondissement) pour alléger le fichier.
  def index
    return unless stale?(etag: DvfImport.latest_done&.finished_at, public: true)

    numbers = Arrondissement.pluck(:id, :number).to_h
    features = Sale.pluck(:lng, :lat, :price, :price_m2, :arrondissement_id).map do |lng, lat, price, m2, arr_id|
      { type: "Feature", geometry: { type: "Point", coordinates: [lng.round(6), lat.round(6)] },
        properties: { p: price, m2: m2, a: numbers[arr_id] } }
    end

    render json: { type: "FeatureCollection", features: features }
  end
end
