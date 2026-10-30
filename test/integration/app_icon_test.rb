require "test_helper"

class AppIconTest < ActionDispatch::IntegrationTest
  test "manager and respondent pages declare the app icon" do
    get root_path
    assert_icon_links

    get respondent_form_path(token: respondents(:rose).token)
    assert_icon_links
  end

  test "static error pages declare the app icon" do
    %w[400 404 406-unsupported-browser 422 500].each do |page|
      html = Rails.public_path.join("#{page}.html").read
      assert_includes html, %(<link rel="icon" href="/icon.svg" type="image/svg+xml">), "#{page}.html"
    end
  end

  test "the implicit favicon request is answered" do
    get "/favicon.ico"
    assert_response :success
  end

  test "binary icons are generated from the svg source" do
    assert_equal "\x00\x00\x01\x00".b, Rails.public_path.join("favicon.ico").binread(4)
    assert_equal "\x89PNG".b, Rails.public_path.join("apple-touch-icon.png").binread(4)
    assert_includes Rails.public_path.join("icon.svg").read, "prefers-color-scheme: dark"
  end

  private
    def assert_icon_links
      assert_select "link[rel=icon][href='/icon.svg'][type='image/svg+xml']"
      assert_select "link[rel=icon][href='/icon.png']"
      assert_select "link[rel=apple-touch-icon][href='/apple-touch-icon.png']"
    end
end
