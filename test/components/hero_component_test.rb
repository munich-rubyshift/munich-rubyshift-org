require "test_helper"
require "view_component/test_helpers"

class HeroComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  def test_shows_next_meetup
    travel_to Date.new(2026, 4, 1) do
      render_inline(HeroComponent.new)
    end

    assert_selector ".hero h1"
    assert_selector ".section-title", text: "Next meetup"
    assert_selector ".events---event-card-featured"
  end

  def test_falls_back_to_latest_meetup
    travel_to Date.new(2030, 1, 1) do
      render_inline(HeroComponent.new)
    end

    assert_selector ".section-title", text: "Latest meetup"
    assert_selector ".events---event-card"
    assert_no_selector ".events---event-card-featured"
  end
end
