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
      kind: meetup
      frequency: quarterly
      ended: false
      default_country_code: DE
      language: English
      website: https://munich-rubyshift.org
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

  test "venue.yml composes the address fields upstream requires but we do not store" do
    build_graph

    venue = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/venue.yml"])

    assert_equal "Germany", venue["address"]["country"]
    assert_equal "Berg-am-Laim-Straße 111, 81673 Munich, Germany", venue["address"]["display"]
    assert_equal "https://www.openstreetmap.org/?mlat=48.129604&mlon=11.625085", venue["maps"]["openstreetmap"]
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

  test "involvements.yml groups our per-entity rows by role" do
    build_graph

    involvements = YAML.safe_load(Rubyevents::Export.new(mode: :strict).files["munich-rubyshift/munich-rubyshift-2026-04/involvements.yml"])

    assert_equal [ { "name" => "Organizer", "users" => [ "Hans Schnedlitz" ] } ], involvements
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

    assert_match "videos.yml", error.message
    assert_match "missing id, description, date, video_provider, video_id", error.message
  end

  test "the zip contains every generated file" do
    build_graph
    export = Rubyevents::Export.new(mode: :strict)

    entries = []
    Zip::File.open_buffer(export.zip) { |zip| entries = zip.map(&:name) }

    assert_equal export.files.keys.sort, entries.sort
  end
end
