# Statistiques agrégées sur les 20 arrondissements (hors communes limitrophes).
class ParisStats
  def median_price_m2 = @median ||= Arrondissement.median(scope.pluck(:price_m2))
  def sales_count = @count ||= scope.count

  private

  def scope = Sale.joins(:arrondissement).merge(Arrondissement.unscoped.parisian)
end
