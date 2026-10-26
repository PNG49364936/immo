class AddKindToArrondissements < ActiveRecord::Migration[7.1]
  def change
    add_column :arrondissements, :kind, :string, default: "arrondissement", null: false
  end
end
