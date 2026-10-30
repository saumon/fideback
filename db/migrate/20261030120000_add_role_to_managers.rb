class AddRoleToManagers < ActiveRecord::Migration[8.1]
  def up
    add_column :managers, :role, :string, default: "manager", null: false

    # Le manager le plus ancien est le premier inscrit : il devient Admin. Sans
    # manager, la sous-requête est vide et rien n'est modifié ; l'id départage
    # deux comptes créés à la même seconde.
    execute "UPDATE managers SET role = 'admin' WHERE id = (SELECT id FROM managers ORDER BY created_at, id LIMIT 1)"
  end

  def down
    remove_column :managers, :role
  end
end
