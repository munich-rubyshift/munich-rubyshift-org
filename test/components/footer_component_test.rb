require "test_helper"
require "view_component/test_helpers"

class FooterComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  def test_manually_rendered_component
    render_inline(FooterComponent.new)

    assert_selector ".footer"
    # TODO: better assertions
  end

  # https://viewcomponent.org/guide/previews.html#previews-as-test-cases
  def test_component_from_view_component_preview
    render_preview(:default)

    assert_selector ".footer"
    # TODO: better assertions
  end
end
