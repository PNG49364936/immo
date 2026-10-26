class ArrondissementsController < ApplicationController
  # GeoJSON des contours, consommé par la carte.
  def index
    features = Arrondissement.all.map do |arr|
      { type: "Feature", id: arr.number, geometry: JSON.parse(arr.geojson),
        properties: { number: arr.number, name: arr.official_name, commune: arr.commune? } }
    end

    render json: { type: "FeatureCollection", features: features }
  end

  # Panneau de statistiques, chargé dans le Turbo Frame "stats".
  def show
    @arrondissement = Arrondissement.find_by!(number: params[:id])
    @paris = ParisStats.new
  end
end
