# Charge les contours des 20 arrondissements (source : opendata.paris.fr)…
geojson = JSON.parse(File.read(Rails.root.join("db/data/arrondissements.geojson")))

geojson["features"].each do |feature|
  props = feature["properties"]
  arrondissement = Arrondissement.find_or_initialize_by(number: props["c_ar"])
  arrondissement.update!(
    kind: "arrondissement",
    insee_code: props["c_arinsee"].to_s,
    name: "Paris #{arrondissement.ordinal}",
    official_name: props["l_aroff"],
    geojson: feature["geometry"].to_json
  )
end

# … et des communes limitrophes (source : geo.api.gouv.fr), numérotées à partir de 21.
communes = JSON.parse(File.read(Rails.root.join("db/data/communes.geojson")))

communes["features"].each.with_index(21) do |feature, number|
  props = feature["properties"]
  commune = Arrondissement.find_or_initialize_by(insee_code: props["code"])
  commune.update!(
    kind: "commune",
    number: number,
    name: props["nom"],
    official_name: props["nom"],
    geojson: feature["geometry"].to_json
  )
end

puts "#{Arrondissement.parisian.count} arrondissements et #{Arrondissement.communes.count} communes chargés."
