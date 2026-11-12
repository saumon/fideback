require "test_helper"

class QuestionTemplatesTest < ActionDispatch::IntegrationTest
  setup { sign_in managers(:alice) }

  def template_params(name: "Onboarding", items: [ { prompt: "Premières impressions", rating: "1", comment: "1" } ])
    { question_template: { name: name, items_attributes: items.each_with_index.to_h { |item, index| [ index.to_s, item ] } } }
  end

  test "requires a signed-in manager" do
    sign_out :manager
    get question_templates_path
    assert_redirected_to new_manager_session_path
  end

  test "index lists the system template first, then mine, never another manager's" do
    get question_templates_path
    assert_response :success
    assert_equal [ "Modèle par défaut", "Bilan annuel", "Fin de projet" ], css_select(".template-list .ledger-title").map(&:text)
    assert_select ".status-system", text: "Fourni par Fideback", count: 1
    assert_equal [ "4 questions", "2 questions", "1 question" ], css_select(".template-list .muted").map(&:text)
    assert_select "a", text: "Modèle de Bob", count: 0
  end

  test "the system template has no edit or delete control" do
    get question_templates_path
    assert_select "#question_template_#{question_templates(:default).id} a[href*=edit]", count: 0
    assert_select "#question_template_#{question_templates(:default).id} form", count: 0

    get question_template_path(question_templates(:default))
    assert_response :success
    assert_select ".question-list li", count: 4
    assert_select "a", text: "Modifier", count: 0
    assert_select "form[action=?]", question_template_path(question_templates(:default)), count: 0
  end

  test "creating a template" do
    get new_question_template_path
    assert_response :success
    assert_select "input[name='question_template[name]']"
    assert_select "[data-nested-form-target=container] input[name$='[prompt]']", count: 1
    assert_select "template input[name='question_template[items_attributes][NEW_RECORD][prompt]']"

    assert_difference -> { managers(:alice).question_templates.count }, 1 do
      post question_templates_path, params: template_params
    end
    assert_redirected_to question_templates_path
    template = managers(:alice).question_templates.find_by!(name: "Onboarding")
    assert_equal [ "Premières impressions" ], template.items.map(&:prompt)
  end

  test "a template without a name or without a question is refused" do
    assert_no_difference -> { QuestionTemplate.count } do
      post question_templates_path, params: template_params(name: "")
      assert_response :unprocessable_content
      post question_templates_path, params: template_params(items: [ { prompt: "", rating: "1", comment: "1" } ])
      assert_response :unprocessable_content
      assert_select ".callout-alert", text: /au moins une question/
    end
  end

  test "a question with neither rating nor comment is refused and the form keeps what was typed" do
    post question_templates_path, params: template_params(items: [ { prompt: "Sans réponse", rating: "0", comment: "0" } ])
    assert_response :unprocessable_content
    assert_select ".callout-alert", text: /note et\/ou un commentaire/
    assert_select "input[value='Sans réponse']"
  end

  test "editing a template keeps the questions in form order" do
    template = question_templates(:alice_annual)
    get edit_question_template_path(template)
    assert_response :success
    assert_select "[data-nested-form-target=container] .question", count: 2

    first, second = template.items.to_a
    patch question_template_path(template), params: { question_template: { name: "Bilan 2026", items_attributes: {
      "0" => { id: first.id, _destroy: "1" },
      "1" => { id: second.id, prompt: second.prompt, rating: "0", comment: "1", _destroy: "0" },
      "2" => { prompt: "Ajoutée", rating: "1", comment: "0" }
    } } }
    assert_redirected_to question_templates_path
    assert_equal "Bilan 2026", template.reload.name
    assert_equal [ "Souhaits d'évolution", "Ajoutée" ], template.items.map(&:prompt)
  end

  test "deleting a template leaves campaigns' questions alone" do
    campaign = campaigns(:draft_campaign)
    assert_difference -> { campaign.questions.count }, 0 do
      assert_difference -> { QuestionTemplate.count }, -1 do
        delete question_template_path(question_templates(:alice_annual))
      end
    end
    assert_redirected_to question_templates_path
  end

  test "the delete button asks for confirmation" do
    get question_templates_path
    assert_select "form[action=?][data-turbo-confirm='Supprimer ce modèle ?'][data-turbo-confirm-icon=trash]", question_template_path(question_templates(:alice_annual))
  end

  test "the system template cannot be edited, updated or deleted" do
    system = question_templates(:default)

    get edit_question_template_path(system)
    assert_redirected_to question_template_path(system)

    patch question_template_path(system), params: template_params(name: "Piraté")
    assert_redirected_to question_template_path(system)
    assert_equal "Modèle par défaut", system.reload.name

    assert_no_difference -> { QuestionTemplate.count } do
      delete question_template_path(system)
    end
    assert_redirected_to question_template_path(system)
    assert_equal 4, system.items.count
  end

  test "another manager's template does not exist for me" do
    other = question_templates(:bob_private)
    [ [ :get, question_template_path(other) ], [ :get, edit_question_template_path(other) ],
      [ :patch, question_template_path(other) ], [ :delete, question_template_path(other) ] ].each do |verb, path|
      sign_in managers(:alice) # la session de test n'est pas conservée après une 404
      assert_no_difference -> { QuestionTemplate.count } do
        public_send(verb, path, params: template_params(name: "Volé"))
      end
      assert_response :not_found, "#{verb} #{path}"
    end
    assert_equal "Modèle de Bob", other.reload.name
  end

  test "a template created for me belongs to me even if another owner is submitted" do
    post question_templates_path, params: { question_template: { manager_id: managers(:bob).id, system: "1" }.merge(template_params[:question_template]) }
    created = QuestionTemplate.find_by!(name: "Onboarding")
    assert_equal managers(:alice), created.manager
    assert_not created.system?
  end
end
