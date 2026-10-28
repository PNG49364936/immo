class SalesController < ApplicationController
  # GeoJSON de toutes les ventes, aux propriétés volontairement courtes
  # (p = prix, m2 = prix au m², s = surface, r = pièces, t = type, a = arrondissement)
  # pour alléger le fichier.
  def index
    return unless stale?(etag: [DvfImport.latest_done&.finished_at, "v2"], public: true)

    numbers = Arrondissement.pluck(:id, :number).to_h
    columns = %i[lng lat price price_m2 surface rooms property_type arrondissement_id]
    features = Sale.pluck(*columns).map do |lng, lat, price, m2, surface, rooms, type, arr_id|
      { type: "Feature", geometry: { type: "Point", coordinates: [lng.round(6), lat.round(6)] },
        properties: { p: price, m2: m2, s: surface, r: rooms, t: type, a: numbers[arr_id] } }
    end

    render json: { type: "FeatureCollection", features: features }
  end
end
