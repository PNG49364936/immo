class Arrondissement < ApplicationRecord
  has_many :sales, dependent: :delete_all

  default_scope { order(:number) }

  # "1er", "2e", "3e"…
  def ordinal
    number == 1 ? "1er" : "#{number}e"
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
