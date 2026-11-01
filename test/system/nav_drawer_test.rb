require "test_helper"
require "application_system_test_case"

class NavDrawerTest < ApplicationSystemTestCase
  setup do
    page.driver.browser.manage.window.resize_to(380, 760)
    visit new_manager_session_path
    fill_in "E-mail", with: "alice@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes"
  end

  teardown { page.driver.browser.manage.window.resize_to(*ApplicationSystemTestCase::SCREEN_SIZE) }

  def toggle = find("button.nav-toggle")
  def active_text = page.evaluate_script("document.activeElement.textContent.trim()")
  def inside_header? = page.evaluate_script("!!document.activeElement.closest('.site-header')")

  test "the entries are hidden behind the menu button until the drawer is opened" do
    assert_selector "button.nav-toggle[aria-expanded=false]"
    assert_no_selector "nav#site-nav a", text: "Mon équipe", visible: :visible

    toggle.click

    assert_selector "button.nav-toggle[aria-expanded=true][aria-label='Fermer le menu']"
    assert_selector "nav#site-nav a", text: "Mon équipe", visible: :visible
    assert_selector "nav#site-nav button", text: "Se déconnecter", visible: :visible
  end

  test "opening focuses the drawer, makes the page inert and stops it from scrolling" do
    toggle.click

    assert_equal "Mes campagnes", active_text
    assert page.evaluate_script("document.querySelector('main').inert")
    assert page.evaluate_script("document.documentElement.classList.contains('nav-open')")
  end

  test "the dimmed backdrop appears with the drawer, without delay" do
    toggle.click

    visibility = page.evaluate_script("getComputedStyle(document.querySelector('.nav-scrim')).visibility")
    delay = page.evaluate_script("getComputedStyle(document.querySelector('.nav-scrim')).transitionDelay")
    assert_equal "visible", visibility
    assert_match(/\A0s(, 0s)*\z/, delay)
  end

  test "Escape closes the drawer and gives the focus back to the button" do
    toggle.click
    assert_selector "nav#site-nav a", text: "Mon équipe", visible: :visible

    page.driver.browser.action.send_keys(:escape).perform

    assert_selector "button.nav-toggle[aria-expanded=false]"
    assert_no_selector "nav#site-nav a", text: "Mon équipe", visible: :visible
    assert_equal "button", page.evaluate_script("document.activeElement.tagName.toLowerCase()")
    assert_not page.evaluate_script("document.querySelector('main').inert")
  end

  test "a click on the dimmed backdrop closes the drawer" do
    toggle.click
    assert_selector "nav#site-nav a", text: "Mon équipe", visible: :visible

    page.execute_script("document.querySelector('.nav-scrim').dispatchEvent(new MouseEvent('click', { bubbles: true }))")

    assert_selector "button.nav-toggle[aria-expanded=false]"
  end

  test "Tab keeps the focus in the drawer" do
    toggle.click

    8.times do
      page.driver.browser.action.send_keys(:tab).perform
      assert inside_header?, "the focus left the header"
    end
  end

  test "following an entry opens the screen with the drawer closed" do
    toggle.click
    within("nav#site-nav") { click_on "Mon équipe" }

    assert_selector "h1", text: "Mon équipe"
    assert_selector "button.nav-toggle[aria-expanded=false]"
    assert_no_selector "nav#site-nav a", text: "Mon équipe", visible: :visible
  end

  test "going back after opening the drawer shows the screen with the drawer closed" do
    click_on "Nouvelle campagne", match: :first
    assert_selector "h1", text: "Nouvelle campagne" # le titre de la page quittée est aussi un h1 : sans texte, le clic suivant peut partir avant le changement de page
    toggle.click
    assert_selector "button.nav-toggle[aria-expanded=true]"
    within("nav#site-nav") { click_on "Mon équipe" }
    assert_selector "h1", text: "Mon équipe"

    page.go_back

    assert_selector "button.nav-toggle[aria-expanded=false]"
    assert_not page.evaluate_script("document.documentElement.classList.contains('nav-open')")
  end

  test "on a wide screen the navigation stays horizontal and the menu button is hidden" do
    page.driver.browser.manage.window.resize_to(1100, 760)

    assert_no_selector "button.nav-toggle", visible: :visible
    assert_selector "nav#site-nav a", text: "Mon équipe", visible: :visible
  end
end
