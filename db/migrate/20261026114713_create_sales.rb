class CreateSales < ActiveRecord::Migration[7.1]
  def change
    create_table :sales do |t|
      t.string :mutation_id
      t.date :sold_on
      t.integer :price
      t.integer :surface
      t.integer :rooms
      t.string :property_type
      t.string :address
      t.float :lat
      t.float :lng
      t.integer :price_m2
      t.references :arrondissement, null: false, foreign_key: true

      t.timestamps
    end
    add_index :sales, :mutation_id, unique: true
    add_index :sales, :sold_on
    add_index :sales, :price_m2
  end
end
