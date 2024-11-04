class CreatePriceHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :price_histories do |t|
      t.date :datte
      t.float :price
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
