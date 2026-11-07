module Rubyevents
  class Document::Series < Document
    def initialize(series, **options)
      super(**options)
      @series = series
    end

    def path
      "#{Rubyevents::Id.path_segment(@series, lenient: lenient?)}/series.yml"
    end

    # Keys in the order of upstream's Yerbafile, so that formatting the files
    # there does not reorder them.
    def content
      drop("series.discord", "no field in SeriesSchema") if @series.discord.present?
      drop("series.frequency", "upstream derives it from the dates of the editions") if @series.frequency.present?

      {
        "id" => id_for(@series),
        "name" => @series.name,
        "location" => place(home_city),
        "timezone" => @series.time_zone,
        "website" => @series.website,
        "kind" => @series.kind,
        "language" => @series.language,
        # Upstream keeps twitter and bsky as bare handles, the rest as URLs.
        "twitter" => handle(@series.twitter_username),
        "facebook" => @series.facebook,
        "default_country_code" => @series.default_country_code,
        "meetup" => @series.meetup,
        "github" => @series.github,
        "mastodon" => @series.mastodon,
        "guild" => @series.guild,
        "linkedin" => @series.linkedin,
        "description" => text(@series.description),
        "luma" => @series.luma,
        "ended" => @series.ended,
        "bsky" => handle(@series.bluesky_handle),
        "banner_background" => @series.banner_background,
        "featured_background" => @series.featured_background,
        "featured_color" => @series.featured_color,
        "coordinates" => point(home_city&.coordinates)
      }
    end

    private

    # Where a meetup group meets: the city most of its events took place in.
    def home_city
      return unless @series.kind == "meetup"

      @home_city ||= Locations::City.joins(addresses: { venues: :events })
        .where(events_events: { events_series_id: @series.id })
        .group(:id).order(Arel.sql("COUNT(*) DESC"), :name).first
    end
  end
end
