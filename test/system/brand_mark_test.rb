require "test_helper"
require "application_system_test_case"

class BrandMarkTest < ApplicationSystemTestCase
  SAFFRON = "rgb(255, 182, 39)".freeze

  teardown { page.driver.browser.manage.window.resize_to(*SCREEN_SIZE) }

  def sign_in_as_alice
    visit new_manager_session_path
    fill_in "E-mail", with: "alice@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes"
  end

  # Réponse d'un test au bout d'un délai : le bloc doit rendre vrai avant l'expiration de l'attente de Capybara.
  def eventually(message)
    page.document.synchronize { raise Capybara::ElementNotFound, message unless yield }
  end

  def animations(selector, name)
    evaluate_script("document.querySelector(#{selector.to_json}).getAnimations().filter((a) => a.animationName === #{name.to_json}).map((a) => a.playState)")
  end

  def running_arrivals
    evaluate_script("[...document.querySelectorAll('#brand .brand-mark *')].flatMap((e) => e.getAnimations()).filter((a) => a.animationName === 'bubble-in' && a.playState === 'running').length")
  end

  def front_fill
    evaluate_script("getComputedStyle(document.querySelector('#brand .bubble-front')).fill")
  end

  # Le bas du SVG moins la ligne de base du texte, mesurée avec un élément de taille nulle ajouté comme enfant de .brand
  # (aligné par la ligne de base avec le nom, sans toucher au logotype qui doit rester d'un seul tenant).
  def baseline_gap
    evaluate_script(<<~JS)
      (() => {
        const brand = document.querySelector("#brand")
        const probe = document.createElement("i")
        probe.style.cssText = "display:inline-block;width:0;height:0"
        brand.appendChild(probe)
        const baseline = probe.getBoundingClientRect().bottom
        probe.remove()
        return document.querySelector("#brand .brand-mark").getBoundingClientRect().bottom - baseline
      })()
    JS
  end

  def header_height
    evaluate_script("document.querySelector('.site-header').getBoundingClientRect().height")
  end

  test "the two bubbles show in the manager and respondent spaces" do
    visit root_path
    assert_selector "#brand svg.brand-mark path.bubble-back"
    assert_selector "#brand svg.brand-mark path.bubble-front"
    assert_selector "#brand svg.brand-mark circle.typing", count: 3
    assert_no_selector ".brand-dots"

    visit respondent_form_path(token: respondents(:rose).token)
    assert_selector "#brand svg.brand-mark path.bubble-back"
    assert_selector "#brand svg.brand-mark circle.typing", count: 3
  end

  test "the arrival plays on load and then settles" do
    visit root_path

    assert_operator running_arrivals, :>=, 1
    eventually("l'arrivée ne se termine pas") { running_arrivals.zero? }
    assert evaluate_script("document.documentElement.hasAttribute('data-brand-arrived')"), "l'arrivée n'est pas notée sur <html>"
    assert_selector "#brand .bubble-back"
  end

  test "the typing dots keep pulsing well beyond five seconds" do
    visit root_path
    sleep 6

    states = evaluate_script("[...document.querySelectorAll('#brand .typing')].map((dot) => dot.getAnimations().filter((a) => a.animationName === 'typing').map((a) => a.playState)).flat()")
    assert_equal [ "running" ] * 3, states
  end

  test "the front bubble keeps changing colour while the back one stays pink" do
    visit root_path
    eventually("l'arrivée ne se termine pas") { running_arrivals.zero? }

    first = front_fill
    sleep 2.6 # chaque couleur tient moins de 2,4 s
    assert_not_equal first, front_fill
    assert_equal "rgb(255, 93, 143)", evaluate_script("getComputedStyle(document.querySelector('#brand .bubble-back')).fill")
  end

  test "hovering sways the bubbles without replaying the arrival or restarting the colour cycle" do
    visit root_path
    eventually("l'arrivée ne se termine pas") { running_arrivals.zero? }
    execute_script("window.__voices = document.querySelector('#brand .bubble-front').getAnimations().find((a) => a.animationName === 'voices'); window.__before = window.__voices.currentTime")

    find("#brand").hover
    eventually("le balancement ne démarre pas") { animations("#brand .sway-back", "sway").include?("running") }
    page.driver.browser.action.move_to_location(700, 600).perform
    eventually("le balancement ne s'arrête pas") { animations("#brand .sway-back", "sway").none? { |state| state == "running" } }

    assert_equal 0, running_arrivals, "l'arrivée a été rejouée"
    assert_equal "running", evaluate_script("window.__voices.playState")
    assert_operator evaluate_script("window.__voices.currentTime"), :>, evaluate_script("window.__before"), "le défilé de couleurs est reparti de zéro"
    assert_equal [ "running" ] * 3, evaluate_script("[...document.querySelectorAll('#brand .typing')].map((dot) => dot.getAnimations().filter((a) => a.animationName === 'typing').map((a) => a.playState)).flat()")
  end

  test "keyboard focus on the logo sways the bubbles like a hover" do
    visit root_path
    eventually("l'arrivée ne se termine pas") { running_arrivals.zero? }

    page.driver.browser.action.send_keys(:tab).perform
    assert evaluate_script("document.activeElement.id") == "brand", "le logo n'est pas le premier élément focalisable"
    eventually("le balancement ne démarre pas au focus") { animations("#brand .sway-back", "sway").include?("running") }
  end

  test "reduced motion shows the final mark without any animation" do
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [ { name: "prefers-reduced-motion", value: "reduce" } ])
    visit root_path
    sleep 1

    assert_equal 0, evaluate_script("document.querySelectorAll('#brand .brand-mark *').length && [...document.querySelectorAll('#brand .brand-mark *')].flatMap((e) => e.getAnimations()).length")
    assert_equal SAFFRON, front_fill
    find("#brand").hover
    sleep 0.3
    assert_equal 0, evaluate_script("[...document.querySelectorAll('#brand .brand-mark *')].flatMap((e) => e.getAnimations()).length")
    assert_selector "#brand circle.typing", count: 3
  end

  test "the arrival is not replayed when navigating to another page" do
    sign_in_as_alice
    eventually("l'arrivée ne se termine pas") { running_arrivals.zero? && evaluate_script("document.documentElement.hasAttribute('data-brand-arrived')") }
    execute_script("window.__page = document.body")

    click_on "Mon équipe", match: :first
    assert_selector "h1", text: /équipe/i
    assert evaluate_script("window.__page !== document.body"), "la page n'a pas été remplacée par Turbo"

    assert_selector "#brand svg.brand-mark"
    assert_equal 0, running_arrivals, "l'arrivée a été rejouée"
    assert_selector "#brand .typing", count: 3
  end

  test "the bottom of the mark sits on the baseline of the name on a wide screen" do
    visit root_path
    eventually("la marque n'est pas affichée") { evaluate_script("document.querySelector('#brand .brand-mark').getBoundingClientRect().height") > 0 }

    assert_in_delta 0, baseline_gap, 1.0
  end

  [ [ 380, "a phone" ], [ 360, "a very small phone" ] ].each do |width, label|
    test "on #{label} the mark keeps its place on the baseline and the header fits one line" do
      page.driver.browser.manage.window.resize_to(width, 760)
      visit root_path
      assert_selector "#brand svg.brand-mark"
      assert_selector ".nav-toggle", visible: :visible
      assert_selector ".header-end > .btn", text: "Créer un compte"

      assert_in_delta 0, baseline_gap, 1.0
      assert_operator header_height, :<, 80, "l'en-tête passe sur plusieurs lignes"
      assert_operator evaluate_script("document.documentElement.scrollWidth"), :<=, evaluate_script("innerWidth")
      assert_operator evaluate_script("document.querySelector('#brand .brand-mark').getBoundingClientRect().height"), :>, 0
    end
  end

  # Avant la marque à bulles, la ligne du logo valait 1,55 fois la police (interligne du site) : l'en-tête ne doit pas dépasser cela.
  test "the mark does not make the header taller than it was with the six dots" do
    visit root_path
    eventually("la marque n'est pas affichée") { evaluate_script("document.querySelector('#brand .brand-mark').getBoundingClientRect().height") > 0 }

    former = evaluate_script(<<~JS)
      (() => {
        const header = getComputedStyle(document.querySelector(".site-header"))
        const brand = parseFloat(getComputedStyle(document.querySelector("#brand")).fontSize)
        return parseFloat(header.paddingTop) + parseFloat(header.paddingBottom) + parseFloat(header.borderBottomWidth) + 1.55 * brand
      })()
    JS

    assert_operator header_height, :<=, former + 1
  end
end
