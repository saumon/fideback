require "test_helper"

class TeamTest < ActionDispatch::IntegrationTest
  setup { sign_in managers(:alice) }

  def row(contact, **changes)
    { id: contact.id, name: contact.name, email: contact.email,
      managed: contact.managed? ? "1" : "0", surveyable: contact.surveyable? ? "1" : "0", _destroy: "0" }.merge(changes)
  end

  test "the main navigation links to the team screen" do
    get campaigns_path
    assert_select "nav a[href='#{team_path}']", text: "Mon équipe"
  end

  test "lists my contacts sorted by name with their roles, a blank row and a template" do
    get team_path
    assert_response :success
    names = css_select("[data-nested-form-target=container] input[name$='[name]']").map { |input| input["value"] }
    assert_equal [ "Dana Managée", "Eli Managé", "Rose Sondée", "Sam Sondé", nil ], names
    assert_select "input[value='Fred Managé']", count: 0
    assert_select "[data-nested-form-target=container] .team-row[data-new-record=true]", count: 1
    assert_select "input[type=checkbox][name='manager[contacts_attributes][0][managed]'][checked]"
    assert_select "input[type=checkbox][name='manager[contacts_attributes][0][surveyable]'][checked]"
    assert_select "template input[name='manager[contacts_attributes][NEW_RECORD][email]']"
    assert_select "button[data-role-filter-target=choice]", count: 3
  end

  test "adds, edits and removes contacts in one save, ignoring blank rows" do
    patch team_path, params: { manager: { contacts_attributes: {
      "0" => row(contacts(:eli), name: "Eli Renommé", surveyable: "1"),
      "1" => row(contacts(:sam), _destroy: "1"),
      "1700000000001" => { name: "Nina", email: "NINA@example.com", managed: "0", surveyable: "1", _destroy: "0" },
      "1700000000002" => { name: "", email: "", managed: "0", surveyable: "0", _destroy: "0" }
    } } }
    assert_redirected_to team_path
    follow_redirect!
    assert_select ".toast", /Équipe enregistrée/

    alice = managers(:alice)
    assert_equal [ "Dana Managée", "Eli Renommé", "Nina", "Rose Sondée" ], alice.contacts.map(&:name)
    assert contacts(:eli).reload.surveyable?
    assert_equal "nina@example.com", alice.contacts.find_by!(name: "Nina").email
  end

  test "a refused save keeps the input, hides removed rows and saves nothing" do
    assert_no_difference "Contact.count" do
      patch team_path, params: { manager: { contacts_attributes: {
        "0" => row(contacts(:eli), name: "Eli Renommé"),
        "1" => row(contacts(:sam), _destroy: "1"),
        "1700000000001" => { name: "Sans rôle", email: "sans-role@example.com", managed: "0", surveyable: "0", _destroy: "0" },
        "1700000000002" => { name: "Doublon", email: "rose@example.com", managed: "1", surveyable: "0", _destroy: "0" }
      } } }
    end
    assert_response :unprocessable_entity
    assert_select ".callout-alert", /corrigez les lignes signalées/
    assert_select "input[value='Eli Renommé']"
    assert_select ".team-row[hidden] input[value='Sam Sondé']"
    assert_select ".team-row.has-error input[value='Sans rôle']"
    assert_select ".team-row.has-error .row-error", /managé, sondable ou les deux/
    assert_select ".team-row.has-error input[value='Doublon']"
    assert_select "[data-nested-form-target=container] .team-row[data-new-record=true]", count: 2 # pas de ligne vide en plus
    assert_equal "Eli Managé", contacts(:eli).reload.name
    assert Contact.exists?(contacts(:sam).id)
  end

  test "another manager's contact ids are ignored" do
    fred = contacts(:fred)
    patch team_path, params: { manager: { contacts_attributes: {
      "0" => { id: fred.id, name: "Piraté", email: fred.email, managed: "1", _destroy: "0" },
      "1" => { id: fred.id, _destroy: "1" }
    } } }
    assert_redirected_to team_path
    assert_equal "Fred Managé", fred.reload.name
  end

  test "the same email is accepted in two managers' directories" do
    patch team_path, params: { manager: { contacts_attributes: {
      "1" => { name: "Fred chez Alice", email: "fred@example.com", managed: "1", _destroy: "0" }
    } } }
    assert_redirected_to team_path
    assert_equal 2, Contact.where(email: "fred@example.com").count
  end

  test "requires a signed-in manager" do
    sign_out :manager
    get team_path
    assert_redirected_to new_manager_session_path
  end
end
