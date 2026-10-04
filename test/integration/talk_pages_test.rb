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
