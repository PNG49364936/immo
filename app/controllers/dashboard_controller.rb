class DashboardController < ApplicationController
  def show
    @arrondissements = Arrondissement.all
    @import = DvfImport.latest
    @last_done = DvfImport.latest_done
    @paris = ParisStats.new
    @max_median = @arrondissements.filter_map(&:median_price_m2).max
  end
end
