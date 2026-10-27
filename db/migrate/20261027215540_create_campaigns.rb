class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.references :manager, null: false, foreign_key: true
      t.string :name, null: false
      t.date :deadline_on, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
