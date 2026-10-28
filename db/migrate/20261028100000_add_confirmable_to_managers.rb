class AddConfirmableToManagers < ActiveRecord::Migration[8.1]
  # up/down plutôt que change, à cause du rattrapage ci-dessous.
  def up
    add_column :managers, :confirmation_token, :string
    add_column :managers, :confirmed_at, :datetime
    add_column :managers, :confirmation_sent_at, :datetime
    add_column :managers, :unconfirmed_email, :string

    # La clé de recherche de confirm_by_token.
    add_index :managers, :confirmation_token, unique: true

    # Tout manager qui existe à la mise en production est activé : personne qui
    # pouvait se connecter hier n'est exclu aujourd'hui. Horodaté au moment de
    # la migration plutôt qu'à created_at, qui prétendrait une activation qui
    # n'a jamais eu lieu.
    execute "UPDATE managers SET confirmed_at = CURRENT_TIMESTAMP WHERE confirmed_at IS NULL"
  end

  def down
    remove_index :managers, :confirmation_token

    remove_column :managers, :unconfirmed_email
    remove_column :managers, :confirmation_sent_at
    remove_column :managers, :confirmed_at
    remove_column :managers, :confirmation_token
  end
end
