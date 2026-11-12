require "test_helper"

class QuestionTemplateTest < ActiveSupport::TestCase
  def new_template(**attrs)
    managers(:alice).question_templates.build({ name: "Mon modèle", items_attributes: [ { prompt: "Une question", rating: "1", comment: "0" } ] }.merge(attrs))
  end

  test "a template with a name and a valid question is valid" do
    assert new_template.valid?
  end

  test "requires a name" do
    template = new_template(name: "")
    assert_not template.valid?
    assert template.errors.key?(:name)
  end

  test "requires at least one question" do
    template = new_template(items_attributes: [])
    assert_not template.valid?
    assert_includes template.errors[:base], "Un modèle doit comporter au moins une question"
  end

  test "blank questions are ignored, which leaves none" do
    assert_not new_template(items_attributes: [ { prompt: "", rating: "1", comment: "1" } ]).valid?
  end

  test "a question needs a rating and/or a comment" do
    template = new_template(items_attributes: [ { prompt: "Sans réponse", rating: "0", comment: "0" } ])
    assert_not template.valid?
    assert_includes template.items.first.errors[:base], "Une question doit comporter une note et/ou un commentaire"
  end

  test "questions are renumbered in form order, ignoring those marked for destruction" do
    template = question_templates(:alice_annual)
    first = template.items.first
    template.update!(items_attributes: [ { id: first.id, _destroy: "1" }, { prompt: "Nouvelle", rating: "1", comment: "0" } ])
    assert_equal [ "Souhaits d'évolution", "Nouvelle" ], template.reload.items.map(&:prompt)
    assert_equal [ 0, 1 ], template.items.map(&:position)
  end

  test "removing every question is refused" do
    template = question_templates(:alice_project)
    assert_not template.update(items_attributes: [ { id: template.items.first.id, _destroy: "1" } ])
    assert_equal 1, template.reload.items.count
  end

  test "available_to lists the system template first, then the manager's own by name, never another manager's" do
    names = QuestionTemplate.available_to(managers(:alice)).map(&:name)
    assert_equal [ "Modèle par défaut", "Bilan annuel", "Fin de projet" ], names
    assert_not_includes QuestionTemplate.available_to(managers(:alice)), question_templates(:bob_private)
  end

  test "default is the system template, with its four questions" do
    assert_equal question_templates(:default), QuestionTemplate.default
    assert_equal 4, QuestionTemplate.default.items.size
  end

  test "the system template can be neither changed nor destroyed" do
    template = question_templates(:default)
    assert_raises(ActiveRecord::ReadOnlyRecord) { template.update(name: "Autre") }
    assert_raises(ActiveRecord::ReadOnlyRecord) { template.destroy }
    assert_raises(ActiveRecord::ReadOnlyRecord) { template.items.first.update(prompt: "Autre") }
    assert_raises(ActiveRecord::ReadOnlyRecord) { template.items.first.destroy }
    assert_equal "Modèle par défaut", template.reload.name
    assert_equal 4, template.items.count
  end

  test "build_questions_for copies the questions in order" do
    campaign = managers(:alice).campaigns.build
    question_templates(:alice_annual).build_questions_for(campaign)
    assert_equal [ "Objectifs atteints", "Souhaits d'évolution" ], campaign.questions.map(&:prompt)
    assert_equal [ [ true, true ], [ false, true ] ], campaign.questions.map { |q| [ q.rating, q.comment ] }
    assert campaign.questions.all?(&:new_record?)
  end

  test "destroying a template destroys its questions" do
    assert_difference -> { QuestionTemplateItem.count }, -2 do
      question_templates(:alice_annual).destroy!
    end
  end
end
