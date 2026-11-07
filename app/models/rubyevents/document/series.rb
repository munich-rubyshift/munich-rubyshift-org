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

      {
        "id" => id_for(@series),
        "name" => @series.name,
        "website" => @series.website,
        "kind" => @series.kind,
        "frequency" => @series.frequency,
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
        "bsky" => handle(@series.bluesky_handle)
      }
    end
  end
end
