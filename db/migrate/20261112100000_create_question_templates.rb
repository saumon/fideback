class CreateQuestionTemplates < ActiveRecord::Migration[8.1]
  # Le modèle fourni à tous les managers : les questions qui étaient auparavant codées en dur dans Campaign.
  DEFAULT_NAME = "Modèle par défaut".freeze
  DEFAULT_ITEMS = [
    { prompt: "Qualité du travail réalisé cette année", rating: true, comment: true },
    { prompt: "Collaboration et esprit d'équipe", rating: true, comment: true },
    { prompt: "Points forts à valoriser", rating: false, comment: true },
    { prompt: "Axes de progrès", rating: false, comment: true }
  ].freeze

  def change
    create_table :question_templates do |t|
      # NULL pour le modèle du système, qui n'appartient à aucun manager.
      t.references :manager, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.boolean :system, null: false, default: false

      t.timestamps
    end

    create_table :question_template_items do |t|
      t.references :question_template, null: false, foreign_key: { on_delete: :cascade }
      t.integer :position, null: false, default: 0
      t.string :prompt, null: false
      t.boolean :rating, null: false, default: false
      t.boolean :comment, null: false, default: false

      t.timestamps
    end

    reversible do |dir|
      dir.up { create_default_template }
    end
  end

  private

  # Idempotent : un modèle système déjà présent n'est pas recréé.
  def create_default_template
    return if select_value("SELECT 1 FROM question_templates WHERE system = 1 LIMIT 1")

    now = connection.quote(Time.current.utc.to_fs(:db))
    execute "INSERT INTO question_templates (name, system, created_at, updated_at) VALUES (#{connection.quote(DEFAULT_NAME)}, 1, #{now}, #{now})"
    template_id = select_value("SELECT id FROM question_templates WHERE system = 1")
    DEFAULT_ITEMS.each_with_index do |item, position|
      execute "INSERT INTO question_template_items (question_template_id, position, prompt, rating, comment, created_at, updated_at) " \
              "VALUES (#{template_id}, #{position}, #{connection.quote(item[:prompt])}, #{item[:rating] ? 1 : 0}, #{item[:comment] ? 1 : 0}, #{now}, #{now})"
    end
  end
end
