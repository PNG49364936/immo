namespace :dvf do
  desc "Télécharge DVF et recharge les ventes des 12 derniers mois disponibles"
  task import: :environment do
    import = DvfImport.create!
    ImportDvfJob.perform_now(import)
    import.reload
    puts "#{import.sales_count} ventes importées (du #{import.data_from} au #{import.data_until})."
  end
end
