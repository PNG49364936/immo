# Charge les contours des 20 arrondissements (source : opendata.paris.fr).
geojson = JSON.parse(File.read(Rails.root.join("db/data/arrondissements.geojson")))

geojson["features"].each do |feature|
  props = feature["properties"]
  arrondissement = Arrondissement.find_or_initialize_by(number: props["c_ar"])
  arrondissement.update!(
    insee_code: props["c_arinsee"].to_s,
    name: "Paris #{arrondissement.ordinal}",
    official_name: props["l_aroff"],
    geojson: feature["geometry"].to_json
  )
end

puts "#{Arrondissement.count} arrondissements chargés."
