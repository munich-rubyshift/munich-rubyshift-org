require "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  include StorageTestHelper

  OPENAPI = JSONSchemer.openapi(YAML.load_file(Rails.root.join("public/api/v1/schema.yaml")))
  RUBYEVENTS_OPENAPI = JSONSchemer.openapi(YAML.load_file(Rails.root.join("public/api/rubyevents-v1/schema.yaml")))

  setup do
    Events::Event.update_all(kind: "meetup", status: nil, date_precision: nil)
    Events::Series.update_all(kind: "meetup")
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
    events_events(:two).update_columns(attendance_mode: "online", venues_venue_id: nil)

    {
      "/api/v1/people.json" => "PeopleDocument",
      "/api/v1/cities.json" => "CitiesDocument",
      "/api/v1/organizations.json" => "OrganizationsDocument",
      "/api/v1/series.json" => "SeriesDocument",
      "/api/v1/events/#{@event.id}.json" => "EventDocument",
      "/api/v1/events/#{events_events(:two).id}.json" => "EventDocument"
    }.each do |path, schema|
      get path

      assert_response :success
      assert_empty OPENAPI.schema(schema).validate(response.parsed_body).map { |error| error["error"] }, path
    end
  end

  test "an event refers to the records it includes and to records that their lists hold" do
    events_involvements(:two).update_columns(events_event_id: @event.id)

    get "/api/v1/events/#{@event.id}.json"
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

  test "a resource's id is its record's UUID, and its slug is an attribute" do
    get "/api/v1/events/#{@event.id}.json"
    event = response.parsed_body["data"]

    assert_equal [ @event.id, "meetup-2026-04-23" ], [ event["id"], event.dig("attributes", "slug") ]
    assert_equal [ { "type" => "involvements", "id" => events_involvements(:one).id } ],
      event.dig("relationships", "involvements", "data")
  end

  test "people are the speakers and those with a role, not those who only attended" do
    dora = Entities::Person.create!(name: "Dora")
    @event.involvements.create!(entity: dora, role: "Chef")
    @event.participations.create!(person: Entities::Person.create!(name: "Carla"))

    get "/api/v1/people.json"

    assert_equal %w[anna ben dora], response.parsed_body["data"].map { |person| person.dig("attributes", "slug") }
  end

  test "an event counts its attendees without naming them" do
    @event.participations.create!(person: Entities::Person.create!(name: "Carla"))

    get "/api/v1/events/#{@event.id}.json"

    assert_equal 2, response.parsed_body.dig("data", "attributes", "participants_count")
    assert_no_match(/carla/i, response.body)
  end

  test "an event and the records it includes hold the values they fall back to" do
    events_series(:one).update_columns(website: "https://munich-rubyshift.org")
    @event.update_columns(website: nil, announced_on: "2026-03-01")
    talks_talks(:one).update_columns(announced_on: nil)
    events_cfps(:one).update_columns(close_date: nil)

    get "/api/v1/events/#{@event.id}.json"
    included = response.parsed_body["included"]

    assert_equal "https://munich-rubyshift.org", response.parsed_body.dig("data", "attributes", "website")
    assert_equal "2026-03-01", included.find { |resource| resource["type"] == "talks" }.dig("attributes", "announced_on")
    assert_equal "2026-04-22", included.find { |resource| resource["type"] == "cfps" }.dig("attributes", "close_date")
  end

  test "an event lists the organization of its venue as a sponsor in a Meetup Host tier" do
    venues_venues(:one).update_columns(entities_organization_id: entities_organizations(:one).id)

    get "/api/v1/events/#{@event.id}.json"
    find = ->(identifier) { response.parsed_body["included"].find { |resource| resource.slice("type", "id") == identifier } }
    tier = response.parsed_body.dig("data", "relationships", "sponsor_tiers", "data").map(&find).find { |resource| resource.dig("attributes", "name") == "Meetup Host" }
    sponsorship = find.(tier.dig("relationships", "sponsorships", "data", 0))

    assert_equal({ "type" => "organizations", "id" => entities_organizations(:one).id }, sponsorship.dig("relationships", "organization", "data"))
  end

  test "an organization's internal notes stay private" do
    entities_organizations(:one).update_columns(internal_notes: "Invoices go to ATOSS")

    get "/api/v1/organizations.json"

    assert_response :success
    assert_no_match(/ATOSS/, response.body)
  end

  test "each list says there is no next page" do
    %w[people cities organizations series].each do |list|
      get "/api/v1/#{list}.json"

      assert_equal({ "next" => nil }, response.parsed_body["links"], list)
    end
  end

  test "a series refers to its events, newest first, by the ids of their documents" do
    older = events_events(:two)
    older.update_columns(events_series_id: events_series(:one).id, start_date: "2026-01-22", end_date: "2026-01-22")

    get "/api/v1/series.json"
    events = response.parsed_body["data"].find { |series| series["id"] == events_series(:one).id }.dig("relationships", "events", "data")

    assert_equal [ { "type" => "events", "id" => @event.id }, { "type" => "events", "id" => older.id } ], events

    get "/api/v1/events/#{older.id}.json"

    assert_response :success
  end

  test "RubyEvents gets each record's values with its rubyevents_data put over them" do
    venues_venues(:one).update_columns(locations_map_id: locations_maps(:one).id)
    @event.update_columns(rubyevents_data: { "slug" => "2026-04-23", "subtitle" => "Talks and drinks" })
    entities_people(:one).update_columns(rubyevents_data: { "name" => nil })
    locations_maps(:one).update_columns(rubyevents_data: { "google_url" => nil })
    talks_additional_resources(:one).update_columns(rubyevents_data: { "kind" => "video" })

    get "/api/rubyevents-v1/events/#{@event.id}.json"
    event = response.parsed_body["data"]
    venue, talk = %w[venues talks].map do |type|
      response.parsed_body["included"].find { |resource| resource["type"] == type }
    end

    assert_equal [ @event.id, "2026-04-23", "Talks and drinks", "meetup" ],
      [ event["id"], *event["attributes"].values_at("slug", "subtitle", "kind") ]
    assert_nil venue.dig("attributes", "map", "google_url")
    assert_equal "video", talk.dig("attributes", "additional_resources", 0, "kind")

    get "/api/rubyevents-v1/people.json"

    assert_nil response.parsed_body["data"].find { |person| person["id"] == entities_people(:one).id }.dig("attributes", "name")
  end

  test "each RubyEvents document matches its schema, while v1 leaves the RubyEvents data out" do
    venues_venues(:one).update_columns(entities_organization_id: entities_organizations(:one).id, locations_map_id: locations_maps(:one).id)
    events_involvements(:two).update_columns(events_event_id: @event.id)
    [ events_series(:one), entities_people(:one), entities_organizations(:one), locations_cities(:one), @event,
      venues_venues(:one), talks_talks(:one), sponsors_sponsor_tiers(:one), events_cfps(:one) ]
      .each { |record| record.update_columns(rubyevents_data: { "slug" => "rubyevents-slug" }) }

    {
      "people.json" => "PeopleDocument",
      "cities.json" => "CitiesDocument",
      "organizations.json" => "OrganizationsDocument",
      "series.json" => "SeriesDocument",
      "events/#{@event.id}.json" => "EventDocument"
    }.each do |path, schema|
      get "/api/rubyevents-v1/#{path}"

      assert_empty RUBYEVENTS_OPENAPI.schema(schema).validate(response.parsed_body).map { |error| error["error"] }, path
      assert_includes response.body, "rubyevents-slug", path

      get "/api/v1/#{path}"

      assert_empty OPENAPI.schema(schema).validate(response.parsed_body).map { |error| error["error"] }, path
      assert_not_includes response.body, "rubyevents-slug", path
    end
  end

  test "the RubyEvents schema rejects values it doesn't document" do
    events_series(:one).update_columns(rubyevents_data: { "undocumented" => true })
    get "/api/rubyevents-v1/series.json"

    assert_match %r{/attributes/undocumented}, RUBYEVENTS_OPENAPI.schema("SeriesDocument").validate(response.parsed_body).map { |error| error["error"] }.join
  end

  test "the RubyEvents schema checks the values it documents beyond v1" do
    events_series(:one).update_columns(rubyevents_data: { "frequency" => "quarterly", "inactive" => false })
    get "/api/rubyevents-v1/series.json"

    assert_empty RUBYEVENTS_OPENAPI.schema("SeriesDocument").validate(response.parsed_body).map { |error| error["error"] }

    events_series(:one).update_columns(rubyevents_data: { "frequency" => "sometimes" })
    get "/api/rubyevents-v1/series.json"

    assert_match %r{/attributes/frequency}, RUBYEVENTS_OPENAPI.schema("SeriesDocument").validate(response.parsed_body).map { |error| error["error"] }.join
  end

  test "each resource and embedded value for RubyEvents carries the rubyevents_data of its own record" do
    venues_venues(:one).update_columns(locations_map_id: locations_maps(:one).id)
    embedded = { "map" => "Locations::Map", "additional_resources" => "Talks::AdditionalResource" }
    (Api::V1::Serializer::TYPES.keys + embedded.values).each { |name| name.constantize.update_all(rubyevents_data: { "source" => name }) }

    resources = %w[people cities organizations series].flat_map do |list|
      get "/api/rubyevents-v1/#{list}.json"
      response.parsed_body["data"]
    end
    get "/api/rubyevents-v1/events/#{@event.id}.json"
    resources += [ response.parsed_body["data"], *response.parsed_body["included"] ]

    assert_equal Api::V1::Serializer::TYPES.values.sort, resources.map { |resource| resource["type"] }.uniq.sort
    assert_equal resources.map { |resource| Api::V1::Serializer::TYPES.key(resource["type"]) },
      resources.map { |resource| resource.dig("attributes", "source") }
    embedded.each do |attribute, source|
      values = resources.filter_map { |resource| resource["attributes"][attribute] }.flatten

      assert_equal [ source ], values.map { |value| value["source"] }.uniq, attribute
    end
  end

  test "a person links to their avatar" do
    check_out_storage
    @event.involvements.create!(entity: Entities::Person.create!(name: "Carla", avatar: image_upload), role: "Organizer")

    get "/api/v1/people.json"

    avatar_url = response.parsed_body["data"].find { |person| person.dig("attributes", "slug") == "carla" }.dig("attributes", "avatar_url")
    assert_match %r{\A/.+/carla-avatar\.png\z}, avatar_url
  end

  test "the schema is a valid OpenAPI document" do
    assert_empty OPENAPI.validate.map { |error| error["error"] }
  end

  test "the RubyEvents schema is a valid OpenAPI document" do
    assert_empty RUBYEVENTS_OPENAPI.validate.map { |error| error["error"] }
  end

  test "the schema is the bundle of its sources" do
    assert_bundle_of_sources "v1"
  end

  test "the RubyEvents schema is the bundle of its sources" do
    assert_bundle_of_sources "rubyevents-v1"
  end

  test "the schema lists the values the models allow" do
    assert_equal Events::Event::KINDS + [ nil ], enum("EventAttributes", "kind")
    assert_equal Events::Event::STATUSES + [ nil ], enum("EventAttributes", "status")
    assert_equal Events::Event::DATE_PRECISIONS + [ nil ], enum("EventAttributes", "date_precision")
    assert_equal Events::Event::ATTENDANCE_MODES, enum("EventAttributes", "attendance_mode")
    assert_equal Events::Series::KINDS + [ nil ], enum("Series", "attributes", "properties", "kind")
    assert_equal Talks::Talk::KINDS, enum("Talk", "attributes", "properties", "kind")
    assert_equal Talks::AdditionalResource::KINDS, enum("AdditionalResource", "kind")
    assert_equal Language::NAMES.keys, OPENAPI.schema("LanguageCode").value["enum"]
  end

  test "the schema renders as a page" do
    get "/api/schema"

    assert_response :success
    assert_select "#api-reference"
    assert_select "script[src*='api_reference']"
  end

  private

  # Bundling an API by name writes to its configured output, so this bundles in a copy.
  def assert_bundle_of_sources(api)
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "doc"))
      FileUtils.cp_r(Rails.root.join("doc/api"), File.join(dir, "doc"))
      FileUtils.cp(Rails.root.join("redocly.yaml"), dir)
      assert system({ "REDOCLY_SUPPRESS_NOTIFICATIONS" => "true" }, Rails.root.join("node_modules/.bin/redocly").to_s, "bundle", api,
        chdir: dir, out: File::NULL, err: File::NULL)

      assert File.read(File.join(dir, "public/api/#{api}/schema.yaml")) == Rails.root.join("public/api/#{api}/schema.yaml").read,
        "run `yarn schema:bundle` after editing doc/api"
    end
  end

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
