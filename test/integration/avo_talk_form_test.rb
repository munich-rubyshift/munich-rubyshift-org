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
end
