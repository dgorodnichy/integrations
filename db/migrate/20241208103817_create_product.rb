class CreateProduct < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :price, null: false
      t.string :sku, null: false, index: true

      t.timestamps
    end
  end
end
