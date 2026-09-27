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

  private

  # The fixtures carry placeholder values that fail the model's validations, and
  # a "MyString" slug the lookup behind the URL never finds.
  def update(event, **attributes)
    event.update_columns(slug: "form-event", kind: "meetup", status: "scheduled", date_precision: "day")
    patch "/avo/resources/events_events/#{event.to_param}", params: { "events/event" => attributes }

    assert_response :redirect
  end
end
