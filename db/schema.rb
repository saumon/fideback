# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_27_215544) do
  create_table "answers", force: :cascade do |t|
    t.integer "respondent_id", null: false
    t.integer "subject_id", null: false
    t.integer "question_id", null: false
    t.integer "rating"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["respondent_id", "subject_id", "question_id"], name: "index_answers_uniqueness", unique: true
    t.index ["respondent_id"], name: "index_answers_on_respondent_id"
    t.index ["subject_id"], name: "index_answers_on_subject_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.integer "manager_id", null: false
    t.string "name", null: false
    t.date "deadline_on", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_campaigns_on_manager_id"
  end

  create_table "managers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_managers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_managers_on_reset_password_token", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "position", default: 0, null: false
    t.string "prompt", null: false
    t.boolean "rating", default: false, null: false
    t.boolean "comment", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_questions_on_campaign_id"
  end

  create_table "respondents", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "email"], name: "index_respondents_on_campaign_id_and_email", unique: true
    t.index ["campaign_id"], name: "index_respondents_on_campaign_id"
    t.index ["token"], name: "index_respondents_on_token", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "email"], name: "index_subjects_on_campaign_id_and_email", unique: true
    t.index ["campaign_id"], name: "index_subjects_on_campaign_id"
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "respondents"
  add_foreign_key "answers", "subjects"
  add_foreign_key "campaigns", "managers"
  add_foreign_key "questions", "campaigns"
  add_foreign_key "respondents", "campaigns"
  add_foreign_key "subjects", "campaigns"
end
