require "test_helper"

class BrandMarkTest < ActionDispatch::IntegrationTest
  def assert_brand_mark
    assert_select ".site-header .brand#brand[data-controller=brand-mark]", count: 1
    assert_select ".site-header .brand svg.brand-mark[aria-hidden=true][focusable=false]", count: 1
    assert_select ".site-header .brand svg.brand-mark path.bubble-back", count: 1
    assert_select ".site-header .brand svg.brand-mark path.bubble-front", count: 1
    assert_select ".site-header .brand svg.brand-mark circle.typing", count: 3
    assert_select ".site-header .brand svg.brand-mark g.arrive-back g.sway-back path.bubble-back", count: 1
    assert_select ".site-header .brand svg.brand-mark g.arrive-front g.sway-front path.bubble-front", count: 1
    assert_select ".site-header .brand-dots", count: 0
    assert_select ".site-header .brand-name", text: "Fideback", count: 1
    assert_select ".site-header .brand-name *", count: 0
  end

  test "the manager header shows the two bubbles instead of the six dots" do
    get root_path
    assert_brand_mark

    sign_in managers(:alice)
    get campaigns_path
    assert_brand_mark
  end

  test "the respondent header shows the same mark" do
    get respondent_form_path(token: respondents(:rose).token)

    assert_brand_mark
  end

  test "the logo link is still named Fideback and leads home" do
    get root_path

    assert_select "a.brand#brand[href=?]", root_path, text: "Fideback"
  end

  test "the mark crops its view box to the drawing so its bottom is the bottom of the tail" do
    get root_path

    assert_select "svg.brand-mark[viewBox='0.9 2.9 46.2 36.3']"
  end
end
