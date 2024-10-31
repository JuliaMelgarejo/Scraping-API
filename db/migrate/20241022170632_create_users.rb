class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :userName, null: false
      t.string :email, null: false, default: "", unique: true
      t.string :encrypted_password, null: false, default: ""
      t.datetime :reset_password_sent_at
      t.string :reset_password_token
      t.datetime :remember_created_at

      t.timestamps
    end
  end
end
