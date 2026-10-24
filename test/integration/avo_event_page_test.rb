require "test_helper"

class AvoEventPageTest < ActionDispatch::IntegrationTest
  test "an event page lists its CFPs" do
    event = events_events(:one)
    event.update_columns(slug: "meetup-2026-11-12")
    events_cfps(:one).update_columns(events_event_id: event.id, name: "Call for Proposals")
    events_cfps(:two).update_columns(events_event_id: event.id, name: "Call for Lightning Talks")

    get "/avo/resources/events_events/meetup-2026-11-12"

    assert_response :success
    frame = css_select("turbo-frame#has_many_field_show_cfps").first
    assert frame, "expected a CFPs panel"

    get frame["src"]

    assert_response :success
    assert_equal [ "Call for Lightning Talks", "Call for Proposals" ], css_select("td[data-field-id='name']").map { |cell| cell.text.squish }.sort
  end
end
