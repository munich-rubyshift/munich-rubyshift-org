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

  teardown do
    browse_from_the_original_time_zone
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

    execute_script("document.querySelector(\"[data-field-id='start_time'] input.flatpickr-input\")._flatpickr.setDate('2026-11-12 19:30:00', true)")
    click_on "Save"

    assert_selector "[data-field-id='start_time']", text: "19:30"
    @event.reload
    assert_equal "19:30", @event.start_time
    assert_equal "22:00", @event.end_time
  end

  test "an event form clears a time whose text is deleted" do
    visit "/avo/resources/events_events/form-event/edit"
    picker(:start_time).click
    picker(:start_time).send_keys([ :control, "a" ], :backspace)
    click_on "Save"

    assert_selector "[data-field-id='end_time']", text: "22:00"
    assert_nil @event.reload.start_time
  end

  test "an event form picks times on a 24 hour clock" do
    visit "/avo/resources/events_events/form-event/edit"
    picker(:start_time).click

    assert_equal "19", find(".flatpickr-calendar.open .flatpickr-hour").value
  end

  test "an event form offers hours and minutes but no seconds" do
    visit "/avo/resources/events_events/form-event/edit"
    picker(:start_time).click

    assert_selector ".flatpickr-calendar.open .flatpickr-minute"
    assert_no_selector ".flatpickr-calendar.open .flatpickr-second", visible: :all
    assert_selector ".flatpickr-calendar.open .flatpickr-time-separator", count: 1
  end

  test "an event form reached from its page offers no seconds either" do
    visit "/avo/resources/events_events/form-event"
    click_on "Edit"
    picker(:start_time).click

    assert_no_selector ".flatpickr-calendar.open .flatpickr-second", visible: :all
  end

  test "a date and time picker keeps its seconds" do
    visit "/avo/resources/events_events/form-event/edit"
    picker(:published_at).click

    assert_selector ".flatpickr-calendar.open .flatpickr-second"
  end

  test "Tab moves through the time picker and back to its input" do
    visit "/avo/resources/events_events/form-event/edit"
    picker(:start_time).click
    find(".flatpickr-calendar.open .flatpickr-hour").click

    page.send_keys(:tab)
    assert_selector ".flatpickr-calendar.open .flatpickr-minute:focus"

    page.send_keys(:tab)
    assert_selector "[data-field-id='start_time'] input.flatpickr-input + input:focus"
  end

  private

  def browse_from_munich
    page.driver.browser.execute_cdp("Emulation.setTimezoneOverride", timezoneId: "Europe/Berlin")
  end

  def browse_from_the_original_time_zone
    page.driver.browser.execute_cdp("Emulation.setTimezoneOverride", timezoneId: "")
  end

  def picker(name)
    find("[data-field-id='#{name}'] input.flatpickr-input + input", visible: true)
  end
end
