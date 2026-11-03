require "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  include StorageTestHelper

  OPENAPI = JSONSchemer.openapi(YAML.load_file(Rails.root.join("public/api/v1/schema.yaml")))

  setup do
    Events::Event.update_all(kind: "meetup", status: nil, date_precision: nil)
    Events::Series.update_all(kind: "meetup", frequency: "quarterly")
    Talks::AdditionalResource.update_all(kind: "repo")

    @event = events_events(:one)
    @event.update_columns(slug: "meetup-2026-04-23")
    events_series(:one).update_columns(slug: "munich-rubyshift")
    entities_people(:one).update_columns(slug: "anna")
    entities_people(:two).update_columns(slug: "ben")
    entities_organizations(:one).update_columns(slug: "freeletics")
    entities_organizations(:two).update_columns(slug: "makandra")
    locations_cities(:one).update_columns(slug: "munich")
  end

  test "each document matches the schema" do
    venues_venues(:one).update_columns(entities_organization_id: entities_organizations(:one).id, locations_map_id: locations_maps(:one).id)
    events_involvements(:two).update_columns(events_event_id: @event.id)
    events_events(:two).update_columns(slug: "online-meetup", attendance_mode: "online", venues_venue_id: nil)

    {
      "/api/v1/people.json" => "PeopleDocument",
      "/api/v1/cities.json" => "CitiesDocument",
      "/api/v1/organizations.json" => "OrganizationsDocument",
      "/api/v1/series.json" => "SeriesDocument",
      "/api/v1/events/meetup-2026-04-23.json" => "EventDocument",
      "/api/v1/events/online-meetup.json" => "EventDocument"
    }.each do |path, schema|
      get path

      assert_response :success
      assert_empty OPENAPI.schema(schema).validate(response.parsed_body).map { |error| error["error"] }, path
    end
  end

  test "an event refers to the records it includes and to records that their lists hold" do
    events_involvements(:two).update_columns(events_event_id: @event.id)

    get "/api/v1/events/meetup-2026-04-23.json"
    document = response.parsed_body
    included = document["included"].map { |resource| resource.slice("type", "id") }
    referenced = identifiers_in([ document["data"], *document["included"] ].map { |resource| resource["relationships"] })

    assert_empty included - referenced
    listed = (referenced - included).group_by { |identifier| identifier["type"] }
    assert_equal %w[cities organizations people series], listed.keys.sort

    listed.each do |type, identifiers|
      get "/api/v1/#{type}.json"

      assert_empty identifiers.map { |identifier| identifier["id"] } - response.parsed_body["data"].map { |record| record["id"] }, type
    end
  end

  test "an involvement's id joins the slugs of its event, its role and its person" do
    events_involvements(:one).update_columns(role: "Ruby embassy bureaucrat")

    get "/api/v1/events/meetup-2026-04-23.json"

    assert_equal [ { "type" => "involvements", "id" => "meetup-2026-04-23-ruby-embassy-bureaucrat-anna" } ],
      response.parsed_body.dig("data", "relationships", "involvements", "data")
  end

  test "people are the speakers and those with a role, not those who only attended" do
    dora = Entities::Person.create!(name: "Dora")
    @event.involvements.create!(entity: dora, role: "Chef")
    @event.participations.create!(person: Entities::Person.create!(name: "Carla"))

    get "/api/v1/people.json"

    assert_equal %w[anna ben dora], response.parsed_body["data"].map { |person| person["id"] }
  end

  test "an event counts its attendees without naming them" do
    @event.participations.create!(person: Entities::Person.create!(name: "Carla"))

    get "/api/v1/events/meetup-2026-04-23.json"

    assert_equal 2, response.parsed_body.dig("data", "attributes", "participants_count")
    assert_no_match(/carla/i, response.body)
  end

  test "an event holds its own values, not those it falls back to" do
    events_series(:one).update_columns(website: "https://munich-rubyshift.org")
    @event.update_columns(website: nil, announced_on: "2026-03-01")
    talks_talks(:one).update_columns(announced_on: nil)
    events_cfps(:one).update_columns(close_date: nil)

    get "/api/v1/events/meetup-2026-04-23.json"
    included = response.parsed_body["included"]

    assert_nil response.parsed_body.dig("data", "attributes", "website")
    assert_nil included.find { |resource| resource["type"] == "talks" }.dig("attributes", "announced_on")
    assert_nil included.find { |resource| resource["type"] == "cfps" }.dig("attributes", "close_date")
  end

  test "a series refers to its events, newest first, by the ids of their documents" do
    events_events(:two).update_columns(events_series_id: events_series(:one).id, slug: "meetup-2026-01-22",
      start_date: "2026-01-22", end_date: "2026-01-22")

    get "/api/v1/series.json"
    events = response.parsed_body["data"].find { |series| series["id"] == "munich-rubyshift" }.dig("relationships", "events", "data")

    assert_equal [ { "type" => "events", "id" => "meetup-2026-04-23" }, { "type" => "events", "id" => "meetup-2026-01-22" } ], events

    get "/api/v1/events/meetup-2026-01-22.json"

    assert_response :success
  end

  test "a person links to their avatar" do
    check_out_storage
    @event.involvements.create!(entity: Entities::Person.create!(name: "Carla", avatar: image_upload), role: "Organizer")

    get "/api/v1/people.json"

    avatar_url = response.parsed_body["data"].find { |person| person["id"] == "carla" }.dig("attributes", "avatar_url")
    assert_match %r{\A/.+/carla-avatar\.png\z}, avatar_url
  end

  test "the schema is a valid OpenAPI document" do
    assert_empty OPENAPI.validate.map { |error| error["error"] }
  end

  test "the schema lists the values the models allow" do
    assert_equal Events::Event::KINDS + [ nil ], enum("EventAttributes", "kind")
    assert_equal Events::Event::STATUSES + [ nil ], enum("EventAttributes", "status")
    assert_equal Events::Event::DATE_PRECISIONS + [ nil ], enum("EventAttributes", "date_precision")
    assert_equal Events::Event::ATTENDANCE_MODES, enum("EventAttributes", "attendance_mode")
    assert_equal Events::Series::KINDS + [ nil ], enum("Series", "attributes", "properties", "kind")
    assert_equal Events::Series::FREQUENCIES + [ nil ], enum("Series", "attributes", "properties", "frequency")
    assert_equal Talks::Talk::KINDS, enum("Talk", "attributes", "properties", "kind")
    assert_equal Talks::AdditionalResource::KINDS, enum("AdditionalResource", "kind")
    assert_equal Language::NAMES.keys, OPENAPI.schema("LanguageCode").value["enum"]
  end

  private

  def identifiers_in(node)
    case node
    when Hash then node.keys.sort == %w[id type] ? [ node ] : node.values.flat_map { |value| identifiers_in(value) }
    when Array then node.flat_map { |value| identifiers_in(value) }
    else []
    end
  end

  def enum(schema, *path)
    OPENAPI.schema(schema).value["properties"].dig(*path, "enum")
  end
end
