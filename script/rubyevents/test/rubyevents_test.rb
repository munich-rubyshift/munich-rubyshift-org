require_relative "test_helper"

class SlugTest < Minitest::Test
  def test_transliterates_like_rubyevents_parameterize
    assert_equal "juergen-kuzma-strasse-o-ae", Rubyevents.slug("Jürgen Kuźma, Straße Ö ä")
  end
end

class ListFileTest < Minitest::Test
  SPEAKERS = <<-YAML.gsub(/^ {4}/, "")
    ---
    - name: "Ada Lovelace"
      github: "ada"
      slug: "ada-lovelace"
    - name: 'Kuba Kuzma' # theirs
      github: ""
      twitter: "kuba"
      slug: "kuba-kuzma"
    - name: "Zoe Zed"
      github: ""
      slug: "zoe-zed"
  YAML

  def setup
    @path = File.join(Dir.mktmpdir, "speakers.yml")
    File.write(@path, SPEAKERS)
  end

  def merge(record, **options)
    list = Rubyevents::ListFile.new(@path)
    status = list.merge(record, lookup: [ [ "slug", record["slug"] ], [ "name", record["name"] ] ], **options)
    list.write
    status
  end

  def test_ours_wins_and_keeps_the_keys_only_rubyevents_has
    status = merge({ "name" => "Ada Lovelace", "github" => nil, "website" => "https://ada.example", "slug" => "ada-lovelace" })

    assert_equal [ :updated, "Ada Lovelace" ], status
    assert_equal({ "name" => "Ada Lovelace", "github" => "ada", "slug" => "ada-lovelace", "website" => "https://ada.example" }, YAML.load_file(@path).first)
  end

  def test_entries_without_changes_keep_their_text
    assert_equal [ :unchanged, "Kuba Kuzma" ], merge({ "name" => "Kuba Kuzma", "twitter" => "kuba", "slug" => "kuba-kuzma" })
    merge({ "name" => "Ada Lovelace", "website" => "https://ada.example", "slug" => "ada-lovelace" })

    assert_includes File.read(@path), "- name: 'Kuba Kuzma' # theirs\n"
  end

  def test_a_rename_keeps_the_old_name_as_an_alias
    status = merge({ "name" => "Kuba Kuźma", "slug" => "kuba-kuzma" }, alias_renames: true)

    assert_equal [ :renamed, "Kuba Kuzma -> Kuba Kuźma" ], status
    assert_equal [ { "name" => "Kuba Kuzma", "slug" => "kuba-kuzma" } ], YAML.load_file(@path)[1]["aliases"]
  end

  def test_keys_in_theirs_stay
    merge({ "name" => "Kuba Kuźma", "slug" => "kuba-kuzma-2" }, theirs: %w[slug])

    assert_equal "kuba-kuzma", YAML.load_file(@path)[1]["slug"]
  end

  def test_the_first_matching_lookup_wins
    list = Rubyevents::ListFile.new(@path)

    status = list.merge({ "name" => "Zoe Zed", "slug" => "zoe-zed" }, lookup: [ [ "github", "ADA" ], [ "name", "Zoe Zed" ] ])

    assert_equal [ :renamed, "Ada Lovelace -> Zoe Zed" ], status
  end

  def test_adds_new_entries_in_name_order_with_defaults
    assert_equal [ :added, "bob Builder" ], merge({ "name" => "bob Builder", "github" => nil, "slug" => "bob-builder" }, defaults: { "github" => "" })

    assert_equal [ "Ada Lovelace", "bob Builder", "Kuba Kuzma", "Zoe Zed" ], YAML.load_file(@path).map { |entry| entry["name"] }
    assert_includes File.read(@path), %(- name: "bob Builder"\n  github: ""\n  slug: "bob-builder"\n- name: 'Kuba Kuzma')
  end

  def test_keeps_blank_lines_between_entries
    File.write(@path, "---\n- name: \"A\"\n  slug: \"a\"\n\n- name: \"C\"\n  slug: \"c\"\n")

    merge({ "name" => "B", "slug" => "b" })

    assert_equal "---\n- name: \"A\"\n  slug: \"a\"\n\n- name: \"B\"\n  slug: \"b\"\n\n- name: \"C\"\n  slug: \"c\"\n", File.read(@path)
  end
end

class YamlEmitterTest < Minitest::Test
  def test_lays_out_like_rubyevents
    yaml = Rubyevents::YamlEmitter.dump([ { "name" => "Meetup", "description" => "One\n\nTwo", "tiers" => [ { "level" => 1, "sponsors" => [ { "slug" => "acme" } ] } ] } ])

    assert_equal <<-YAML.gsub(/^ {6}/, ""), yaml
      ---
      - name: "Meetup"
        description: |-
          One

          Two
        tiers:
          - level: 1
            sponsors:
              - slug: "acme"
    YAML
  end
end

