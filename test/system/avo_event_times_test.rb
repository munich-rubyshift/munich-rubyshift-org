require "application_system_test_case"

class AvoEventTimesTest < ApplicationSystemTestCase
  setup do
    browse_from_munich
    venues_venues(:one).update_columns(slug: "venue")
    events_series(:one).update_columns(slug: "series")
    @event = events_events(:one)
    @event.update_columns(slug: "form-event", kind: "meetup", status: "scheduled", date_precision: "day",
      start_date: Date.new(2026, 11, 12), start_time: "19:00", end_date: Date.new(2026, 11, 12), end_time: "22:00")
  end

  test "an event page shows its times as they are stored" do
    visit "/avo/resources/events_events/form-event"

    assert_selector "[data-field-id='start_time']", text: "19:00"
    assert_selector "[data-field-id='end_time']", text: "22:00"
    assert_no_text "19:00:00"
  end

  test "an event form stores its times as they are picked" do
    visit "/avo/resources/events_events/form-event/edit"
    assert_equal "19:00", picker(:start_time).value

    execute_script("document.querySelector(\"input[name='fake_start_time[fake]']\")._flatpickr.setDate('2026-11-12 19:30:00', true)")
    click_on "Save"

    assert_selector "[data-field-id='start_time']", text: "19:30"
    @event.reload
    assert_equal "19:30", @event.start_time
    assert_equal "22:00", @event.end_time
  end

  private

  def browse_from_munich
    page.driver.browser.execute_cdp("Emulation.setTimezoneOverride", timezoneId: "Europe/Berlin")
  end

  def picker(name)
    find("[data-field-id='#{name}'] input.flatpickr-input + input", visible: true)
  end
end
