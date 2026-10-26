# Un secteur de la carte : un arrondissement parisien ou une commune limitrophe
# (Clichy, Levallois-Perret). Les communes ont un numéro ≥ 21.
class Arrondissement < ApplicationRecord
  has_many :sales, dependent: :delete_all

  default_scope { order(:number) }
  scope :parisian, -> { where(kind: "arrondissement") }
  scope :communes, -> { where(kind: "commune") }

  def commune? = kind == "commune"

  # "1er", "2e", "3e"…
  def ordinal
    number == 1 ? "1er" : "#{number}e"
  end

  # Ce qu'affiche la grande pastille de la liste : 6, 20… ou « Cl », « LP ».
  def badge
    return number.to_s unless commune?

    words = official_name.split(/[-\s]/)
    words.size == 1 ? official_name[0, 2] : words.map(&:first).join
  end

  # Surtitre du panneau de statistiques.
  def kicker
    commune? ? "Hauts-de-Seine · #{insee_code}" : "#{ordinal} arrondissement"
  end

  # Recalcule la médiane du prix au m² et le nombre de ventes (cache).
  def refresh_stats!
    prices = sales.pluck(:price_m2)
    update!(median_price_m2: self.class.median(prices), sales_count: prices.size)
  end

  def self.median(values)
    return nil if values.empty?

    sorted = values.sort
    mid = sorted.size / 2
    sorted.size.odd? ? sorted[mid] : ((sorted[mid - 1] + sorted[mid]) / 2.0).round
  end
end
