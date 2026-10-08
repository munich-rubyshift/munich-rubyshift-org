require "test_helper"
require "view_component/test_helpers"

class HeaderComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  def test_manually_rendered_component
    render_inline(HeaderComponent.new)

    assert_selector ".header"
    # TODO: better assertions
  end

  def test_marks_the_current_section
    with_request_url "/events/meetup-2026-04-23" do
      render_inline(HeaderComponent.new)
    end

    assert_selector "a.header--link-current", count: 1
    assert_selector "a.header--link-current", text: "Events"
  end

  def test_marks_home_on_the_root_page
    with_request_url "/" do
      render_inline(HeaderComponent.new)
    end

    assert_selector "a.header--link-current", text: "Home"
  end

  # https://viewcomponent.org/guide/previews.html#previews-as-test-cases
  def test_component_from_view_component_preview
    render_preview(:default)

    assert_selector ".header"
    # TODO: better assertions
  end
end
