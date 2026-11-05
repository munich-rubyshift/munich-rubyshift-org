require_relative "test_helper"

class JsonApiTest < Minitest::Test
  include ResourceHelper

  API = "http://example.com/api/v1".freeze

  def stub_document(path, data, included: [])
    stub_request(:get, "#{API}/#{path}").to_return(body: JSON.generate("data" => data, "included" => included))
  end

  def test_resolves_relationships_across_documents
    stub_document("people.json", [ resource_data("people", "ada", name: "Ada") ])
    stub_document("events/meetup.json",
      resource_data("events", "meetup", relationships: { talks: [ identifier("talks", "intro") ], venue: nil }),
      included: [ resource_data("talks", "intro", relationships: { speakers: [ identifier("people", "ada") ] }) ])

    client = JsonApi::Client.new(API)
    client.get("people.json")
    event = client.get("events/meetup.json")

    assert_equal [ "Ada" ], event.related("talks").flat_map { |talk| talk.related("speakers").map { |person| person["name"] } }
    assert_nil event.related("venue")
  end

  def test_tells_which_resource_is_missing
    stub_document("talks/intro.json", resource_data("talks", "intro", relationships: { speakers: [ identifier("people", "ada") ] }))

    talk = JsonApi::Client.new(API).get("talks/intro.json")

    error = assert_raises(JsonApi::Error) { talk.related("speakers") }
    assert_equal "people ada hasn't been fetched", error.message
  end

  def test_raises_on_an_unsuccessful_response
    stub_request(:get, "#{API}/people.json").to_return(status: 404)

    error = assert_raises(JsonApi::Error) { JsonApi::Client.new("#{API}/").get("people.json") }
    assert_equal "GET #{API}/people.json answered 404", error.message
  end

  def test_fetches_the_lists_and_each_event_of_each_series
    %w[people organizations cities].each { |list| stub_document("#{list}.json", []) }
    stub_document("series.json", [ resource_data("series", "rubyshift", relationships: { events: [ identifier("events", "meetup") ] }) ])
    stub_document("events/meetup.json", resource_data("events", "meetup", title: "Meetup"))

    store = MunichRubyshift.fetch(API)

    assert_equal "Meetup", store.all("series").first.related("events").first["title"]
  end
end
