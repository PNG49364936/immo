# Statistiques agrégées sur tout Paris (calculées à la volée).
class ParisStats
  def median_price_m2 = @median ||= Arrondissement.median(Sale.pluck(:price_m2))
  def sales_count = @count ||= Sale.count
end
