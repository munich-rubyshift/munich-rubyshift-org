require "test_helper"

class EventPagesTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Date.new(2026, 11, 1)
    @event = events_events(:one)
    @event.update_columns(slug: "meetup-2026-11-12", start_date: "2026-11-12", end_date: "2026-11-12")
    Events::CFP.delete_all
  end

  test "the events link to each event's CFPs in the order they open" do
    Events::CFP.create!(event: @event, name: "Call for Lightning Talks", open_date: "2026-10-15")
    Events::CFP.create!(event: @event, name: "Call for Proposals", open_date: "2026-10-01")

    get "/events"

    assert_response :success
    assert_equal [ [ "CFP open", "/cfps/meetup-2026-11-12-call-for-proposals" ], [ "CFP open", "/cfps/meetup-2026-11-12-call-for-lightning-talks" ] ],
      css_select("#events_events a[href^='/cfps/']").map { |link| [ link.text, link["href"] ] }
  end

  test "an event's CFP closes after the day before the event" do
    Events::CFP.create!(event: @event, name: "Call for Proposals", open_date: "2026-10-01")

    travel_to Date.new(2026, 11, 11)
    get "/events/meetup-2026-11-12"

    assert_select "a[href='/cfps/meetup-2026-11-12-call-for-proposals']", text: "CFP open"

    travel_to Date.new(2026, 11, 12)
    get "/events/meetup-2026-11-12"

    assert_select "a[href='/cfps/meetup-2026-11-12-call-for-proposals']", text: "CFP closed"
  end

  test "an event's CFP yet to open reads as open" do
    Events::CFP.create!(event: @event, name: "Call for Proposals", open_date: "2026-11-05")

    get "/events/meetup-2026-11-12"

    assert_select "a[href='/cfps/meetup-2026-11-12-call-for-proposals']", text: "CFP open"
  end
end
