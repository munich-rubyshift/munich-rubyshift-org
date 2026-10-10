require "test_helper"

class TalkPagesTest < ActionDispatch::IntegrationTest
  test "a talk lists its speakers by name, ignoring case" do
    talk = talks_talks(:one)
    talk.update_columns(slug: "panel")
    Talks::SpeakerTalk.where(talk: talk).delete_all
    [ "Zoe", "anna", "Bob" ].each do |name|
      talk.speakers << Entities::Person.create!(name: name)
    end

    get "/talks/panel"

    assert_response :success
    assert_equal [ "anna", "Bob", "Zoe" ], css_select("article li a").map(&:text)
  end

  test "the talks list the latest event first, and its last talk first" do
    older = events_events(:one)
    newer = events_events(:two)
    older.update_columns(start_date: "2026-03-05", end_date: "2026-03-05")
    newer.update_columns(start_date: "2026-04-23", end_date: "2026-04-23")
    talks_talks(:one).update_columns(events_event_id: older.id, position: 1, slug: "older-first")
    talks_talks(:two).update_columns(events_event_id: newer.id, position: 1, slug: "newer-first")
    Talks::Talk.create!(event: older, title: "Older second", kind: "talk", language_code: "en", position: 2)
    Talks::Talk.create!(event: newer, title: "Newer second", kind: "talk", language_code: "en", position: 2)

    get "/talks"

    assert_response :success
    assert_equal %w[/talks/newer-second /talks/newer-first /talks/older-second /talks/older-first],
      css_select("#talks_talks > li > p > a").map { |link| link["href"] }
  end

  test "an event lists each talk's speakers by name, ignoring case" do
    talk = talks_talks(:one)
    talk.event.update_columns(slug: "meetup")
    Talks::SpeakerTalk.where(talk: talk).delete_all
    [ "Zoe", "anna", "Bob" ].each do |name|
      talk.speakers << Entities::Person.create!(name: name)
    end

    get "/events/meetup"

    assert_response :success
    assert_match(/by anna, Bob, Zoe/, response.body)
  end
end
