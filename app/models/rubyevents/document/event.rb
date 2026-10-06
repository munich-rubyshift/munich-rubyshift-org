module Rubyevents
  class Document::Event < Document
    def initialize(event, **options)
      super(**options)
      @event = event
    end

    def path
      "#{Rubyevents::Id.path_segment(@event.series, lenient: lenient?)}/" \
        "#{Rubyevents::Id.path_segment(@event, lenient: lenient?)}/event.yml"
    end

    def content
      drop("event.channel_id", "YouTubeChannelSchema needs id, name and handle") if @event.channel_id.present?
      drop("event.youtube", "no field in EventSchema") if @event.youtube.present?

      {
        "id" => id_for(@event),
        "title" => @event.title,
        # description/website/twitter/... fall back to the series through
        # Events::SeriesDefaults, so these read our effective values.
        "description" => @event.description,
        "kind" => fallback(@event.kind, default_kind),
        "hybrid" => @event.hybrid,
        "status" => @event.status,
        "last_edition" => @event.last_edition,
        "start_date" => date(@event.start_date),
        "end_date" => date(@event.end_date),
        "recordings_published_date" => date(@event.published_at),
        "announced_on" => date(@event.announced_on),
        "year" => @event.year,
        "date_precision" => @event.date_precision,
        "location" => fallback(location, "TODO, TODO"),
        "timezone" => fallback(timezone, "Europe/Berlin"),
        "venue" => @event.venue&.name,
        "playlist" => @event.playlist,
        "website" => @event.website,
        "twitter" => handle(@event.twitter),
        "mastodon" => @event.mastodon,
        "github" => @event.github,
        "meetup" => @event.meetup,
        "luma" => @event.luma,
        "tickets_url" => @event.tickets_url,
        "banner_background" => @event.banner_background,
        "featured_background" => @event.featured_background,
        "featured_color" => @event.featured_color,
        "coordinates" => coordinates
      }
    end

    private

    # EventSchema's kinds are a subset of the series' wider list, so a series
    # kind is only usable when it happens to be valid for an event too.
    def default_kind
      @event.series&.kind.presence_in(Events::Event::KINDS) || "meetup"
    end

    def city
      @event.venue&.address&.city
    end

    # Upstream's "City, Country" display string, which we compose rather than
    # store. Their EventCityNames validator wants the canonical city name.
    def location
      return nil unless city

      [ city.name, country_name(city.country_code) ].compact_blank.join(", ").presence
    end

    def timezone
      country_timezone(city&.country_code)
    end

    # `false` is meaningful here: it is upstream's marker for an online event.
    def coordinates
      return false if @event.online_event?

      pin = @event.venue&.coordinates || city&.coordinates
      return fallback(nil, { "latitude" => 0.0, "longitude" => 0.0 }) unless pin

      { "latitude" => pin.latitude.to_f, "longitude" => pin.longitude.to_f }
    end
  end
end
