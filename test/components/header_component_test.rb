require "test_helper"
require "view_component/test_helpers"

class HeaderComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  def test_manually_rendered_component
    render_inline(HeaderComponent.new)

    assert_selector ".header"
    # TODO: better assertions
  end

  # https://viewcomponent.org/guide/previews.html#previews-as-test-cases
  def test_component_from_view_component_preview
    render_preview(:default)

    assert_selector ".header"
    # TODO: better assertions
  end
end
