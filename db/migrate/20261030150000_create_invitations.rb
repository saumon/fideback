class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at
      t.references :invited_by, foreign_key: { to_table: :managers, on_delete: :nullify }

      t.timestamps
    end
    add_index :invitations, :token, unique: true
    # Une seule invitation non acceptée par adresse, même sous concurrence.
    add_index :invitations, :email, unique: true, where: "accepted_at IS NULL", name: "index_invitations_on_email_unaccepted"
  end
end
