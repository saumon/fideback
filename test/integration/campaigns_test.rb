require "test_helper"

class CampaignsTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup { sign_in managers(:alice) }

  test "index lists only my campaigns" do
    get campaigns_path
    assert_response :success
    assert_select "a", text: "Entretiens 2026"
    assert_select "a", text: "Campagne de Bob", count: 0
  end

  test "new form is prefilled with the default template's questions, which is preselected" do
    default = question_templates(:default)
    get new_campaign_path
    assert_response :success
    assert_select "[data-nested-form-target=container] input[name$='[prompt]']", count: default.items.size
    assert_select "input[value='#{default.items.first.prompt}']"
    assert_select "select#template_id option[selected]", text: default.name
  end

  test "the template picker lists the default template, then my templates under « Mes modèles »" do
    get new_campaign_path
    assert_select "label[for=template_id]", text: "Partir d'un modèle"
    assert_select "select#template_id > option", count: 1
    assert_select "select#template_id > option", text: "Modèle par défaut"
    assert_select "select#template_id > optgroup[label='Mes modèles'] > option", count: 2
    assert_equal [ "Bilan annuel", "Fin de projet" ], css_select("select#template_id optgroup option").map(&:text)
    assert_select "select#template_id option", text: "Modèle de Bob", count: 0
    assert_select "turbo-frame#questions [data-nested-form-target=container]"
    assert_select "[data-controller=template-picker] select[data-action='template-picker#choose']"
  end

  test "without a template of my own the picker has no group" do
    sign_out :manager
    sign_in managers(:bob)
    managers(:bob).question_templates.destroy_all
    get new_campaign_path
    assert_select "select#template_id > optgroup", count: 0
  end

  test "new form with a template of mine is prefilled with its questions" do
    template = question_templates(:alice_annual)
    get new_campaign_path(template_id: template.id)
    assert_response :success
    assert_equal template.items.map(&:prompt), css_select("turbo-frame#questions [data-nested-form-target=container] .question input[name$='[prompt]']").map { |input| input["value"] }
    assert_select "select#template_id option[selected]", text: template.name
  end

  test "the frame request for a template renders without the page layout" do
    get new_campaign_path(template_id: question_templates(:alice_project).id), headers: { "Turbo-Frame" => "questions" }
    assert_response :success
    assert_select "header.site-header", count: 0
    assert_select "turbo-frame#questions input[value='Respect des délais']"
  end

  test "an unknown, foreign or malformed template falls back to the default" do
    [ 0, question_templates(:bob_private).id, "abc", "" ].each do |id|
      get new_campaign_path(template_id: id)
      assert_response :success, id.inspect
      assert_select "select#template_id option[selected]", text: "Modèle par défaut"
      assert_select "input[value='Axes de progrès']"
      assert_select "input[value='Question privée de Bob']", count: 0
    end
  end

  test "a refused creation keeps the chosen template and the typed questions" do
    template = question_templates(:alice_annual)
    post campaigns_path, params: { template_id: template.id, campaign: { name: "", deadline_on: 1.month.from_now.to_date,
      questions_attributes: { "0" => { prompt: "Ma question à moi", rating: "1", comment: "0" } } } }
    assert_response :unprocessable_content
    assert_select "select#template_id option[selected]", text: template.name
    assert_select "input[value='Ma question à moi']"
    assert_select "input[value='Objectifs atteints']", count: 0
  end

  test "the campaign keeps its own copy of the questions when the template changes afterwards" do
    template = question_templates(:alice_annual)
    post campaigns_path, params: { template_id: template.id, campaign: { name: "Copie", deadline_on: 1.month.from_now.to_date,
      questions_attributes: { "0" => { prompt: "Objectifs atteints", rating: "1", comment: "1" }, "1" => { prompt: "Ajoutée à la main", rating: "0", comment: "1" } } } }
    campaign = Campaign.find_by!(name: "Copie")
    assert_equal [ "Objectifs atteints", "Ajoutée à la main" ], campaign.questions.map(&:prompt)

    template.update!(items_attributes: [ { id: template.items.first.id, prompt: "Changé" } ])
    template.destroy!
    assert_equal [ "Objectifs atteints", "Ajoutée à la main" ], campaign.reload.questions.map(&:prompt)
  end

  test "the edit form of a draft has no template picker" do
    get edit_campaign_path(campaigns(:draft_campaign))
    assert_select "select#template_id", count: 0
    assert_select "[data-nested-form-target=container] .question", count: campaigns(:draft_campaign).questions.count
  end

  def checked_ids(list)
    css_select("input[type=checkbox][name='campaign[#{list}_contact_ids][]'][checked]").map { |box| box["value"].to_i }
  end

  test "new form lists my contacts by role, all unchecked, with a template per list" do
    get new_campaign_path
    assert_response :success
    assert_select "input[name='campaign[subject_contact_ids][]'][type=checkbox]", count: 2 # Dana, Eli
    assert_select "input[name='campaign[respondent_contact_ids][]'][type=checkbox]", count: 3 # Dana, Rose, Sam
    assert_select "input[type=checkbox][value='#{contacts(:fred).id}']", count: 0
    assert_empty checked_ids(:subject) + checked_ids(:respondent)
    assert_select "input[type=hidden][name='campaign[subject_contact_ids][]'][value='']"
    assert_select "button[data-action='check-all#check']", text: "Tout cocher", count: 2
    assert_select "[data-nested-form-target=container] .contact", count: 0
    assert_select "template input[name='campaign[new_subject_contacts][NEW_RECORD][name]']"
    assert_select "template .contact input[type=checkbox][checked]:not([name])", count: 2
    assert_select "template input[name='campaign[questions_attributes][NEW_RECORD][prompt]']"
    assert_select "button[data-action='nested-form#add']", text: "Nouveau contact", count: 2
  end

  test "edit form checks the contacts already in the campaign" do
    get edit_campaign_path(campaigns(:draft_campaign))
    assert_equal [ contacts(:dana).id ], checked_ids(:subject)
    assert_equal [ contacts(:rose).id ], checked_ids(:respondent)
    assert_select "[data-nested-form-target=container] .question", count: campaigns(:draft_campaign).questions.count
  end

  test "an empty directory points to the team screen" do
    sign_out :manager
    sign_in managers(:bob)
    get new_campaign_path
    assert_select ".picker-empty", text: /Aucun sondable/ do
      assert_select "a[href='#{team_path}']"
    end
    assert_select "input[name='campaign[subject_contact_ids][]'][type=checkbox]", count: 1 # Fred
  end

  test "create with selected contacts, a new contact, a default question left out and blank rows ignored" do
    post campaigns_path, params: { campaign: {
      name: "Dynamique", deadline_on: 20.days.from_now.to_date,
      subject_contact_ids: [ "", contacts(:dana).id, contacts(:eli).id ],
      respondent_contact_ids: [ "", contacts(:rose).id ],
      new_respondent_contacts: { "1700000000001" => { name: "Hugo", email: "hugo@example.com" },
                                 "1700000000002" => { name: "", email: "" } },
      questions_attributes: { "1" => { prompt: "Première", rating: "1", comment: "0", _destroy: "0" },
                              "2" => { prompt: "Seconde", rating: "0", comment: "1", _destroy: "0" } }
    } }
    campaign = Campaign.order(:id).last
    assert_redirected_to campaign_path(campaign)
    assert_equal [ "Dana Managée", "Eli Managé" ], campaign.subjects.order(:name).map(&:name)
    assert_equal [ "Hugo", "Rose Sondée" ], campaign.respondents.order(:name).map(&:name)
    hugo = managers(:alice).contacts.find_by!(email: "hugo@example.com")
    assert hugo.surveyable?
    assert_equal [ [ "Première", 0 ], [ "Seconde", 1 ] ], campaign.questions.map { |q| [ q.prompt, q.position ] }
  end

  test "update adds a question, removes a persisted one and unchecks a subject" do
    campaign = campaigns(:draft_campaign)
    existing = campaign.questions.first
    patch campaign_path(campaign), params: { campaign: {
      questions_attributes: { "0" => { id: existing.id, prompt: existing.prompt, rating: "1", comment: "1", _destroy: "1" },
                              "1700000000001" => { prompt: "Ajoutée", rating: "1", comment: "0", _destroy: "0" } },
      subject_contact_ids: [ "" ],
      respondent_contact_ids: [ "", contacts(:rose).id ]
    } }
    assert_redirected_to campaign_path(campaign)
    campaign.reload
    assert_not_includes campaign.questions, existing
    assert_equal "Ajoutée", campaign.questions.last.prompt
    assert_equal (0...campaign.questions.size).to_a, campaign.questions.map(&:position)
    assert_equal 0, campaign.subjects.count
    assert Contact.exists?(contacts(:dana).id)
    assert_equal [ respondents(:draft_rose).id ], campaign.respondents.ids
  end

  test "a failed create keeps the checked boxes, the new contacts and the questions" do
    post campaigns_path, params: { campaign: {
      name: "", deadline_on: 20.days.from_now.to_date,
      subject_contact_ids: [ "", contacts(:eli).id ],
      new_subject_contacts: { "5" => { name: "Gina", email: "gina@example.com" } },
      questions_attributes: { "7" => { prompt: "Seule question", rating: "1", comment: "0", _destroy: "0" } }
    } }
    assert_response :unprocessable_entity
    assert_equal [ contacts(:eli).id ], checked_ids(:subject)
    assert_empty checked_ids(:respondent)
    assert_select "[data-nested-form-target=container] input[value='Gina']", count: 1
    assert_select "[data-nested-form-target=container] .contact", count: 1
    assert_select "[data-nested-form-target=container] .question", count: 1
    assert_select "[data-nested-form-target=container] input[value='Seule question']"
    assert_not Contact.exists?(email: "gina@example.com")
  end

  test "a failed update keeps an unchecked contact unchecked and changes nothing" do
    campaign = campaigns(:draft_campaign)
    patch campaign_path(campaign), params: { campaign: { name: "", subject_contact_ids: [ "" ] } }
    assert_response :unprocessable_entity
    assert_empty checked_ids(:subject)
    assert_equal [ contacts(:rose).id ], checked_ids(:respondent)
    assert_equal [ subjects(:draft_dana) ], campaign.reload.subjects.to_a
  end

  test "an invalid new contact is shown on its row and nothing is saved" do
    campaign = campaigns(:draft_campaign)
    assert_no_difference [ "Contact.count", "Respondent.count" ] do
      patch campaign_path(campaign), params: { campaign: {
        respondent_contact_ids: [ "", contacts(:rose).id, contacts(:sam).id ],
        new_respondent_contacts: { "1" => { name: "Zoé", email: "pas-un-email" } }
      } }
    end
    assert_response :unprocessable_entity
    assert_select ".callout-alert li", /Nouveau contact « Zoé »/
    assert_select ".contact.has-error input[value='pas-un-email']"
    assert_select ".contact.has-error input[type=checkbox][checked]:not([name])", count: 1
    assert_equal [ contacts(:rose).id, contacts(:sam).id ].sort, checked_ids(:respondent).sort
  end

  test "a new contact with an email already in the directory checks the existing contact" do
    patch campaign_path(campaigns(:draft_campaign)), params: { campaign: {
      new_subject_contacts: { "1" => { name: "Sam encore", email: "SAM@example.com" } }
    } }
    assert_redirected_to campaign_path(campaigns(:draft_campaign))
    assert contacts(:sam).reload.managed?
    assert_includes campaigns(:draft_campaign).subjects.map(&:contact_id), contacts(:sam).id
  end

  test "create a valid campaign" do
    assert_difference "Campaign.count", 1 do
      post campaigns_path, params: { campaign: {
        name: "Fin d'année", deadline_on: 20.days.from_now.to_date,
        subject_contact_ids: [ "", contacts(:eli).id ],
        respondent_contact_ids: [ "", contacts(:sam).id ],
        questions_attributes: { "0" => { prompt: "Note globale", rating: "1", comment: "0", position: 0 } }
      } }
    end
    campaign = Campaign.order(:id).last
    assert_redirected_to campaign_path(campaign)
    assert_equal managers(:alice), campaign.manager
    assert campaign.draft?
    assert_equal 1, campaign.subjects.count
  end

  test "create with a missing name re-renders the form" do
    assert_no_difference "Campaign.count" do
      post campaigns_path, params: { campaign: { name: "", deadline_on: 20.days.from_now.to_date } }
    end
    assert_response :unprocessable_entity
    assert_select "main form .callout-alert li"
    assert_select ".toasts", count: 0
  end

  test "another manager's campaign behaves as if it did not exist" do
    other = campaigns(:bobs_campaign)
    [
      [ :get, campaign_path(other) ],
      [ :patch, campaign_path(other), { campaign: { name: "Piratée" } } ],
      [ :post, launch_campaign_path(other) ],
      [ :delete, campaign_path(other) ]
    ].each do |verb, path, params|
      sign_in managers(:alice) # la session de test n'est pas conservée après une 404
      send(verb, path, params: params)
      assert_response :not_found, "#{verb} #{path}"
    end
    assert_equal "Campagne de Bob", other.reload.name
    assert other.draft?
  end

  test "launching sends invitations and freezes editing" do
    campaign = campaigns(:draft_campaign)
    assert_enqueued_emails campaign.respondents.count do
      post launch_campaign_path(campaign)
    end
    assert_redirected_to campaign_path(campaign)
    assert campaign.reload.running?
    get edit_campaign_path(campaign)
    assert_redirected_to campaign_path(campaign)
  end

  test "launching without respondents is refused" do
    campaign = campaigns(:draft_campaign)
    campaign.respondents.destroy_all
    assert_no_enqueued_emails { post launch_campaign_path(campaign) }
    assert campaign.reload.draft?
    follow_redirect!
    assert_select ".flash-alert"
  end

  test "closing a running campaign" do
    post close_campaign_path(campaigns(:running_campaign))
    assert campaigns(:running_campaign).reload.closed?
  end

  test "show displays each respondent status and the response rate" do
    campaign = campaigns(:running_campaign)
    respondents(:rose).update!(submitted_at: Time.current)
    answers = Answer.create!(respondent: respondents(:sam), subject: subjects(:dana), question: questions(:strengths), body: "Super")
    get campaign_path(campaign)
    assert_response :success
    assert_select "#response-rate", /1 \/ 3 réponses soumises/
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:rose))}", /A répondu/
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:sam))}", /Réponse partielle/
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:dana_as_respondent))}", /Pas encore répondu/
  end

  test "show offers a resend button only to respondents who can still answer" do
    respondents(:rose).update!(submitted_at: Time.current)
    respondents(:sam).update!(last_invited_at: Time.zone.local(2026, 10, 20, 9, 30))
    get campaign_path(campaigns(:running_campaign))
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:rose))} form", count: 0
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:sam))} form[action='#{resend_campaign_respondent_path(campaigns(:running_campaign), respondents(:sam))}']"
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:sam))}", /20 oct\./
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:dana_as_respondent))}", /—/
  end

  test "show has no resend button outside a running campaign" do
    get campaign_path(campaigns(:draft_campaign))
    assert_select "button", text: "Renvoyer", count: 0
    assert_select "th", text: "Invité le"
  end
end
