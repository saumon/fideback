require "test_helper"
require "application_system_test_case"

class ConfirmDialogTest < ApplicationSystemTestCase
  setup do
    visit new_manager_session_path
    fill_in "E-mail", with: "alice@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes"
    @running = campaigns(:running_campaign)
    @draft = campaigns(:draft_campaign)
  end

  teardown { page.driver.browser.manage.window.resize_to(*SCREEN_SIZE) }

  def active_element(attribute)
    evaluate_script("document.activeElement.#{attribute}")
  end

  def dialog_rect
    evaluate_script("(() => { const r = document.querySelector('dialog.confirm').getBoundingClientRect(); return { left: r.left, right: r.right, bottom: r.bottom, width: r.width, vw: document.documentElement.clientWidth, vh: innerHeight, scroll: document.documentElement.scrollWidth } })()")
  end

  test "the dialog shows the title, the detail and the label of the clicked button, without a native alert" do
    visit campaign_path(@running)
    click_on "Clôturer la campagne"
    wait_for_confirm_dialog

    within DIALOG do
      assert_selector "h2", text: "Clôturer la campagne ?"
      assert_text "Les sondés ne pourront plus répondre"
      assert_selector "button[value=ok]", text: "Clôturer la campagne"
      assert_selector "button[value=cancel]", text: "Non, revenir"
    end
  end

  test "confirming runs the action" do
    visit campaign_path(@running)
    click_on "Clôturer la campagne"
    accept_confirm_dialog

    assert_selector ".toast", text: "Campagne clôturée."
    assert @running.reload.closed?
  end

  test "the back button, Escape and the backdrop dismiss without running the action" do
    visit campaign_path(@running)

    click_on "Clôturer la campagne"
    dismiss_confirm_dialog
    assert_equal "Clôturer la campagne", active_element("textContent.trim()"), "le focus revient sur le bouton d'origine"

    click_on "Clôturer la campagne"
    wait_for_confirm_dialog
    page.driver.browser.action.send_keys(:escape).perform
    assert_no_selector DIALOG

    click_on "Clôturer la campagne"
    wait_for_confirm_dialog
    page.driver.browser.action.move_to_location(8, 8).click.perform
    assert_no_selector DIALOG

    assert_selector "h1", text: "Campagne en cours"
    assert @running.reload.running?
  end

  test "an irreversible action is red and starts on the back button" do
    visit campaign_path(@draft)
    click_on "Supprimer"
    wait_for_confirm_dialog

    assert_selector "#{DIALOG}[data-tone=danger] button.btn-solid-danger[value=ok]", text: "Supprimer"
    assert_equal "cancel", active_element("value")
    dismiss_confirm_dialog
    assert Campaign.exists?(@draft.id)

    click_on "Supprimer"
    accept_confirm_dialog
    assert_selector ".toast", text: /supprimée/i
    assert_not Campaign.exists?(@draft.id)
  end

  test "a common action starts on the confirmation button, which is not red" do
    visit campaign_path(@draft)
    click_on "Lancer la campagne"
    wait_for_confirm_dialog

    assert_equal "ok", active_element("value")
    assert_no_selector "#{DIALOG} .btn-solid-danger"
    dismiss_confirm_dialog
    assert @draft.reload.draft?
  end

  # En sortant du dernier bouton, le navigateur rend le focus à son interface : le corps de la page, jamais son contenu.
  test "Tab never puts the focus on the page behind the dialog" do
    visit campaign_path(@running)
    click_on "Clôturer la campagne"
    wait_for_confirm_dialog

    6.times do
      page.driver.browser.action.send_keys(:tab).perform
      assert evaluate_script("!!document.activeElement.closest('dialog.confirm') || document.activeElement === document.body"),
             "le focus est passé sur la page en dessous"
    end
  end

  test "the dialog is named by its title and described by its detail" do
    visit campaign_path(@running)
    click_on "Clôturer la campagne"
    wait_for_confirm_dialog

    assert_equal "Clôturer la campagne ?", evaluate_script("document.getElementById(document.querySelector('dialog.confirm').getAttribute('aria-labelledby')).textContent")
    assert_match(/ne pourront plus répondre/, evaluate_script("document.getElementById(document.querySelector('dialog.confirm').getAttribute('aria-describedby')).textContent"))
    assert evaluate_script("document.querySelector('dialog.confirm').matches(':modal')")
  end

  test "on a wide screen the dialog is centered with a limited width and side by side buttons" do
    visit campaign_path(@running)
    click_on "Clôturer la campagne"
    wait_for_confirm_dialog

    rect = dialog_rect
    assert_operator rect["width"], :<=, 420
    assert_in_delta (rect["left"] + rect["right"]) / 2, rect["vw"] / 2, 2
    top_of = ->(value) { evaluate_script("document.querySelector('dialog.confirm button[value=#{value}]').getBoundingClientRect().top") }
    assert_in_delta top_of.call("ok"), top_of.call("cancel"), 2
  end

  test "on a phone the dialog is a bottom sheet with stacked buttons and no horizontal scroll" do
    page.driver.browser.manage.window.resize_to(380, 800)
    visit campaign_path(@running)
    click_on "Clôturer la campagne"
    wait_for_confirm_dialog

    rect = dialog_rect
    assert_in_delta 0, rect["left"], 1
    assert_in_delta rect["vw"], rect["right"], 1
    assert_in_delta rect["vh"], rect["bottom"], 1
    assert_operator rect["scroll"], :<=, rect["vw"]
    top_of = ->(value) { evaluate_script("document.querySelector('dialog.confirm button[value=#{value}]').getBoundingClientRect().top") }
    assert_operator top_of.call("ok"), :<, top_of.call("cancel"), "la confirmation est au-dessus du retrait"
  end

  test "reduced motion removes the opening and closing transitions" do
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [ { name: "prefers-reduced-motion", value: "reduce" } ])
    visit campaign_path(@running)
    click_on "Clôturer la campagne"
    wait_for_confirm_dialog

    assert_equal "0s", evaluate_script("getComputedStyle(document.querySelector('dialog.confirm')).transitionDuration.split(', ')[0]")
  end

  test "a browser without modal dialogs falls back to the native confirmation" do
    visit campaign_path(@running)
    execute_script("HTMLDialogElement.prototype.showModal = undefined")

    accept_confirm("Clôturer la campagne ?") { click_on "Clôturer la campagne" }

    assert_selector ".toast", text: "Campagne clôturée."
    assert @running.reload.closed?
  end

  test "dismissing the native confirmation of the fallback keeps the action from running" do
    visit campaign_path(@running)
    execute_script("HTMLDialogElement.prototype.showModal = undefined")

    dismiss_confirm("Clôturer la campagne ?") { click_on "Clôturer la campagne" }

    assert @running.reload.running?
  end
end
