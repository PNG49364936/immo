class CreateArrondissements < ActiveRecord::Migration[7.1]
  def change
    create_table :arrondissements do |t|
      t.integer :number
      t.string :insee_code
      t.string :name
      t.string :official_name
      t.text :geojson
      t.integer :median_price_m2
      t.integer :sales_count, default: 0, null: false

      t.timestamps
    end
    add_index :arrondissements, :number, unique: true
    add_index :arrondissements, :insee_code, unique: true
  end
end
