require "test_helper"

class Events::EventTest < ActiveSupport::TestCase
  setup do
    @series = events_series(:one)
    @venue = venues_venues(:one)
  end

  test "requires a venue" do
    event = build_event(venue: nil)

    assert_not event.valid?
    assert_includes event.errors[:venue], "can't be blank"
  end

  # A hybrid event is online *and* in person, so people still need somewhere to go.
  test "requires a venue for a hybrid event" do
    event = build_event(venue: nil, attendance_mode: "hybrid")

    assert_not event.valid?
    assert_includes event.errors[:venue], "can't be blank"
  end

  test "requires a venue for a postponed event" do
    event = build_event(venue: nil, status: "postponed")

    assert_not event.valid?
    assert_includes event.errors[:venue], "can't be blank"
  end

  test "does not require a venue for an online event" do
    event = build_event(venue: nil, attendance_mode: "online")

    assert event.valid?, event.errors.full_messages.to_sentence
  end

  test "does not require a venue for a cancelled event" do
    event = build_event(venue: nil, status: "cancelled")

    assert event.valid?, event.errors.full_messages.to_sentence
  end

  test "refuses a venue for an online event" do
    event = build_event(attendance_mode: "online")

    assert_not event.valid?
    assert_includes event.errors[:venue], "must be blank"
  end

  test "refuses a venue for a cancelled online event" do
    event = build_event(attendance_mode: "online", status: "cancelled")

    assert_not event.valid?
    assert_includes event.errors[:venue], "must be blank"
  end

  test "keeps the venue of an event that no longer needs one" do
    event = build_event(status: "cancelled")

    assert event.valid?, event.errors.full_messages.to_sentence
    assert_equal @venue, event.venue
  end

  test "stores an event without a venue" do
    event = build_event(venue: nil, attendance_mode: "online")

    assert event.save, event.errors.full_messages.to_sentence
    assert_nil event.reload.venue
  end

  test "accepts every attendance mode" do
    Events::Event::ATTENDANCE_MODES.each do |mode|
      event = build_event(attendance_mode: mode, venue: mode == "online" ? nil : @venue)

      assert event.valid?, "#{mode}: #{event.errors.full_messages.to_sentence}"
    end
  end

  test "rejects an unknown attendance mode" do
    event = build_event(attendance_mode: "telepathic")

    assert_not event.valid?
    assert_includes event.errors[:attendance_mode], "is not included in the list"
  end

  test "requires an attendance mode" do
    event = build_event(attendance_mode: nil)

    assert_not event.valid?
    assert_equal [ "can't be blank" ], event.errors[:attendance_mode]
  end

  private

  def build_event(**attributes)
    Events::Event.new(title: "Meetup", series: @series, venue: @venue, attendance_mode: "in_person", **attributes)
  end
end
