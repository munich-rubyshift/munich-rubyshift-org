require "test_helper"
require_relative "../../support/rubyevents_graph"

class Rubyevents::ExportTest < ActiveSupport::TestCase
  include RubyeventsGraph

  test "strict export writes our records verbatim into their layout" do
    build_graph

    files = Rubyevents::Export.new(mode: :strict).files

    assert_equal [
      "munich-rubyshift/munich-rubyshift-2026-04/event.yml",
      "munich-rubyshift/munich-rubyshift-2026-04/involvements.yml",
      "munich-rubyshift/munich-rubyshift-2026-04/sponsors.yml",
      "munich-rubyshift/munich-rubyshift-2026-04/venue.yml",
      "munich-rubyshift/munich-rubyshift-2026-04/videos.yml",
      "munich-rubyshift/series.yml",
      "speakers/speakers.yml"
    ], files.keys.sort
  end

  test "series.yml drops discord, which has no upstream field" do
    build_graph
    export = Rubyevents::Export.new(mode: :strict)

    assert_equal <<~YAML, export.files["munich-rubyshift/series.yml"]
      ---
      id: munich-rubyshift
      name: Munich Rubyshift
      website: https://munich-rubyshift.org
      kind: meetup
      frequency: quarterly
      language: English
      default_country_code: DE
      ended: false
    YAML

    assert_includes export.warnings, "series.discord: no field in SeriesSchema"
  end

  test "event.yml derives location, timezone and coordinates from the venue" do
    build_graph

    event = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/event.yml"])

    assert_equal "munich-rubyshift-2026-04", event["id"]
    assert_equal "Munich, Germany", event["location"]
    assert_equal "Europe/Berlin", event["timezone"]
    assert_equal({ "latitude" => 48.129604, "longitude" => 11.625085 }, event["coordinates"])
  end

  test "event.yml spells out only what upstream does not assume, in their key order" do
    graph = build_graph
    graph[:event].update!(
      description: "Two talks.\r\n\r\nAnd pizza.\r\n", status: "scheduled", date_precision: "day",
      start_time: "18:30", end_time: "22:00"
    )
    export = Rubyevents::Export.new(mode: :strict)

    event = YAML.safe_load(export.files["munich-rubyshift/munich-rubyshift-2026-04/event.yml"])

    assert_equal "Two talks.\n\nAnd pizza.", event["description"]
    assert_equal %w[id title location timezone kind description start_date end_date website venue coordinates], event.keys
    assert_includes export.warnings, "event.start_time/end_time: no field in EventSchema"
  end

  test "leaves out cancelled events, and people who only organized those" do
    graph = build_graph
    cancelled = Events::Event.create!(
      series: graph[:series], title: "Cancelled", slug: "meetup-2026-07-01", kind: "meetup", status: "cancelled",
      attendance_mode: "in_person", start_date: Date.new(2026, 7, 1), end_date: Date.new(2026, 7, 1)
    )
    organizer = Entities::Person.create!(name: "Ada Lovelace", slug: "ada-lovelace")
    Events::Involvement.create!(event: cancelled, entity: organizer, role: "Organizer")

    files = Rubyevents::Export.new(mode: :strict).files

    assert_empty files.keys.grep(/meetup-2026-07-01/)
    assert_equal [ "Hans Schnedlitz" ], YAML.safe_load(files["speakers/speakers.yml"]).map { _1["name"] }
  end

  test "event.yml marks an online event the way upstream does" do
    graph = build_graph
    Events::Event.create!(
      series: graph[:series], title: "Online", slug: "meetup-2026-07-01", kind: "meetup",
      attendance_mode: "online", start_date: Date.new(2026, 7, 1), end_date: Date.new(2026, 7, 1)
    )

    event = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-meetup-2026-07-01/event.yml"])

    assert_equal "online", event["location"]
    assert_equal "Europe/Berlin", event["timezone"]
    assert_equal false, event["coordinates"]
  end

  test "venue.yml composes the address fields upstream requires but we do not store" do
    build_graph

    venue = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/venue.yml"])

    assert_equal "Germany", venue["address"]["country"]
    assert_equal "Berg-am-Laim-Straße 111, 81673 Munich, Germany", venue["address"]["display"]
    assert_equal "https://www.openstreetmap.org/?mlat=48.129604&mlon=11.625085", venue["maps"]["openstreetmap"]
  end

  test "sponsors.yml lists the venue's organization as the meetup host, then our sponsors" do
    build_graph

    assert_equal <<~YAML, Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/sponsors.yml"]
      ---
      - tiers:
        - name: Meetup Host
          sponsors:
          - name: Freeletics
            slug: freeletics
            website: https://www.freeletics.com
        - name: Pizza & Drinks
          level: 1
          sponsors:
          - name: AppSignal
            slug: appsignal
            website: https://www.appsignal.com
    YAML
  end

  test "sponsors.yml lists the meetup host of an event without sponsors" do
    graph = build_graph
    Sponsors::Sponsorship.delete_all
    Sponsors::SponsorTier.delete_all

    sponsors = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/sponsors.yml"])

    assert_equal [ "Meetup Host" ], sponsors.first["tiers"].map { _1["name"] }

    graph[:venue].update!(organization: nil)

    assert_not_includes Rubyevents::Export.new(mode: :strict).files.keys, "munich-rubyshift/munich-rubyshift-2026-04/sponsors.yml"
  end

  test "videos.yml uses rubyevents_slug as the id and lists speakers by name" do
    build_graph

    videos = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/videos.yml"])

    assert_equal 1, videos.size
    assert_equal "gems-are-overrated-at-munich-rubyshift", videos.first["id"]
    assert_equal [ "Hans Schnedlitz" ], videos.first["speakers"]
    assert_equal "2026-04-23", videos.first["date"]
    assert_equal "not_recorded", videos.first["video_provider"]
  end

  test "speakers.yml reduces our profile URLs to the bare handles upstream wants" do
    build_graph

    speakers = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["speakers/speakers.yml"])

    assert_equal({
      "name" => "Hans Schnedlitz",
      "slug" => "hans-schnedlitz",
      "github" => "hschne",
      "twitter" => "hschnedlitz",
      "website" => "https://hansschnedlitz.com",
      "mastodon" => "https://ruby.social/@hschne",
      "bluesky" => "hschne",
      "linkedin" => "hschne"
    }, speakers.first)
  end

  test "speakers.yml lists exactly the people upstream sees named, slugged after their names" do
    graph = build_graph
    graph[:speaker].update!(rubyevents_slug: "hschne")
    helper = Entities::Person.create!(name: "Jürgen Müßig", slug: "juergen-muessig")
    Events::Involvement.create!(event: graph[:event], entity: helper, role: "Chef")
    attendee = Entities::Person.create!(name: "Ada Lovelace", slug: "ada-lovelace")
    Events::Participation.create!(event: graph[:event], person: attendee)

    speakers = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["speakers/speakers.yml"])

    assert_equal [ "Hans Schnedlitz", "Jürgen Müßig" ], speakers.map { _1["name"] }
    assert_equal [ "hans-schnedlitz", "jurgen-mussig" ], speakers.map { _1["slug"] }
    assert_equal "", speakers.last["github"]
  end

  test "involvements.yml groups our per-entity rows by role" do
    build_graph

    involvements = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/involvements.yml"])

    assert_equal [ { "name" => "Organizer", "users" => [ "Hans Schnedlitz" ] } ], involvements
  end

  test "involvements.yml lists organizers first, then the other roles alphabetically" do
    graph = build_graph
    [ "Photo box", "Chef" ].each { |role| Events::Involvement.create!(event: graph[:event], entity: graph[:speaker], role: role) }

    involvements = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/involvements.yml"])

    assert_equal [ "Organizer", "Chef", "Photo box" ], involvements.map { _1["name"] }
  end

  test "a complete graph passes every vendored schema" do
    build_graph

    assert_empty Rubyevents::Export.new(mode: :strict).errors
  end

  test "lenient export of incomplete data passes every vendored schema" do
    build_graph(complete: false)

    export = Rubyevents::Export.new(mode: :lenient)

    assert_empty export.errors, export.errors.join("\n")
    assert_nothing_raised { export.validate! }
  end

  test "strict export of incomplete data fails, naming the missing fields" do
    build_graph(complete: false)

    error = assert_raises(Rubyevents::Export::InvalidDocument) do
      Rubyevents::Export.new(mode: :strict).validate!
    end

    assert_match "sponsors.yml [0]/tiers/0/sponsors/0: missing website", error.message
  end

  test "event and talk ids are derived where we hold none" do
    build_graph(complete: false)

    files = Rubyevents::Export.new(mode: :strict).files
    videos = YAML.safe_load(files["munich-rubyshift/munich-rubyshift-meetup-2026-04-23/videos.yml"])

    assert_equal "munich-rubyshift-meetup-2026-04-23", YAML.safe_load(files["munich-rubyshift/munich-rubyshift-meetup-2026-04-23/event.yml"])["id"]
    assert_equal "hans-schnedlitz-munich-rubyshift-meetup-2026-04-23", videos.first["id"]
    assert_equal videos.first["id"], videos.first["video_id"]
  end

  test "videos.yml schedules the talks of an event that is not over yet, including on its day" do
    build_graph

    travel_to Date.new(2026, 4, 23) do
      videos = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/videos.yml"])

      assert_equal "scheduled", videos.first["video_provider"]
    end
  end

  test "videos.yml only spells out a kind that upstream would not infer from the title" do
    graph = build_graph
    lightning = Talks::Talk.create!(event: graph[:event], title: "Gems again", kind: "lightning_talk", language_code: "en")
    misleading = Talks::Talk.create!(event: graph[:event], title: "Panel of one", kind: "talk", language_code: "en")

    videos = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/videos.yml"])

    assert_equal [ nil, "lightning_talk", "talk" ], videos.map { _1["kind"] }
    assert_equal [ graph[:talk].title, lightning.title, misleading.title ], videos.map { _1["title"] }
  end

  test "writes the same tree as the zip" do
    build_graph
    export = Rubyevents::Export.new(mode: :strict)

    Dir.mktmpdir do |directory|
      export.write_to(directory)

      export.files.each { |path, content| assert_equal content, File.read(File.join(directory, path)) }
    end
  end

  test "the zip contains every generated file" do
    build_graph
    export = Rubyevents::Export.new(mode: :strict)

    entries = []
    Zip::File.open_buffer(export.zip) { |zip| entries = zip.map(&:name) }

    assert_equal export.files.keys.sort, entries.sort
  end
end
