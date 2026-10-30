class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.references :manager, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.boolean :managed, default: false, null: false
      t.boolean :surveyable, default: false, null: false
      t.timestamps
    end
    add_index :contacts, %i[manager_id email], unique: true

    # Les managés et sondés d'une campagne restent des copies : le lien ne sert
    # qu'à suivre l'annuaire tant que la campagne est brouillon.
    %i[subjects respondents].each do |table|
      add_reference table, :contact, foreign_key: { on_delete: :nullify }
      add_index table, %i[campaign_id contact_id], unique: true
    end
  end
end
