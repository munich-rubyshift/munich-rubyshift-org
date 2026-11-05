require "date"
require "fileutils"
require "json"
require "yaml"
require_relative "talk_kind"

# Turns the Munich Rubyshift resources into rubyevents' data files. Unlike JsonApi,
# this is the part rubyevents adapts whenever their schemas change.
module Rubyevents
  LANGUAGES = { "en" => "English", "de" => "German" }.freeze
  COUNTRIES = { "DE" => "Germany" }.freeze
  MEETUP_HOST = "Meetup Host".freeze

  # rubyevents' I18n transliteration rules, on top of the default ones.
  TRANSLITERATIONS = { "ü" => "ue", "ö" => "oe", "ä" => "ae", "ß" => "ss" }.freeze

  # Like rubyevents' String#parameterize, so "Jürgen Kuźma" becomes "juergen-kuzma".
  def self.slug(text)
    text.gsub(Regexp.union(TRANSLITERATIONS.keys), TRANSLITERATIONS).unicode_normalize(:nfkd).gsub(/\p{Mn}/, "").downcase
      .gsub(/[^a-z0-9\-_]+/, "-").squeeze("-").delete_prefix("-").delete_suffix("-")
  end

  def self.country(code)
    COUNTRIES.fetch(code) { raise ArgumentError, "add the name of country #{code} to Rubyevents::COUNTRIES" }
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
      @store.all("series").each { |series| write_series(series, File.join(root, "data")) }

      # A speaker's slug is their name parameterized, so it follows a rename. Other
      # files refer to organizations by slug, so theirs stays.
      merge(File.join(root, "data/speakers.yml"), referenced("people"), defaults: { "github" => "" }, alias_renames: true) { |person| speaker(person) }
      merge(File.join(root, "data/organizations.yml"), referenced("organizations"), theirs: %w[slug], alias_renames: true) { |organization| organization(organization) }
      merge(File.join(root, "data/featured_cities.yml"), referenced("cities"), theirs: %w[slug]) { |city| city(city) }
      report
    end

    private

    def write_series(series, data_dir)
      id = rubyevents_id(series) { Rubyevents.slug(series["name"]) }
      dir = File.join(data_dir, id)
      FileUtils.rm_rf(dir)
      YamlEmitter.write(File.join(dir, "series.yml"), series_file(series, id))

      series.related("events").reject { |event| event["status"] == "cancelled" }.each do |event|
        event_id = rubyevents_id(event) { "#{id}-#{event.id}" }
        write_event(event, series, File.join(dir, event_id), event_id)
      end
    end

    def write_event(event, series, dir, id)
      venue = event.related("venue")
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
        "description" => series["description"],
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
      city = venue&.related("address")&.related("city")
      raise ArgumentError, "event #{event.id} takes place in person, but has no venue" unless online || venue

      prune(
        "id" => id,
        "title" => event["title"],
        "location" => online ? "online" : "#{city["name"]}, #{Rubyevents.country(city["country_code"])}",
        "timezone" => series["time_zone"],
        "kind" => event["kind"] || "meetup",
        "description" => event["description"],
        "announced_on" => event["announced_on"],
        "date_precision" => event["date_precision"],
        "start_date" => event["start_date"],
        "end_date" => event["end_date"],
        "recordings_published_date" => event["published_at"]&.slice(0, 10),
        "status" => (event["status"] if event["status"] == "postponed"),
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
        "coordinates" => online ? false : coordinates(venue.related("address"))
      )
    end

    def venue_file(venue)
      address = venue.related("address")
      city = remember(address.related("city"))
      country = Rubyevents.country(city["country_code"])
      map = venue["map"]

      prune(
        "name" => venue["name"],
        "description" => venue["description"],
        "instructions" => venue["instructions"],
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
        "coordinates" => coordinates(address),
        "maps" => map && { "google" => map["google_url"], "apple" => map["apple_url"], "openstreetmap" => map["openstreetmap_url"] },
        # Our flags can't tell "no" from "not checked", so only "yes" goes over.
        "accessibility" => {
          "wheelchair" => (true if venue["accessibility_wheelchair"]),
          "elevators" => (true if venue["accessibility_elevators"]),
          "accessible_restrooms" => (true if venue["accessibility_restrooms"]),
          "notes" => venue["accessibility_notes"]
        },
        "nearby" => { "public_transport" => venue["nearby_public_transport"], "parking" => venue["nearby_parking"] }
      )
    end

    def videos_file(event, event_id)
      talks = event.related("talks")
      ids = TalkIds.new(event_id, talks).to_h
      talks.map do |talk|
        speakers = talk.related("speakers").each { |person| remember(person) }
        id = rubyevents_id(talk) { ids.fetch(talk) }

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
          "description" => talk["description"].to_s,
          "speakers" => speakers.map { |person| person["name"] },
          "additional_resources" => talk["additional_resources"].to_a.map do |resource|
            { "name" => resource["name"], "url" => resource["url"], "type" => resource["kind"], "title" => resource["title"] }
          end
        )
      end
    end

    def involvements_file(event)
      roles = event.related("involvements").group_by { |involvement| involvement["role"] || "Organizer" }
      roles.sort_by { |role, _| [ role == "Organizer" ? 0 : 1, role ] }.map do |role, involvements|
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
          "close_date" => cfp["close_date"] || (Date.iso8601(event["start_date"]) - 1).iso8601
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
        tiers << prune("name" => tier["name"], "description" => tier["description"], "level" => tier["level"], "sponsors" => sponsors)
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
        "slug" => Rubyevents.slug(name).then { |slug| slug.empty? ? Rubyevents.slug(person["github_username"].to_s) : slug }
      }
    end

    def organization(organization)
      {
        "name" => organization["name"],
        "slug" => organization_slug(organization),
        "website" => organization["website"],
        # Our logo is a path on our website.
        "logo_url" => organization["logo_url"] && "#{@site}#{organization["logo_url"]}"
      }
    end

    def city(city)
      coordinates = city["coordinates"]
      {
        "name" => city["name"],
        "slug" => rubyevents_id(city) { Rubyevents.slug(city["name"]) },
        "state_code" => city["state_code"],
        "country_code" => city["country_code"],
        "latitude" => coordinates["latitude"],
        "longitude" => coordinates["longitude"]
      }
    end

    # Our API derives an organization's rubyevents slug from its name.
    def organization_slug(organization)
      organization["rubyevents_slug"] || Rubyevents.slug(organization["name"])
    end

    # rubyevents' own id where we know it, or one in their naming scheme.
    def rubyevents_id(resource)
      resource["rubyevents_slug"] || yield.tap { |id| report[:"#{resource.type} without rubyevents_slug"] |= [ "#{resource.id} -> #{id}" ] }
    end

    def coordinates(address)
      address["coordinates"]
    end

    def upcoming?(event)
      event["end_date"] && Date.iso8601(event["end_date"]) >= @today
    end

    def remember(resource)
      @referenced[resource.type][resource.id] = resource
    end

    def referenced(type)
      @referenced[type].values
    end

    def merge(path, resources, **options)
      list = ListFile.new(path)
      resources.each do |resource|
        record = yield(resource)
        status, name = list.merge(record, lookup: lookup(resource, record), **options)
        report[:"#{File.basename(path)} #{status}"] << name
      end
      list.write
    end

    # How to find a record's entry in rubyevents' list, surest first. A person's
    # rubyevents_slug is their profile on rubyevents.org: the GitHub handle, or else the slug.
    def lookup(resource, record)
      keys = resource.type == "people" ? %w[github slug] : %w[slug]
      [ *keys.map { |key| [ key, resource["rubyevents_slug"] ] }, *keys.map { |key| [ key, record[key] ] }, [ "name", record["name"] ] ]
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
      [ *parts.map { |part| Rubyevents.slug(part) }.reject(&:empty?), @event_id ].join("-")
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
    Entry = Struct.new(:text, :data)

    def initialize(path)
      @path = path
      @header, *chunks = File.read(path).split(/^(?=- )/)
      @blank_lines = chunks.first.to_s.end_with?("\n\n")
      @entries = chunks.map { |chunk| Entry.new(chunk.sub(/\n+\z/, "\n"), YAML.safe_load(chunk).first) }
    end

    # Finds the record's entry by the first of the lookup's keys and values that
    # matches one. Ours wins for each key we provide, except the keys in theirs;
    # the keys only rubyevents has stay. With alias_renames, a renamed entry keeps
    # its old name as an alias, which other files may still refer to.
    def merge(record, lookup:, defaults: {}, theirs: [], alias_renames: false)
      entry = lookup.lazy.filter_map do |key, value|
        @entries.find { |candidate| candidate.data[key].to_s.casecmp?(value) } unless value.to_s.empty?
      end.first

      if entry
        merged = entry.data.merge(record.compact, entry.data.slice(*theirs))
        return [ :unchanged, merged["name"] ] if merged == entry.data

        old_name = entry.data["name"]
        renamed = old_name != merged["name"]
        if renamed && alias_renames && merged["aliases"].to_a.none? { |other| other["name"] == old_name }
          merged["aliases"] = [ *merged["aliases"], { "name" => old_name, "slug" => Rubyevents.slug(old_name) } ]
        end
        status = renamed ? [ :renamed, "#{old_name} -> #{merged["name"]}" ] : [ :updated, merged["name"] ]
        entry.data = merged
        entry.text = YamlEmitter.dump([ merged ]).delete_prefix("---\n")
        status
      else
        data = record.merge(defaults) { |_key, ours, default| ours.nil? ? default : ours }.compact
        index = @entries.index { |other| other.data["name"].downcase > data["name"].downcase } || @entries.size
        @entries.insert(index, Entry.new(YamlEmitter.dump([ data ]).delete_prefix("---\n"), data))
        [ :added, data["name"] ]
      end
    end

    def write
      File.write(@path, @header + @entries.map(&:text).join(@blank_lines ? "\n" : ""))
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
