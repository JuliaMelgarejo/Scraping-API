class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.float :price
      t.references :category, null: false, foreign_key: true
      t.string :link 
      t.timestamps
    end
  end
end


