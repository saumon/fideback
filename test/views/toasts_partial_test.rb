require "test_helper"

class ToastsPartialTest < ActionView::TestCase
  test "renders each text message and leaves out non-text flash values" do
    controller.flash[:notice] = "Connecté(e)."
    controller.flash[:alert] = "Email ou mot de passe incorrect."
    controller.flash[:timedout] = true
    render partial: "layouts/toasts"

    assert_select ".toast", count: 2
    assert_select ".toast.flash-notice", text: /Connecté/
    assert_select ".toast.flash-alert[role=alert]", text: /incorrect/
    assert_select ".toast", text: /true/, count: 0
  end
end
