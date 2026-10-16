module Rubyevents
  class Document::Videos < Document
    # Upstream's "parent"/"children" providers describe a container video, which
    # only their single-event meetup layout needs. We export one event directory
    # per edition (decision 1B), so every talk is a video in its own right.
    PROVIDERS = %w[youtube mp4 vimeo scheduled not_published not_recorded].freeze
    WATCHABLE = %w[youtube mp4 vimeo].freeze

    def initialize(event, **options)
      super(**options)
      @event = event
    end

    def path
      "#{Rubyevents::Id.path_segment(@event.series, lenient: lenient?)}/" \
        "#{Rubyevents::Id.path_segment(@event, lenient: lenient?)}/videos.yml"
    end

    def content
      @event.talks.map { |talk| video(talk) }
    end

    private

    def video(talk)
      provider = fallback(talk.video_provider.presence_in(PROVIDERS), "not_recorded")

      {
        "id" => id_for(talk),
        "title" => talk.title,
        "raw_title" => talk.raw_title,
        "original_title" => talk.original_title,
        "description" => fallback(talk.description, "TODO"),
        "slug" => talk.slug,
        "kind" => talk.kind,
        "status" => talk.status,
        "speakers" => talk.speakers.map(&:name),
        "event_name" => @event.title,
        "date" => fallback(date(talk.date), date(@event.start_date) || "1970-01-01"),
        "time" => talk.time&.strftime("%H:%M"),
        "published_at" => timestamp(talk.published_at, provider),
        "announced_at" => timestamp(talk.announced_at, provider),
        "location" => talk.location,
        "video_provider" => provider,
        "video_id" => fallback(talk.video_id, id_for(talk) || talk.slug),
        "external_player" => talk.external_player,
        "external_player_url" => talk.external_player_url,
        "track" => talk.track,
        "language" => talk.language,
        "slides_url" => talk.slides_url,
        "additional_resources" => talk.additional_resources.map { |resource| additional_resource(resource) }
      }
    end

    # VideoSchema makes published_at imply a watchable provider, so carrying a
    # timestamp on an unrecorded talk would fail validation on its own. Strict
    # exports it anyway - that mismatch is a data problem worth seeing.
    def timestamp(value, provider)
      return nil if value.blank?
      return nil if lenient? && !provider.in?(WATCHABLE)

      value.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

    def additional_resource(resource)
      {
        "name" => resource.name,
        "url" => resource.url,
        "type" => resource.kind,
        "title" => resource.title
      }
    end
  end
end
