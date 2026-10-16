module Rubyevents
  class Document::Series < Document
    def initialize(series, **options)
      super(**options)
      @series = series
    end

    def path
      "#{Rubyevents::Id.path_segment(@series, lenient: lenient?)}/series.yml"
    end

    def content
      drop("series.discord", "no field in SeriesSchema") if @series.discord.present?

      {
        "id" => id_for(@series),
        "name" => @series.name,
        "description" => @series.description,
        "kind" => @series.kind,
        "frequency" => @series.frequency,
        "ended" => @series.ended,
        "default_country_code" => @series.default_country_code,
        "language" => @series.language,
        "website" => @series.website,
        "original_website" => @series.original_website,
        # Upstream keeps these two as bare handles and the rest as full URLs.
        "twitter" => handle(@series.twitter),
        "bsky" => handle(@series.bsky),
        "facebook" => @series.facebook,
        "mastodon" => @series.mastodon,
        "github" => @series.github,
        "linkedin" => @series.linkedin,
        "meetup" => @series.meetup,
        "luma" => @series.luma,
        "guild" => @series.guild,
        "vimeo" => @series.vimeo,
        "youtube_channels" => youtube_channels
      }
    end

    private

    # Our four flat columns are upstream's array of channel objects. All three
    # of id/name/handle are required there, so a partial fill exports nothing
    # and shows up as missing data rather than an invalid channel.
    def youtube_channels
      channel = {
        "id" => @series.youtube_channel_id,
        "name" => @series.youtube_channel_name,
        "handle" => @series.youtube_channel_handle,
        "playlist_matcher" => @series.playlist_matcher
      }.compact_blank

      return [] unless channel.values_at("id", "name", "handle").all?(&:present?)

      [ channel ]
    end
  end
end
