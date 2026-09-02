require "test_helper"

class Events::EventTest < ActiveSupport::TestCase
  setup do
    @series = events_series(:one)
    @venue = venues_venues(:one)
  end

  test "requires an attendance mode" do
    event = build_event(attendance_mode: nil)

    assert_not event.valid?
    assert_equal [ "can't be blank" ], event.errors[:attendance_mode]
  end

  test "accepts every attendance mode" do
    Events::Event::ATTENDANCE_MODES.each do |mode|
      event = build_event(attendance_mode: mode)

      assert event.valid?, "#{mode}: #{event.errors.full_messages.to_sentence}"
    end
  end

  test "rejects an unknown attendance mode" do
    event = build_event(attendance_mode: "telepathic")

    assert_not event.valid?
    assert_includes event.errors[:attendance_mode], "is not included in the list"
  end

  private

  def build_event(**attributes)
    Events::Event.new(title: "Meetup", series: @series, venue: @venue, attendance_mode: "in_person", **attributes)
  end
end
