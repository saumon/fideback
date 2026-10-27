class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.references :campaign, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.string :prompt, null: false
      t.boolean :rating, null: false, default: false
      t.boolean :comment, null: false, default: false

      t.timestamps
    end
  end
end
