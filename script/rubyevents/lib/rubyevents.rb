require "date"
require "fileutils"
require "json"
require "yaml"
require "active_support"
require "active_support/core_ext/string/inflections"
require_relative "talk_kind"

# Turns the Munich Rubyshift resources into rubyevents' data files. Unlike JsonApi,
# this is the part rubyevents adapts whenever their schemas change.
module Rubyevents
  LANGUAGES = { "en" => "English", "de" => "German" }.freeze
  COUNTRIES = { "DE" => "Germany" }.freeze
  MEETUP_HOST = "Meetup Host".freeze
  ORGANIZER = "Organizer".freeze

  # So that String#parameterize slugs like rubyevents, "Jürgen" becoming "juergen".
  I18n.load_path << File.expand_path("../snapshot/config/locales/transliterate.en.yml", __dir__)

  def self.country(code)
    COUNTRIES.fetch(code) { raise ArgumentError, "add the name of country #{code} to Rubyevents::COUNTRIES" }
  end

  # rubyevents shows long texts as plain text with links; ours are Markdown.
  def self.plain_text(markdown)
    markdown
      &.gsub(/\[([^\]]+)\]\(([^)\s]+)\)/) { $1 == $2 ? $2 : "#{$1} (#{$2})" }
      &.gsub(/<(https?:[^>\s]+)>/, '\1')
      &.gsub(/(\*\*?)(\S|\S.*?\S)\1/, '\2')
  end

  # Writes a series' directory from scratch, and merges the people, organizations
  # and cities its files refer to into the global lists, where ours wins.
  class Import
    attr_reader :report

    def initialize(store, site:, today: Date.today)
      @store = store
      @site = site.chomp("/")
      @today = today
      @referenced = Hash.new { |hash, type| hash[type] = {} }
      @report = Hash.new { |hash, key| hash[key] = [] }
    end

    def write(root)
      data = File.join(root, "data")
      @speakers, @organizations, @cities = %w[speakers organizations featured_cities].map { |list| ListFile.new(File.join(data, "#{list}.yml")) }
      @store.all("series").each { |series| write_series(series, data) }

      # A speaker's slug is their name parameterized, so it follows a rename.
      merge(@speakers, "people", defaults: { "github" => "" }, alias_renames: true) { |person| speaker(person) }
      # Other files refer to an organization by its slug, so theirs stays.
      merge(@organizations, "organizations", theirs: %w[slug], alias_renames: true) { |organization| organization(organization) }
      # rubyevents.org features every city in this list, so we only update theirs.
      merge(@cities, "cities", theirs: %w[slug], add: false) { |city| city(city) }
      report
    end

    private

    def write_series(series, data_dir)
      id = series["rubyevents_slug"] || series["name"].parameterize
      dir = File.join(data_dir, id)
      FileUtils.rm_rf(dir)
      YamlEmitter.write(File.join(dir, "series.yml"), series_file(series, id))

      series.related("events").each do |event|
        venue = event.related("venue")
        # rubyevents needs a location, which only the venue knows for an event in person.
        next report[:"events without a venue, skipped"] << event.id unless venue || event["attendance_mode"] == "online"

        event_id = event["rubyevents_slug"] || "#{id}-#{event.id}"
        write_event(event, series, venue, File.join(dir, event_id), event_id)
      end
    end

    def write_event(event, series, venue, dir, id)
      YamlEmitter.write(File.join(dir, "event.yml"), event_file(event, series, venue, id))
      YamlEmitter.write(File.join(dir, "venue.yml"), venue_file(venue)) if venue
      { "videos.yml" => videos_file(event, id), "involvements.yml" => involvements_file(event),
        "cfp.yml" => cfp_file(event), "sponsors.yml" => sponsors_file(event, venue) }.each do |name, content|
        YamlEmitter.write(File.join(dir, name), content) unless content.empty?
      end
    end

    def series_file(series, id)
      prune(
        "id" => id,
        "name" => series["name"],
        "description" => Rubyevents.plain_text(series["description"]),
        "kind" => series["kind"],
        "frequency" => series["frequency"],
        "ended" => (true if series["ended"]),
        "default_country_code" => series["default_country_code"],
        "language" => series["language_code"] && LANGUAGES.fetch(series["language_code"]),
        "website" => series["website"],
        "twitter" => series["twitter_username"],
        "facebook" => series["facebook"],
        "mastodon" => series["mastodon"],
        "bsky" => series["bluesky_handle"],
        "github" => series["github"],
        "linkedin" => series["linkedin"],
        "meetup" => series["meetup"],
        "luma" => series["luma"],
        "guild" => series["guild"]
      )
    end

    def event_file(event, series, venue, id)
      online = event["attendance_mode"] == "online"
      address = venue&.related("address")
      city = address&.related("city")

      prune(
        "id" => id,
        "title" => event["title"],
        "location" => online ? "online" : "#{city["name"]}, #{Rubyevents.country(city["country_code"])}",
        "timezone" => series["time_zone"],
        "kind" => event["kind"] || "meetup",
        "description" => Rubyevents.plain_text(event["description"]),
        "announced_on" => event["announced_on"],
        "date_precision" => event["date_precision"],
        "start_date" => event["start_date"],
        "end_date" => event["end_date"],
        "recordings_published_date" => event["published_at"]&.slice(0, 10),
        "status" => (event["status"] unless event["status"] == "scheduled"),
        "last_edition" => (true if event["last_edition"]),
        "hybrid" => (true if event["attendance_mode"] == "hybrid"),
        "website" => event["website"],
        "tickets_url" => event["tickets_url"],
        "meetup" => event["meetup"],
        "twitter" => event["twitter_username"],
        "mastodon" => event["mastodon"],
        "github" => event["github"],
        "luma" => event["luma"],
        "venue" => venue && venue["name"],
        "coordinates" => online ? false : address["coordinates"]
      )
    end

    def venue_file(venue)
      address = venue.related("address")
      city = remember(address.related("city"))
      country = Rubyevents.country(city["country_code"])
      map = venue["map"]

      prune(
        "name" => venue["name"],
        "description" => Rubyevents.plain_text(venue["description"]),
        "instructions" => Rubyevents.plain_text(venue["instructions"]),
        "url" => venue["website"],
        "address" => {
          "street" => address["street"],
          "city" => city["name"],
          "region" => city["state_code"],
          "postal_code" => address["zip_code"],
          "country" => country,
          "country_code" => city["country_code"],
          "display" => [ address["street"], [ address["zip_code"], city["name"] ].compact.join(" "), country ].compact.join(", ")
        },
        "coordinates" => address["coordinates"],
        "maps" => map && { "google" => map["google_url"], "apple" => map["apple_url"], "openstreetmap" => map["openstreetmap_url"] },
        # Our flags can't tell "no" from "not checked", so only "yes" goes over.
        "accessibility" => {
          "wheelchair" => (true if venue["accessibility_wheelchair"]),
          "elevators" => (true if venue["accessibility_elevators"]),
          "accessible_restrooms" => (true if venue["accessibility_restrooms"]),
          "notes" => Rubyevents.plain_text(venue["accessibility_notes"])
        },
        "nearby" => {
          "public_transport" => Rubyevents.plain_text(venue["nearby_public_transport"]),
          "parking" => Rubyevents.plain_text(venue["nearby_parking"])
        }
      )
    end

    def videos_file(event, event_id)
      talks = event.related("talks")
      ids = TalkIds.new(event_id, talks).to_h
      talks.map do |talk|
        speakers = talk.related("speakers").each { |person| remember(person) }
        id = talk["rubyevents_slug"] || ids.fetch(talk)

        prune(
          "id" => id,
          "title" => talk["title"],
          # rubyevents wants a kind unless both ours and the one their title implies are "talk".
          "kind" => (talk["kind"] unless talk["kind"] == "talk" && TalkKind.from_title(talk["title"]) == :talk),
          "date" => event["start_date"],
          # A blank announcement date means "together with the event".
          "announced_at" => talk["announced_on"] || event["announced_on"],
          "language" => LANGUAGES.fetch(talk["language_code"]),
          "slides_url" => talk["slides_url"],
          "video_provider" => upcoming?(event) ? "scheduled" : "not_recorded",
          # rubyevents wants a video id even without a video, and uses the talk's id.
          "video_id" => id,
          "description" => Rubyevents.plain_text(talk["description"]).to_s,
          "speakers" => speakers.map { |person| person["name"] },
          "additional_resources" => talk["additional_resources"].to_a.map do |resource|
            { "name" => resource["name"], "url" => resource["url"], "type" => resource["kind"], "title" => resource["title"] }
          end
        )
      end
    end

    def involvements_file(event)
      roles = event.related("involvements").group_by { |involvement| involvement["role"] || ORGANIZER }
      roles.sort_by { |role, _| [ role == ORGANIZER ? 0 : 1, role ] }.map do |role, involvements|
        entities = involvements.map { |involvement| remember(involvement.related("entity")) }

        prune(
          "name" => role,
          "users" => entities.select { |entity| entity.type == "people" }.map { |person| person["name"] },
          "organisations" => entities.select { |entity| entity.type == "organizations" }.map { |organization| organization_slug(organization) }
        )
      end
    end

    def cfp_file(event)
      event.related("cfps").map do |cfp|
        prune(
          "name" => cfp["name"],
          # A blank link means "on our website", a blank close date "the day before the event".
          "link" => cfp["external_url"] || "#{@site}/cfps/#{cfp.id}",
          "open_date" => cfp["open_date"],
          "close_date" => cfp["close_date"] || (event["start_date"] && (Date.iso8601(event["start_date"]) - 1).iso8601)
        )
      end
    end

    def sponsors_file(event, venue)
      host = venue&.related("organization")
      tiers = []
      tiers << { "name" => MEETUP_HOST, "sponsors" => [ { "slug" => organization_slug(remember(host)) } ] } if host

      event.related("sponsor_tiers").each do |tier|
        sponsors = tier.related("sponsorships").map do |sponsorship|
          prune("slug" => organization_slug(remember(sponsorship.related("organization"))), "badge" => sponsorship["badge"])
        end
        tiers << prune("name" => tier["name"], "description" => Rubyevents.plain_text(tier["description"]), "level" => tier["level"], "sponsors" => sponsors)
      end

      tiers.empty? ? [] : [ { "tiers" => tiers } ]
    end

    def speaker(person)
      name = person["name"]
      {
        "name" => name,
        "github" => person["github_username"],
        "twitter" => person["twitter_username"],
        "mastodon" => person["mastodon"],
        "bluesky" => person["bluesky_handle"],
        "linkedin" => person["linkedin_username"],
        "website" => person["website"],
        "speakerdeck" => person["speakerdeck_username"],
        "slug" => name.parameterize.then { |slug| slug.empty? ? person["github_username"].to_s.parameterize : slug }
      }
    end

    def organization(organization)
      {
        "name" => organization["name"],
        "slug" => organization["rubyevents_slug"],
        "website" => organization["website"],
        # Our logo is a path on our website.
        "logo_url" => organization["logo_url"] && "#{@site}#{organization["logo_url"]}"
      }
    end

    def city(city)
      coordinates = city["coordinates"]
      {
        "name" => city["name"],
        "slug" => city["rubyevents_slug"] || city["name"].parameterize,
        "state_code" => city["state_code"],
        "country_code" => city["country_code"],
        "latitude" => coordinates["latitude"],
        "longitude" => coordinates["longitude"]
      }
    end

    # Their slug where they list the organization already, since other files refer to it by that.
    def organization_slug(organization)
      record = organization(organization)
      entry, = @organizations.find(lookup(organization, record))
      entry ? entry.data["slug"] : record["slug"]
    end

    # An event without a date yet is still to come.
    def upcoming?(event)
      date = event["end_date"] || event["start_date"]
      date.nil? || Date.iso8601(date) >= @today
    end

    def remember(resource)
      @referenced[resource.type][resource.id] = resource
    end

    def merge(list, type, **options)
      @referenced[type].each_value do |resource|
        record = yield(resource)
        status, name = list.merge(record, lookup: lookup(resource, record), **options)
        report[:"#{list.name} #{status}"] << name
      end
      list.write
    end

    # How to find a record's entry in rubyevents' list, surest first. A person's
    # rubyevents_slug is their profile on rubyevents.org: the GitHub handle, or else the slug.
    def lookup(resource, record)
      keys = resource.type == "people" ? %w[github slug] : %w[slug]
      [ *keys.map { |key| [ key, resource["rubyevents_slug"] ] }, *keys.map { |key| [ key, record[key] ] },
        [ "name", record["name"] ], [ "aliases", record["name"] ] ]
    end

    # Drops what we don't know: nil, and empty lists and maps.
    def prune(hash)
      hash.filter_map do |key, value|
        value = prune(value) if value.is_a?(Hash)
        value = value.map { |item| item.is_a?(Hash) ? prune(item) : item } if value.is_a?(Array)
        [ key, value ] unless value.nil? || (value.respond_to?(:empty?) && value.empty? && !value.is_a?(String))
      end.to_h
    end
  end

  # The ids of an event's talks, as rubyevents' Talk::StaticID and TalkId validator
  # derive them: "firstname-lastname-<event id>" for one or two speakers, the kind
  # added on collisions, the kind alone for any other number of speakers, the
  # title when even that collides, and a number as the last resort. Talks with a
  # rubyevents_slug keep theirs, and nobody else gets it.
  class TalkIds
    def initialize(event_id, talks)
      @event_id = event_id
      @talks = talks
      @taken = talks.filter_map { |talk| talk["rubyevents_slug"] }
    end

    def to_h
      @talks.reject { |talk| talk["rubyevents_slug"] }.group_by { |talk| speaker_id(talk) }.each_with_object({}) do |(id, group), ids|
        next ids[group.first] = id if group.one? && available?(id)

        group.group_by { |talk| kind_id(talk) }.each do |with_kind, kind_group|
          next ids[kind_group.first] = with_kind if kind_group.one? && available?(with_kind)

          kind_group.group_by { |talk| title_id(talk) }.each do |with_title, title_group|
            next ids[title_group.first] = with_title if title_group.one? && available?(with_title)

            title_group.each.with_index(1) { |talk, index| ids[talk] = numbered(with_title, index) }
          end
        end
      end
    end

    private

    def speaker_id(talk)
      if speakers(talk).size.between?(1, 2)
        id_from(*speakers(talk))
      elsif talk["kind"] == "talk"
        title_id(talk)
      else
        id_from(talk["kind"].tr("_", "-"))
      end
    end

    def kind_id(talk)
      return speaker_id(talk) if talk["kind"] == "talk" || !speakers(talk).size.between?(1, 2)

      id_from(*speakers(talk), talk["kind"].tr("_", "-"))
    end

    def speakers(talk)
      talk.related("speakers").map { |person| person["name"] }
    end

    def title_id(talk)
      id_from(talk["title"])
    end

    def id_from(*parts)
      [ *parts.map(&:parameterize).reject(&:empty?), @event_id ].join("-")
    end

    def numbered(id, index)
      index += 1 until available?(candidate = id.delete_suffix("-#{@event_id}") + "-#{index}-#{@event_id}")
      candidate
    end

    def available?(id)
      !@taken.include?(id)
    end
  end

  # A list like data/speakers.yml, edited entry by entry, so that the entries we
  # don't change keep their exact text and formatting.
  class ListFile
    Entry = Struct.new(:text, :data) do
      def values(key)
        return [ data[key] ] unless key == "aliases"

        data["aliases"].to_a.map { |other| other.is_a?(Hash) ? other["name"] : other }
      end
    end

    def initialize(path)
      @path = path
      @header, *chunks = File.read(path).split(/^(?=- )/)
      @blank_lines = chunks.first.to_s.end_with?("\n\n")
      @entries = chunks.map { |chunk| Entry.new(chunk.sub(/\n+\z/, "\n"), YAML.safe_load(chunk).first) }
    end

    def name
      File.basename(@path)
    end

    # The entry that the first of the lookup's keys and values matches, and that key.
    def find(lookup)
      lookup.each do |key, value|
        next if value.to_s.empty?

        entry = @entries.find { |candidate| candidate.values(key).any? { |other| other.to_s.casecmp?(value) } }
        return [ entry, key ] if entry
      end
      nil
    end

    # Ours wins for each key we provide, except the keys in theirs; the keys only
    # rubyevents has stay. An entry found by one of its aliases keeps its name. With
    # alias_renames, a renamed entry keeps its old name as an alias, which other
    # files may still refer to. Without add, records they don't list are skipped.
    def merge(record, lookup:, defaults: {}, theirs: [], alias_renames: false, add: true)
      entry, key = find(lookup)
      return add ? insert(record, defaults) : [ :skipped, record["name"] ] unless entry
      return [ :conflict, "#{record["name"]}: GitHub #{entry.data["github"]}, ours #{record["github"]}" ] if other_github?(entry.data, record)

      theirs += %w[name] if key == "aliases"
      update(entry, entry.data.merge(record.compact, entry.data.slice(*theirs)), alias_renames:)
    end

    def write
      File.write(@path, @header + @entries.map(&:text).join(@blank_lines ? "\n" : ""))
    end

    private

    # The same name with another GitHub handle is most likely someone else.
    def other_github?(data, record)
      [ data["github"], record["github"] ].none? { |handle| handle.to_s.empty? } && !data["github"].casecmp?(record["github"])
    end

    def update(entry, merged, alias_renames:)
      return [ :unchanged, merged["name"] ] if merged == entry.data

      old_name = entry.data["name"]
      renamed = old_name != merged["name"]
      if renamed && alias_renames
        aliases = merged["aliases"].to_a.reject { |other| [ old_name, merged["name"] ].include?(other["name"]) }
        merged["aliases"] = [ *aliases, { "name" => old_name, "slug" => old_name.parameterize } ]
      end
      entry.data = merged
      entry.text = YamlEmitter.dump([ merged ]).delete_prefix("---\n")
      renamed ? [ :renamed, "#{old_name} -> #{merged["name"]}" ] : [ :updated, merged["name"] ]
    end

    def insert(record, defaults)
      data = record.merge(defaults) { |_key, ours, default| ours.nil? ? default : ours }.compact
      index = @entries.index { |other| other.data["name"].downcase > data["name"].downcase } || @entries.size
      @entries.insert(index, Entry.new(YamlEmitter.dump([ data ]).delete_prefix("---\n"), data))
      [ :added, data["name"] ]
    end
  end

  # Emits YAML laid out like rubyevents' files: lists indented below their key,
  # double-quoted strings and literal blocks for text. `yerba apply` does the rest.
  module YamlEmitter
    def self.write(path, value)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, dump(value))
    end

    def self.dump(value)
      "---\n#{lines(value, 0).join("\n")}\n"
    end

    def self.lines(value, indent)
      pad = " " * indent
      case value
      when Hash
        value.flat_map do |key, item|
          if item.is_a?(String) && item.include?("\n")
            [ "#{pad}#{key}: |-", *item.lines(chomp: true).map { |line| line.empty? ? "" : "#{pad}  #{line}" } ]
          elsif item.is_a?(Hash) || item.is_a?(Array)
            [ "#{pad}#{key}:", *lines(item, indent + 2) ]
          else
            [ "#{pad}#{key}: #{scalar(item)}" ]
          end
        end
      when Array
        value.flat_map do |item|
          next [ "#{pad}- #{scalar(item)}" ] unless item.is_a?(Hash)

          first, *rest = lines(item, indent + 2)
          [ "#{pad}- #{first.lstrip}", *rest ]
        end
      end
    end

    def self.scalar(value)
      value.is_a?(String) ? JSON.generate(value) : value.to_s
    end
  end
end
