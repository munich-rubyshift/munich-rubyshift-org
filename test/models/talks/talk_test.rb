require "test_helper"

class Talks::TalkTest < ActiveSupport::TestCase
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

  private

  def build_talk(**attributes)
    Talks::Talk.new(title: "Gems are overrated", event: events_events(:one), kind: "talk", language_code: "en", **attributes)
  end
end
