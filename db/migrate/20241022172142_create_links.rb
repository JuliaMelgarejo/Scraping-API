class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links do |t|
      t.string :url
      t.string :description
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
