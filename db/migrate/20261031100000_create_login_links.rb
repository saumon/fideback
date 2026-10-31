class CreateLoginLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :login_links do |t|
      t.references :manager, null: false, foreign_key: { on_delete: :cascade }
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end
    add_index :login_links, :token, unique: true
  end
end
