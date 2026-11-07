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
      drop("event.start_time/end_time", "EventSchema has them for one-day events only") if (@event.start_time || @event.end_time) && !one_day?

      {
        "id" => id_for(@event),
        "title" => meetup_title ? meetup_title.title : @event.title,
        "subtitle" => meetup_title&.subtitle,
        "location" => fallback(location, "TODO, TODO"),
        "timezone" => @event.time_zone,
        "kind" => fallback(@event.kind, default_kind),
        "description" => text(@event.description),
        "announced_on" => date(@event.announced_on),
        # Upstream's formatter deletes "day", their default.
        "date_precision" => @event.date_precision.presence_in(Events::Event::DATE_PRECISIONS - [ "day" ]),
        "start_date" => date(@event.start_date),
        "end_date" => date(@event.end_date),
        "start_time" => (@event.start_time if one_day?),
        "end_time" => (@event.end_time if one_day?),
        # Upstream only marks what is unusual: cancelled or postponed events
        # and hybrid ones.
        "status" => @event.status.presence_in(Events::Event::STATUSES - [ "scheduled" ]),
        "hybrid" => (true if @event.attendance_mode == "hybrid"),
        # Only the event's own links, without Events::SeriesDefaults: upstream
        # rejects an event repeating its series' links.
        "website" => @event[:website],
        "tickets_url" => (@event.tickets_url unless meetup_page?(@event.tickets_url)),
        "meetup" => @event[:meetup] || (@event.tickets_url if meetup_page?(@event.tickets_url)),
        "twitter" => handle(@event[:twitter_username]),
        "mastodon" => @event[:mastodon],
        "github" => @event[:github],
        "luma" => @event[:luma],
        "coordinates" => coordinates
      }
    end

    private

    # EventSchema's kinds are a subset of the series' wider list, so a series
    # kind is only usable when it happens to be valid for an event too.
    def default_kind
      @event.series&.kind.presence_in(Events::Event::KINDS) || "meetup"
    end

    def meetup_title
      return unless @event.kind == "meetup" && @event.start_date

      @meetup_title ||= Rubyevents::MeetupTitle.new(
        @event, same_month: @event.series.events.not_cancelled.where(start_date: @event.start_date.all_month).count > 1
      )
    end

    def one_day?
      @event.start_date.present? && @event.start_date == @event.end_date
    end

    # Upstream keeps an event's meetup.com page in "meetup", and "tickets_url"
    # for ticket shops.
    def meetup_page?(url)
      url.to_s.match?(%r{\Ahttps?://(www\.)?meetup\.com/}i)
    end

    def city
      @event.venue&.address&.city
    end

    def location
      @event.online? ? "online" : place(city)
    end

    # `false` is meaningful here: it is upstream's marker for an online event.
    def coordinates
      return false if @event.online?

      point(@event.venue&.coordinates || city&.coordinates)
    end
  end
end
