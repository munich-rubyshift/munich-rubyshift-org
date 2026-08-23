require "test_helper"
require "view_component/test_helpers"

class Entities::PersonComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  # def test_manually_rendered_component
  #   render_inline(Entities::PersonComponent.new(Entities::Person.find_by!(slug: "klaus-weidinger")))

  #   assert_selector ".entities---person"
  #   # TODO: better assertions
  # end

  # # https://viewcomponent.org/guide/previews.html#previews-as-test-cases
  # def test_component_from_view_component_preview
  #   render_preview(:default)

  #   assert_selector ".entities---person"
  #   # TODO: better assertions
  # end
end
