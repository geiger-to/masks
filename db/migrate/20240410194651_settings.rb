class Settings < ActiveRecord::Migration[7.1]
  def change
    create_table :masks_settings do |t|
      t.string :name
      t.text   :value

      t.timestamps

      t.index :name, unique: true
    end

    create_table :masks_rules do |t|
      t.references :tenant
      t.references :masks_profile

      t.string :key
      t.string :actor
      t.text :checks
      t.text :credentials
      t.text :scopes
      t.text :request
      t.text :access
      t.text :settings
      t.text :pass, default: "/"
      t.text :fail
      t.boolean :skip
      t.boolean :anon

      t.datetime :enabled_at
      t.timestamps

      t.index %i[key], unique: true
    end
  end
end
