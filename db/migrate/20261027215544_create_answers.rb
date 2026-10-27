class CreateAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :answers do |t|
      t.references :respondent, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :rating
      t.text :body

      t.timestamps
    end
    add_index :answers, [ :respondent_id, :subject_id, :question_id ], unique: true, name: "index_answers_uniqueness"
  end
end