class TalkIdsTest < Minitest::Test
  include ResourceHelper

  def setup
    @store = JsonApi::Store.new
    @store.add(resource_data("people", "ada", name: "Ada Lovelace"))
    @store.add(resource_data("people", "bob", name: "Bob Builder"))
    @store.add(resource_data("people", "cy", name: "Cy Twombly"))
  end

  def talk(id, speakers, title: "Some talk", kind: "talk", rubyevents_slug: nil)
    @store.add(resource_data("talks", id, title:, kind:, rubyevents_slug:,
      relationships: { speakers: speakers.map { |speaker| identifier("people", speaker) } }))
  end

  def ids(*talks)
    Rubyevents::TalkIds.new("meetup", talks).to_h.transform_keys(&:id)
  end

  def test_names_one_or_two_speakers
    assert_equal({ "a" => "ada-lovelace-meetup", "b" => "ada-lovelace-bob-builder-meetup" }, ids(talk("a", %w[ada]), talk("b", %w[ada bob])))
  end

  def test_adds_the_kind_when_speakers_collide
    assert_equal({ "a" => "ada-lovelace-meetup", "b" => "ada-lovelace-lightning-talk-meetup" },
      ids(talk("a", %w[ada]), talk("b", %w[ada], kind: "lightning_talk")))
  end

  def test_falls_back_to_the_title_and_then_a_number
    assert_equal({ "a" => "first-meetup", "b" => "second-meetup", "c" => "same-1-meetup", "d" => "same-2-meetup" },
      ids(talk("a", %w[ada], title: "First"), talk("b", %w[ada], title: "Second"), talk("c", %w[bob], title: "Same"), talk("d", %w[bob], title: "Same")))
  end

  def test_names_other_numbers_of_speakers_by_kind_or_title
    assert_equal({ "a" => "panel-meetup", "b" => "intro-meetup" },
      ids(talk("a", %w[ada bob cy], kind: "panel"), talk("b", [], title: "Intro")))
  end

  def test_keeps_the_ids_rubyevents_already_has
    assert_equal({ "b" => "some-talk-meetup" }, ids(talk("a", %w[bob], rubyevents_slug: "ada-lovelace-meetup"), talk("b", %w[ada])))
  end
end

class ImportTest < Minitest::Test
  include ResourceHelper

  def setup
    @root = Dir.mktmpdir
    FileUtils.mkdir_p(File.join(@root, "data/munich-rubyshift/munich-rubyshift"))
    File.write(File.join(@root, "data/speakers.yml"), "---\n- name: \"Ada Lovelace\"\n  github: \"ada\"\n  slug: \"ada-lovelace\"\n")
    %w[organizations featured_cities].each { |list| File.write(File.join(@root, "data/#{list}.yml"), "---\n") }

    @store = JsonApi::Store.new
    @store.add(resource_data("people", "ada", name: "Ada Lovelace", twitter_username: "ada"))
    @store.add(resource_data("people", "bob", name: "Bob Builder"))
    @store.add(resource_data("talks", "recap", title: "Recap of RailsConf", kind: "talk", language_code: "en",
      relationships: { speakers: [ identifier("people", "ada"), identifier("people", "bob") ] }))
    @store.add(event("meetup-2026-09-24", talks: [ identifier("talks", "recap") ]))
    @store.add(event("meetup-2026-10-24", status: "cancelled"))
    @store.add(resource_data("series", "munich-rubyshift", name: "Munich Rubyshift", rubyevents_slug: "munich-rubyshift",
      relationships: { events: [ identifier("events", "meetup-2026-09-24"), identifier("events", "meetup-2026-10-24") ] }))
  end

  def event(id, talks: [], **attributes)
    resource_data("events", id, title: "Meetup", attendance_mode: "online", start_date: id.delete_prefix("meetup-"), **attributes,
      relationships: { venue: nil, talks:, involvements: [], cfps: [], sponsor_tiers: [] })
  end

  def write
    Rubyevents::Import.new(@store, site: "https://munich.example", today: Date.new(2026, 11, 5)).write(@root)
  end

  def load(path)
    YAML.load_file(File.join(@root, "data", path))
  end

  def test_replaces_the_series_without_cancelled_events
    write

    assert_equal %w[munich-rubyshift-meetup-2026-09-24 series.yml], Dir.children(File.join(@root, "data/munich-rubyshift")).sort
  end

  def test_writes_talks_with_the_kind_rubyevents_would_not_guess
    write

    talk = load("munich-rubyshift/munich-rubyshift-meetup-2026-09-24/videos.yml").first
    assert_equal [ "ada-lovelace-bob-builder-munich-rubyshift-meetup-2026-09-24", "talk", [ "Ada Lovelace", "Bob Builder" ] ],
      talk.values_at("id", "kind", "speakers")
  end

  def test_merges_the_speakers_into_rubyevents_list
    report = write

    assert_equal [
      { "name" => "Ada Lovelace", "github" => "ada", "slug" => "ada-lovelace", "twitter" => "ada" },
      { "github" => "", "name" => "Bob Builder", "slug" => "bob-builder" }
    ], load("speakers.yml")
    assert_equal [ "Bob Builder" ], report[:"speakers.yml added"]
  end
end
