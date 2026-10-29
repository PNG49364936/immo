require "test_helper"
require "csv"

class Dvf::ParserTest < ActiveSupport::TestCase
  HEADER = %w[id_mutation date_mutation nature_mutation valeur_fonciere adresse_numero adresse_suffixe
              adresse_nom_voie code_commune type_local surface_reelle_bati nombre_pieces_principales
              longitude latitude].freeze

  def row(id, type, surface: 50, price: 500_000, date: "2025-06-01", nature: "Vente", lat: "48.85")
    [id, date, nature, price, "12", nil, "RUE DES ROSIERS", "75104", type, surface, 2, "2.35", lat]
  end

  def parse(rows)
    file = Tempfile.new(["dvf", ".csv.gz"])
    Zlib::GzipWriter.open(file.path) do |gz|
      gz.write(HEADER.to_csv)
      rows.each { |r| gz.write(r.to_csv) }
    end
    Dvf::Parser.new(file.path).call
  ensure
    file&.unlink
  end

  test "garde un appartement simple et calcule le prix au m²" do
    sales = parse([row("A", "Appartement")])

    assert_equal 1, sales.size
    assert_equal 10_000, sales.first.price_m2
    assert_equal "12 RUE DES ROSIERS", sales.first.address
  end

  test "regroupe un appartement et sa cave en une seule vente" do
    sales = parse([row("A", "Dépendance", surface: nil), row("A", "Appartement")])

    assert_equal 1, sales.size
    assert_equal 50, sales.first.surface
  end

  test "écarte les ventes en bloc, les locaux commerciaux et les non-ventes" do
    sales = parse([
      row("BLOC", "Appartement"), row("BLOC", "Appartement"),
      row("MIXTE", "Appartement"), row("MIXTE", "Local industriel. commercial ou assimilé"),
      row("ECHANGE", "Appartement", nature: "Echange")
    ])

    assert_empty sales
  end

  test "écarte les prix aberrants, les petites surfaces et les ventes sans coordonnées" do
    sales = parse([
      row("CHER", "Appartement", price: 50_000_000),
      row("MINI", "Appartement", surface: 5),
      row("NOGPS", "Appartement", lat: nil)
    ])

    assert_empty sales
  end

  test "ne garde que les 24 mois précédant la vente la plus récente" do
    sales = parse([
      row("RECENT", "Appartement", date: "2025-12-31"),
      row("DANS", "Appartement", date: "2024-01-01"),
      row("VIEUX", "Appartement", date: "2023-12-31")
    ])

    assert_equal %w[DANS RECENT], sales.map(&:mutation_id).sort
  end
end
