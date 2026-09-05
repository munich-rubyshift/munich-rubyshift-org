require "test_helper"

# Avo names a record by the first of `name`, `title`, `label` or `to_param` it
# finds unless the resource says otherwise, so a model owning none of those
# columns was headed by its UUID. These check the record reads as itself.
class AvoRecordLabelsTest < ActionDispatch::IntegrationTest
  test "a belongs_to column prints the record rather than its id" do
    coordinates = locations_addresses(:one).coordinates
    coordinates.update!(latitude: 48.118196, longitude: 11.602731)

    get "/avo/resources/locations_addresses"

    assert_response :success
    # The id still belongs in the link's href, so this asks what the link reads.
    assert_select "a", text: /N48\.11 E11\.60/
    assert_select "a", text: coordinates.id, count: 0
  end

  # Nothing on this one carries a name, a title or a slug, so before the resource
  # named `to_s` its own index was a column of UUIDs.
  test "a record with no name of its own still heads its own page" do
    speaker_talk = talks_speaker_talks(:one)
    speaker_talk.talk.update!(title: "munich-rubyshift.org goes LIVE!")
    speaker_talk.speaker.update!(name: "Klaus Weidinger")

    get "/avo/resources/talks_speaker_talks/#{speaker_talk.to_param}"

    assert_response :success
    assert_includes response.body, "by Klaus Weidinger"
  end
end
