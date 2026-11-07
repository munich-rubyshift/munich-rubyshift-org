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

    # Keys in the order of upstream's Yerbafile, so that formatting the files
    # there does not reorder them.
    def content
      drop("event.start_time/end_time", "no field in EventSchema") if @event.start_time || @event.end_time

      {
        "id" => id_for(@event),
        "title" => @event.title,
        "location" => fallback(location, "TODO, TODO"),
        "timezone" => @event.time_zone,
        "kind" => fallback(@event.kind, default_kind),
        "description" => text(@event.description),
        "announced_on" => date(@event.announced_on),
        # Upstream's formatter deletes "day", their default.
        "date_precision" => @event.date_precision.presence_in(Events::Event::DATE_PRECISIONS - [ "day" ]),
        "start_date" => date(@event.start_date),
        "end_date" => date(@event.end_date),
        # Upstream only marks what is unusual: cancelled or postponed events
        # and hybrid ones.
        "status" => @event.status.presence_in(Events::Event::STATUSES - [ "scheduled" ]),
        "hybrid" => (true if @event.attendance_mode == "hybrid"),
        # website/twitter/... fall back to the series through
        # Events::SeriesDefaults, so these read our effective values.
        "website" => @event.website,
        "tickets_url" => @event.tickets_url,
        "meetup" => @event.meetup,
        "twitter" => handle(@event.twitter_username),
        "mastodon" => @event.mastodon,
        "github" => @event.github,
        "luma" => @event.luma,
        "venue" => @event.venue&.name,
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
      return "online" if @event.online?
      return nil unless city

      [ city.name, country_name(city.country_code) ].compact_blank.join(", ").presence
    end

    # `false` is meaningful here: it is upstream's marker for an online event.
    def coordinates
      return false if @event.online?

      pin = @event.venue&.coordinates || city&.coordinates
      return fallback(nil, { "latitude" => 0.0, "longitude" => 0.0 }) unless pin

      { "latitude" => pin.latitude.to_f, "longitude" => pin.longitude.to_f }
    end
  end
end
