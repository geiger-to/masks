class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table "masks_entries" do |t|
      t.string :public_id

      t.references :actor
      t.references :device
      t.references :client
      t.timestamps

      t.index :public_id, unique: true
    end
  end
end
