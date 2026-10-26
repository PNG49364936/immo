class CreateDvfImports < ActiveRecord::Migration[7.1]
  def change
    create_table :dvf_imports do |t|
      t.string :status, default: "pending", null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :sales_count, default: 0, null: false
      t.date :data_from
      t.date :data_until
      t.text :error_message

      t.timestamps
    end
  end
end
