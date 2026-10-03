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

  test "requires an end date once it has a start date" do
    event = build_event(start_date: Date.new(2026, 9, 24))

    assert_not event.valid?
    assert_includes event.errors[:end_date], "can't be blank"
  end

  test "refuses an end date without a start date" do
    event = build_event(end_date: Date.new(2026, 9, 24))

    assert_not event.valid?
    assert_includes event.errors[:end_date], "must be blank"
  end

  test "needs neither date while undated" do
    event = build_event

    assert event.valid?, event.errors.full_messages.to_sentence
  end

  test "refuses a start time without a start date" do
    event = build_event(start_time: "19:00")

    assert_not event.valid?
    assert_includes event.errors[:start_time], "must be blank"
  end

  test "refuses an end time without an end date" do
    event = build_event(end_time: "22:00")

    assert_not event.valid?
    assert_includes event.errors[:end_time], "must be blank"
  end

  test "needs no times on its dates" do
    event = build_event(start_date: Date.new(2026, 9, 24), end_date: Date.new(2026, 9, 24))

    assert event.valid?, event.errors.full_messages.to_sentence
  end

  test "refuses to end on a day before it starts" do
    event = build_event(start_date: Date.new(2026, 9, 24), end_date: Date.new(2026, 9, 23))

    assert_not event.valid?
    assert_includes event.errors[:end_date], "can't be before the start date"
  end

  test "refuses to end before it starts on the same day" do
    event = build_event(start_date: Date.new(2026, 9, 24), start_time: "19:00", end_date: Date.new(2026, 9, 24), end_time: "18:59")

    assert_not event.valid?
    assert_includes event.errors[:end_time], "can't be before the start time"
  end

  test "may end the moment it starts" do
    event = build_event(start_date: Date.new(2026, 9, 24), start_time: "19:00", end_date: Date.new(2026, 9, 24), end_time: "19:00")

    assert event.valid?, event.errors.full_messages.to_sentence
  end

  test "may end at an earlier hour on a later day" do
    event = build_event(start_date: Date.new(2026, 9, 24), start_time: "19:00", end_date: Date.new(2026, 9, 25), end_time: "01:00")

    assert event.valid?, event.errors.full_messages.to_sentence
  end

  # Without both times, only the dates can be put in order.
  test "orders a single day by its dates when a time is missing" do
    event = build_event(start_date: Date.new(2026, 9, 24), start_time: "19:00", end_date: Date.new(2026, 9, 24))

    assert event.valid?, event.errors.full_messages.to_sentence
  end

  test "slugs an event after its kind and start date" do
    event = build_event(kind: "meetup", start_date: Date.new(2013, 7, 10), end_date: Date.new(2013, 7, 10))
    event.save!

    assert_equal "meetup-2013-07-10", event.slug
  end

  test "slugs an event without a start date after its title" do
    event = build_event(kind: "meetup", title: "Gems Marathon")
    event.save!

    assert_equal "meetup-gems-marathon", event.slug
  end

  test "slugs an event without a start date or title after its kind alone" do
    event = build_event(kind: "meetup", title: nil)
    event.save!

    assert_equal "meetup", event.slug
  end

  # The kind alone is not distinctive, so the second one has to be disambiguated.
  test "appends a uuid once the kind alone is taken" do
    build_event(kind: "meetup", title: nil).save!
    event = build_event(kind: "meetup", title: nil)
    event.save!

    assert_match(/\Ameetup-\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/, event.slug)
  end

  test "sorts by start date and then start time" do
    evening = build_event(start_date: Date.new(2026, 9, 24), start_time: "19:00", end_date: Date.new(2026, 9, 24)).tap(&:save!)
    morning = build_event(start_date: Date.new(2026, 9, 24), start_time: "09:00", end_date: Date.new(2026, 9, 24)).tap(&:save!)
    earlier = build_event(start_date: Date.new(2026, 9, 23), start_time: "20:00", end_date: Date.new(2026, 9, 23)).tap(&:save!)
    events = Events::Event.where(id: [ evening, morning, earlier ])

    assert_equal [ earlier, morning, evening ], events.by_start_date.to_a
    assert_equal [ evening, morning, earlier ], events.by_start_date.reverse_order.to_a
  end

  test "reads as its kind and start date like its slug" do
    event = build_event(kind: "meetup", title: "Ruby User Group Meetup", start_date: Date.new(2026, 12, 31))

    assert_equal "Meetup 2026-12-31", event.to_s
  end

  test "reads as its kind alone without a start date" do
    assert_equal "Meetup", build_event(kind: "meetup", title: "Ruby User Group Meetup").to_s
  end

  private

  def build_event(**attributes)
    Events::Event.new(title: "Meetup", series: @series, venue: @venue, attendance_mode: "in_person", **attributes)
  end
end
