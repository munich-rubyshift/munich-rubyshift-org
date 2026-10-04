require "test_helper"

class Talks::TalkTest < ActiveSupport::TestCase
  test "requires a title" do
    talk = build_talk(title: "")

    assert_not talk.valid?
    assert_includes talk.errors[:title], "can't be blank"
  end

  test "is slugged after its title" do
    talk = build_talk(title: "Gems are overrated")
    talk.save!

    assert_equal "gems-are-overrated", talk.slug
  end

  test "a repeated title is slugged with its event's date" do
    events_events(:two).update_columns(start_date: Date.new(2025, 10, 16))
    build_talk(title: "Lightning Talks", event: events_events(:one)).save!

    talk = build_talk(title: "Lightning Talks", event: events_events(:two))
    talk.save!

    assert_equal "lightning-talks-2025-10-16", talk.slug
  end

  test "requires a kind" do
    talk = build_talk(kind: nil)

    assert_not talk.valid?
    assert_includes talk.errors[:kind], "can't be blank"
  end

  test "only takes a kind rubyevents knows" do
    talk = build_talk(kind: "lightning")

    assert_not talk.valid?
    assert_includes talk.errors[:kind], "is not included in the list"
  end

  test "requires a language" do
    talk = build_talk(language_code: nil)

    assert_not talk.valid?
    assert_includes talk.errors[:language_code], "can't be blank"
  end

  test "only takes a language we list" do
    talk = build_talk(language_code: "English")

    assert_not talk.valid?
    assert_includes talk.errors[:language_code], "is not included in the list"
  end

  test "reads its language as the English name" do
    assert_equal "German", build_talk(language_code: "de").language
  end

  test "doesn't default to the series' language" do
    event = events_events(:one)
    event.series.language_code = "de"

    assert_nil Talks::Talk.new(event: event).language_code
  end

  test "a talk announced on its own keeps its date" do
    talk = build_talk(announced_on: Date.new(2026, 9, 10))
    talk.event.announced_on = Date.new(2026, 9, 1)

    assert_equal Date.new(2026, 9, 10), talk.announced_on
  end

  test "a talk without its own date was announced with its event" do
    talk = build_talk(announced_on: nil)
    talk.event.announced_on = Date.new(2026, 9, 1)

    assert_equal Date.new(2026, 9, 1), talk.announced_on
  end

  # Entering the event's date explicitly is a statement of its own, so it stays
  # when the event's date gets corrected.
  test "a talk announced on the event's date explicitly keeps it" do
    talk = build_talk(announced_on: Date.new(2026, 9, 1))
    talk.event.announced_on = Date.new(2026, 9, 1)
    talk.save!

    talk.event.update_column(:announced_on, Date.new(2026, 9, 2))

    assert_equal Date.new(2026, 9, 1), talk.reload.announced_on
  end

  test "a talk without a position comes after its event's last one" do
    event = events_events(:one)
    talks_talks(:one).update_columns(events_event_id: events_events(:two).id, position: 2)
    build_talk(event: event, position: 3).save!

    talk = build_talk(event: event, position: nil)
    talk.save!

    assert_equal 4, talk.position
  end

  test "the first talk of an event comes first" do
    event = events_events(:one)
    talks_talks(:one).update_columns(events_event_id: events_events(:two).id, position: 2)

    talk = build_talk(event: event, position: nil)
    talk.save!

    assert_equal 1, talk.position
  end

  test "a talk whose position gets cleared goes right after the others" do
    event = events_events(:one)
    talks_talks(:one).update_columns(events_event_id: events_events(:two).id, position: 2)
    build_talk(event: event, position: 1).save!
    talk = build_talk(event: event, position: 3).tap(&:save!)

    talk.update!(position: nil)

    assert_equal 2, talk.position
  end

  test "a talk keeps the position it was given" do
    talk = build_talk(position: 7)
    talk.save!

    assert_equal 7, talk.reload.position
  end

  test "two talks of an event can't share a position" do
    talk = build_talk(event: talks_talks(:one).event, position: talks_talks(:one).position)

    assert_not talk.valid?
    assert_includes talk.errors[:position], "has already been taken"
  end

  test "talks of different events may share a position" do
    talks_talks(:one).update_column(:position, 5)

    assert build_talk(event: talks_talks(:two).event, position: 5).valid?
  end

  test "the database refuses two talks of an event sharing a position" do
    taken = talks_talks(:one)

    assert_raises ActiveRecord::RecordNotUnique do
      build_talk(event: taken.event, position: taken.position).save!(validate: false)
    end
  end

  test "rejects a position below one" do
    talk = build_talk(position: 0)

    assert_not talk.valid?
    assert_includes talk.errors[:position], "must be greater than 0"
  end

  test "an event lists its talks in running order" do
    event = events_events(:one)
    talks_talks(:one).update_columns(events_event_id: events_events(:two).id, position: 2)
    second = build_talk(event: event, title: "A", position: 2).tap(&:save!)
    first = build_talk(event: event, title: "B", position: 1).tap(&:save!)

    assert_equal [ first, second ], event.talks.reload.to_a
  end

  private

  def build_talk(**attributes)
    Talks::Talk.new(title: "Gems are overrated", event: events_events(:one), kind: "talk", language_code: "en", **attributes)
  end
end
