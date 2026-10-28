class SalesController < ApplicationController
  # GeoJSON de toutes les ventes, aux propriétés volontairement courtes
  # (p = prix, m2 = prix au m², s = surface, r = pièces, t = type, ad = adresse,
  # a = arrondissement) pour alléger le fichier.
  def index
    return unless stale?(etag: [DvfImport.latest_done&.finished_at, "v3"], public: true)

    sectors = Arrondissement.pluck(:id, :number, :name).to_h { |id, number, name| [id, [number, name]] }
    columns = %i[lng lat price price_m2 surface rooms property_type address arrondissement_id]
    features = Sale.pluck(*columns).map do |lng, lat, price, m2, surface, rooms, type, address, arr_id|
      number, place = sectors[arr_id]
      { type: "Feature", geometry: { type: "Point", coordinates: [lng.round(6), lat.round(6)] },
        properties: { p: price, m2: m2, s: surface, r: rooms, t: type,
                      ad: "#{Sale.format_address(address)}, #{place}", a: number } }
    end

    render json: { type: "FeatureCollection", features: features }
  end
end
