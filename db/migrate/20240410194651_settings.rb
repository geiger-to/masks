class Settings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.string :name
      t.text   :value

      t.timestamps

      t.index :name, unique: true
    end
  end
end
