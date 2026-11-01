require "test_helper"

class ConfirmDialogTest < ActionDispatch::IntegrationTest
  test "the dialog is rendered on a manager page" do
    sign_in managers(:alice)

    get campaigns_path

    assert_select "dialog.confirm[data-controller=confirm-dialog][aria-labelledby=confirm-title][aria-describedby=confirm-detail]", count: 1
    assert_select "dialog.confirm h2#confirm-title"
    assert_select "dialog.confirm button[value=cancel]", text: "Non, revenir"
    assert_select "dialog.confirm button[value=ok]"
  end

  test "the dialog is rendered on a respondent page" do
    get respondent_form_path(token: respondents(:rose).token)

    assert_select "dialog.confirm[data-controller=confirm-dialog]", count: 1
  end

  test "the dialog carries one icon template per pictogram" do
    sign_in managers(:alice)

    get campaigns_path

    %w[send lock check trash warning].each do |name|
      assert_select "dialog.confirm template[data-name=#{name}]", count: 1
    end
  end

  test "the campaign page carries the confirmation of each of its actions" do
    sign_in managers(:alice)

    get campaign_path(campaigns(:draft_campaign))
    assert_confirm "form[action=?]", launch_campaign_path(campaigns(:draft_campaign)),
                   title: "Envoyer les invitations aux sondés ?", detail: /lien personnel/, icon: "send", tone: nil
    assert_confirm "form[action=?]", campaign_path(campaigns(:draft_campaign)),
                   title: "Supprimer cette campagne ?", detail: /définitive/, icon: "trash", tone: "danger"

    running = campaigns(:running_campaign)
    get campaign_path(running)
    assert_confirm "form[action=?]", close_campaign_path(running),
                   title: "Clôturer la campagne ?", detail: /ne pourront plus répondre/, icon: "lock", tone: nil
    assert_confirm "form[action=?]", resend_campaign_respondent_path(running, respondents(:rose)),
                   title: "Renvoyer l'invitation à Rose Sondée ?", detail: /même lien/, icon: "send", tone: nil
  end

  test "the respondent form carries the confirmation of the final submission" do
    get respondent_form_path(token: respondents(:rose).token)

    assert_select "input[type=submit][value='Soumettre définitivement'][data-turbo-confirm='Soumettre vos réponses ?']" \
                  "[data-turbo-confirm-detail*='ne pourrez plus modifier'][data-turbo-confirm-icon=check]"
    assert_select "input[type=submit][value='Soumettre définitivement'][data-turbo-confirm-tone]", count: 0
  end

  test "the admin users page carries the confirmation of both invitation actions" do
    sign_in managers(:alice)
    invitation = Invitation.invite(name: "Pat Durand", email: "pat@example.com", by: managers(:alice))

    get admin_users_path

    assert_confirm "form[action=?]", resend_admin_invitation_path(invitation),
                   title: "Renvoyer l'invitation à Pat Durand ?", detail: /validité repart de zéro/, icon: "send", tone: nil
    assert_confirm "form[action=?]", admin_invitation_path(invitation),
                   title: "Annuler l'invitation de Pat Durand ?", detail: /cessera de fonctionner/, icon: "trash", tone: "danger"
  end

  test "the account page asks to delete the account with a precise detail" do
    sign_in managers(:alice)

    get edit_manager_registration_path

    assert_select "button[data-turbo-confirm='Supprimer votre compte ?'][data-turbo-confirm-tone=danger][data-turbo-confirm-icon=trash]" \
                  "[data-turbo-confirm-detail*='campagnes']", text: "Supprimer mon compte"
    assert_select "[data-confirm]", count: 0
    assert_no_match(/Êtes-vous sûr/, response.body)
  end

  private

  # Les attributs sont portés par le formulaire (button_to) ; `tone: nil` signifie ton neutre, donc sans attribut.
  def assert_confirm(selector, argument, title:, detail:, icon:, tone:)
    assert_select selector, argument do |forms|
      form = forms.first
      assert_equal title, form["data-turbo-confirm"]
      assert_match detail, form["data-turbo-confirm-detail"]
      assert_equal icon, form["data-turbo-confirm-icon"]
      tone ? assert_equal(tone, form["data-turbo-confirm-tone"]) : assert_nil(form["data-turbo-confirm-tone"])
    end
  end
end
