require "test_helper"

class AvoTalkFormTest < ActionDispatch::IntegrationTest
  test "a new talk starts as a plain talk" do
    get "/avo/resources/talks_talks/new"

    assert_response :success
    assert_select "select[name='talks/talk[kind]'] option[selected]", text: "Talk"
    assert_select "select[name='talks/talk[kind]'] option[value='']", count: 0
  end

  test "the kind select spells Q&A as such" do
    get "/avo/resources/talks_talks/new"

    assert_select "select[name='talks/talk[kind]'] option[value='q_and_a']", text: "Q&A"
    assert_select "select[name='talks/talk[kind]'] option[value='lightning_talk']", text: "Lightning talk"
  end

  test "a new talk starts in English" do
    get "/avo/resources/talks_talks/new"

    assert_response :success
    assert_select "select[name='talks/talk[language_code]'] option[selected]", text: "English"
    assert_select "select[name='talks/talk[language_code]'] option[value='']", count: 0
  end

  test "a talk page names its language" do
    talk = talks_talks(:one)
    talk.update_columns(slug: "talk-page", language_code: "de")

    get "/avo/resources/talks_talks/#{talk.to_param}"

    assert_response :success
    assert_select "[data-field-id='language_code']", text: /German/
  end

  test "a talk form shows the talk's own announcement date" do
    talk = talks_talks(:one)
    talk.update_columns(slug: "talk-form", announced_on: nil)
    talk.event.update_columns(announced_on: Date.new(2026, 9, 1))

    get "/avo/resources/talks_talks/#{talk.to_param}/edit"

    assert_response :success
    assert_select "[data-field-id='announced_on'] input[value='2026-09-01']", count: 0
    assert_select "[data-field-id='announced_on'] input[placeholder='2026-09-01']"
  end

  test "a talk page shows when the talk was announced with its event" do
    talk = talks_talks(:one)
    talk.update_columns(slug: "talk-page", announced_on: nil)
    talk.event.update_columns(announced_on: Date.new(2026, 9, 1))

    get "/avo/resources/talks_talks/#{talk.to_param}"

    assert_response :success
    assert_select "[data-field-id='announced_on']", text: /2026-09-01/
  end

  test "a talk saved without a position goes last" do
    event = events_events(:one)
    event.update_columns(slug: "talk-event")
    event.talks.update_all(position: 2)

    post "/avo/resources/talks_talks", params: { "talks/talk" => {
      title: "Appended", events_event_id: event.id, position: "", kind: "talk", language_code: "en"
    } }

    assert_response :redirect
    assert_equal 3, Talks::Talk.find_by!(title: "Appended").position
  end

  test "the event dropdown lists the newest events first" do
    events_events(:one).update_columns(kind: "meetup", start_date: Date.new(2017, 3, 8))
    events_events(:two).update_columns(kind: "meetup", start_date: Date.new(2026, 9, 24))

    get "/avo/resources/talks_talks/new"

    assert_response :success
    options = css_select("select[name='talks/talk[events_event_id]'] option[value]").reject { |option| option["value"].blank? }.map(&:text)
    assert_equal [ "Meetup 2026-09-24", "Meetup 2017-03-08" ], options
  end

  test "a talk page lists its speakers by name" do
    talk = talks_talks(:one)
    talk.update_columns(slug: "talk-page")
    Talks::SpeakerTalk.where(talk: talk).delete_all
    [ "Zoe", "anna", "Bob" ].each { |name| talk.speakers << Entities::Person.create!(name: name) }

    get speakers_frame(talk)

    assert_response :success
    assert_equal [ "anna", "Bob", "Zoe" ], css_select("[data-field-id='name']").map { |cell| cell.text.strip }
  end

  test "a speaker created from a talk speaks at it" do
    talk = talks_talks(:one)
    talk.update_columns(slug: "talk-page")
    get speakers_frame(talk)
    create_link = css_select("a").find { |link| link.text.include?("Create new speaker") }

    post "/avo/resources/entities_people",
      params: Rack::Utils.parse_query(URI(create_link["href"]).query).merge("entities/person" => { name: "Anna" })

    assert_includes talk.speakers.reload.map(&:name), "Anna"
  end

  test "attaching a speaker adds them to the talk" do
    talk = talks_talks(:one)
    talk.update_columns(slug: "talk-page")
    person = Entities::Person.create!(name: "Anna")

    post "/avo/resources/talks_talks/talk-page/speakers", params: { fields: { related_id: person.id } }

    assert_includes talk.speakers.reload, person
  end

  test "attaching a speaker twice reports an error" do
    talk = talks_talks(:one)
    talk.update_columns(slug: "talk-page")
    taken = talks_speaker_talks(:one).speaker

    post "/avo/resources/talks_talks/talk-page/speakers",
      params: { fields: { related_id: taken.id }, turbo_frame: "has_many_field_show_speakers" },
      as: :turbo_stream

    assert_match(/attach/i, flash[:error])
    assert_equal 1, Talks::SpeakerTalk.where(talk: talk, speaker: taken).count
  end

  test "a talk page lists its additional resources" do
    talk = talks_talks(:one)
    talk.update_columns(slug: "talk-page")

    get "/avo/resources/talks_talks/talk-page"

    assert_select "turbo-frame#has_many_field_show_additional_resources"
  end

  private

  def speakers_frame(talk)
    "/avo/resources/talks_talks/#{talk.to_param}/speakers?view=show&turbo_frame=has_many_field_show_speakers"
  end
end
