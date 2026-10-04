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

  private

  def build_talk(**attributes)
    Talks::Talk.new(title: "Gems are overrated", event: events_events(:one), kind: "talk", language_code: "en", **attributes)
  end
end
