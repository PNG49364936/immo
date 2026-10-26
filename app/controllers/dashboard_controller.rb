class DashboardController < ApplicationController
  def show
    @arrondissements = Arrondissement.parisian
    @communes = Arrondissement.communes
    @import = DvfImport.latest
    @last_done = DvfImport.latest_done
    @paris = ParisStats.new
    @max_median = Arrondissement.maximum(:median_price_m2)
  end
end
