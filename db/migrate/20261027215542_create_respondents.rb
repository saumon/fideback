class CreateRespondents < ActiveRecord::Migration[8.1]
  def change
    create_table :respondents do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :submitted_at

      t.timestamps
    end
    add_index :respondents, [ :campaign_id, :email ], unique: true
    add_index :respondents, :token, unique: true
  end
end
