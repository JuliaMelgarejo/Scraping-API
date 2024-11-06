class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ""  # Cambiamos eemail por email
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      # Campos para el trackable (descomentarlos si los necesitas)
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      # Campos para el confirmable (descomentarlos si los necesitas)
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_eemail # Solo si usas reconfirmable

      # Campos para el lockable (descomentarlos si los necesitas)
      # t.integer  :failed_attempts, default: 0, null: false # Solo si lock strategy es :failed_attempts
      # t.string   :unlock_token # Solo si unlock strategy es :eemail o :both
      # t.datetime :locked_at

      t.timestamps
    end

    add_index :users, :email, unique: true              # Cambiamos eemail por email
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token, unique: true
    # add_index :users, :unlock_token, unique: true
  end
end