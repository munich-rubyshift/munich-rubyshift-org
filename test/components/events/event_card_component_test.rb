require "test_helper"
require "view_component/test_helpers"

class Events::EventCardComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  def test_compact_card
    event = events_events(:one)
    render_inline(Events::EventCardComponent.new(event))

    assert_selector ".events---event-card"
    assert_no_selector ".events---event-card-featured"
    assert_selector ".events---event-card--title a", text: event.title
    assert_selector ".events---event-card--talks li", count: event.talks.count
    assert_no_selector ".events---event-card--actions"
  end

  def test_featured_card_has_actions
    render_inline(Events::EventCardComponent.new(events_events(:one), featured: true))

    assert_selector ".events---event-card-featured.origami-paper"
    assert_selector ".events---event-card--actions a.button", text: "Event details"
  end

  def test_cancelled_card
    event = events_events(:one)
    event.status = "cancelled"
    render_inline(Events::EventCardComponent.new(event))

    assert_selector ".events---event-card-cancelled"
    assert_selector ".tag", text: "Cancelled"
  end
end
