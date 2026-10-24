require "test_helper"

# The model insists on an end date once an event has a start date, but in the
# form a blank one means the event ends the day it starts.
class AvoEventFormTest < ActionDispatch::IntegrationTest
  test "a blank end date ends the event on its start date" do
    event = events_events(:one)

    update event, start_date: "2026-10-01", end_date: ""

    assert_equal Date.new(2026, 10, 1), event.reload.end_date
  end

  test "an end date of its own is kept" do
    event = events_events(:one)

    update event, start_date: "2026-10-01", end_date: "2026-10-03"

    assert_equal Date.new(2026, 10, 3), event.reload.end_date
  end

  test "an undated event stays without an end date" do
    event = events_events(:one)

    update event, start_date: "", start_time: "", end_date: "", end_time: ""

    assert_nil event.reload.end_date
  end

  test "an event that has yet to happen comes with a CFP opening today" do
    travel_to Date.new(2026, 11, 1)

    event = create_event(start_date: "2026-11-02")

    cfp = event.cfps.sole
    assert_equal "Call for Proposals", cfp.name
    assert_equal Date.new(2026, 11, 1), cfp.open_date
    assert_nil cfp.read_attribute(:close_date)
    assert_equal "meetup-2026-11-02-call-for-proposals", cfp.slug
  end

  test "an undated event comes with an open-ended CFP" do
    travel_to Date.new(2026, 11, 1)

    event = create_event(start_date: "")

    assert_equal Date.new(2026, 11, 1), event.cfps.sole.open_date
    assert_nil event.cfps.sole.close_date
  end

  test "an event starting today comes without a CFP" do
    travel_to Date.new(2026, 11, 1)

    assert_empty create_event(start_date: "2026-11-01").cfps
  end

  test "a past event comes without a CFP" do
    travel_to Date.new(2026, 11, 1)

    assert_empty create_event(start_date: "2019-07-10").cfps
  end

  test "a cancelled event comes without a CFP" do
    travel_to Date.new(2026, 11, 1)

    assert_empty create_event(start_date: "2026-12-03", status: "cancelled").cfps
  end

  test "an updated event gets no new CFP" do
    event = events_events(:one)
    Events::CFP.where(event: event).delete_all

    update event, start_date: Date.current.next_month.iso8601, end_date: ""

    assert_empty event.cfps.reload
  end

  private

  # The fixtures carry placeholder values that fail the model's validations, and
  # a "MyString" slug the lookup behind the URL never finds.
  def update(event, **attributes)
    event.update_columns(slug: "form-event", kind: "meetup", status: "scheduled", date_precision: "day")
    patch "/avo/resources/events_events/#{event.to_param}", params: { "events/event" => attributes }

    assert_response :redirect
  end

  def create_event(**attributes)
    post "/avo/resources/events_events", params: { "events/event" => {
      kind: "meetup", status: "scheduled", date_precision: "day", attendance_mode: "in_person",
      events_series_id: events_series(:one).id, venues_venue_id: venues_venues(:one).id, **attributes
    } }

    assert_response :redirect
    Events::Event.where.not(id: [ events_events(:one), events_events(:two) ]).sole
  end
end
